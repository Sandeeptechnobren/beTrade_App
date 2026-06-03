# Lessons Learned
Rules added here prevent repeated mistakes. Each rule was born from an actual error.

## Code Patterns

### Frontend Design
- All AI models default to generic templates (Inter font, purple gradients, cards-in-cards). Always challenge the first design output with `/critique` before accepting.
- Animations should have purpose. Never animate just because you can. Every motion must communicate state change, guide attention, or provide feedback.
- Dark mode is not "invert colors". It requires separate consideration for contrast, shadows, and surface hierarchy.

## Common Pitfalls

### Google Sign-In Android: the SHA-1 is per-machine and lives in Google Cloud, not the APK (2026-06-03)
Native Google Sign-In on Android only works if the SHA-1 of the keystore that signed the APK is registered on an Android OAuth client (type 1, matching package) in the SAME Google Cloud project whose web client is passed as `serverClientId`. Gotchas that bit us: (a) **debug keystores differ per developer machine** — the committed `google-services.json` had Abhishek's debug SHA-1 (`947f4de9…`), but this machine's debug keystore is `e4c3a212…`, so a build from here fails with `ApiException: 10` until our SHA-1 is added; (b) registering a SHA-1 in the Console takes effect for the **already-installed** app — no rebuild needed; (c) get the SHA-1 with `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`. **Rule:** when wiring Google Sign-In, confirm WHICH keystore signs the build and that its SHA-1 is registered before expecting it to work on device — it's a Console action the dev must do, not something code can fix.

### `serverClientId` = WEB client; the idToken `aud` is the web client, not the android client (2026-06-03)
With `google_sign_in` v7 + `initialize(serverClientId: <WEB client id>)`, the returned idToken's `aud` claim is the **web** client. So the backend audience check must include `GOOGLE_OAUTH_WEB_CLIENT_ID`. Setting only the android client id makes every real token fail the aud check. The android OAuth client (with SHA-1) authorizes the device; the web client defines the token audience — both must exist in the project, and the backend must whitelist the web client id.

### Parallelising multi-file features with agents: define the interface contract first (2026-06-03)
Three agents built the Google flow simultaneously (data layer / new screen / screen-wiring) with zero rework because: (a) their file sets were **disjoint** (no two agents edited the same file), and (b) every agent got the SAME explicit contract — exact method signatures, return-map keys, the new screen's class+constructor, and import paths. The consumers (screens) were written against the contract in parallel with the producer (provider), and `flutter analyze` at the end confirmed the seams. **Rule:** to fan out a feature across agents, first pin the interface (signatures + return shapes + file ownership), forbid agents from running shared `flutter`/`pub` commands (they clash on one working tree), and verify seams centrally afterwards.

### Original pitfalls

### Don't gate buttons on derived state that can race with controllers (2026-06-02)
Client reported "after entering the pin the button is not responsive" on the login OTP screen. Root cause: the button's `onPressed` was gated on a local `isOtpComplete` flag updated inside the `TextField.onChanged` callback after multiple focus changes and `setState` schedules. Even when the visible cells held 6 digits, the flag could lag a frame — and a `null` `onPressed` feels broken (no ripple, no feedback). **Rule:** for forms, prefer "button always tappable when no request is in flight; validate inside the handler and surface a clear toast" over "button gated on a derived `isComplete` boolean." The disabled-look state can still follow the derived flag for visual cues, but `onPressed` should not be `null`.

### Don't run the success path of an API call without inspecting the response envelope (2026-06-02)
The login OTP `_resendOtp` ignored the `{status, message}` envelope and ALWAYS ran `_clearOtpFields() + _startTimer() + "OTP resent successfully"`. When the backend returned `{status: false}` (e.g. user not found, validation reject), the user got a false success toast AND a fresh 30 s cooldown — the resend button was unreachable for half a minute on a silently-failed resend. **Rule:** if the API contract is `{status: bool}` or `{success: bool}`, every caller must branch on it before running side effects.

### Don't clear source-of-truth state while leaving the visible UI intact (2026-06-02)
Signup OTP `case 2` on failed verify called `provider.setOtp("")` AND `isOtpValid = false`, but did NOT clear the child `StepOtp._controllers`. The user saw 6 digits in the cells and a disabled Continue button — taps felt like "the button doesn't respond". **Rule:** when invalidating an input on failure, either (a) leave the input intact AND keep the button enabled so the user can retry / edit, OR (b) clear both the visible widgets AND the underlying state — never leave them in disagreement.

### Persistent error UI &gt; transient snackbar for retryable failures (2026-06-02)
The login send-OTP failure path only showed a 3 s snackbar then disappeared, with the same "Continue" button and no other affordance. Users complained "no resend option" — they had no persistent cue that something needed retrying. **Rule:** for retryable operations (send OTP, submit form, fetch with retry), pair the transient toast with a persistent inline chip + a button-label flip ("Continue" → "Try again") so the retry intent stays obvious until the user acts.

### Generic backend-flavoured templates on a Flutter mobile client
Slash-command and doc templates often assume a Node/Express/PostgreSQL backend (npm scripts, ORM patterns, `tenant_id` checks, webhook signatures, `pg_dump` backups, `pm2`/`docker-compose` deploys). Mobile-client repos have none of those. When applying a generic template:
- **Drop** sections referencing SQL, multi-tenant filtering, webhook signature verification, npm/pnpm/docker tooling, and `localStorage` token storage. They add noise to security audits and waste cycles.
- **Substitute** the Node/Express terminology with Flutter equivalents: `npm test` → `flutter test`, `pm2 restart` → `flutter build apk`, `localStorage` → `SharedPreferences` / `flutter_secure_storage`.
- Backend-specific rules (parameterised SQL, password hashing, rate limiting) apply to the external Laravel API at `api.buildacademy.io`, NOT to this client repo.

### Tool-level safety vs Claude-side discipline
`.claude/settings.json` `Write(.env)` / `Edit(.env)` / `Write(android/key.properties)` / `Write(*.keystore)` / `Write(*.jks)` / `Write(ios/Runner/GoogleService-Info.plist)` denies enforce safety at the **tool level** — the Write/Edit tools simply refuse. CLAUDE.md "NEVER commit secrets" rules are **Claude-side discipline only** — a careless write could still slip through. Both layers are needed; don't remove the settings.json denies just because the CLAUDE.md rule exists.

## Testing
(none yet)

## Bulk Operations
- **NEVER** run `sed -i` on files without checking the file list first.
- **NEVER** run `find -exec` on directories without excluding: `.claude/skills/`, `node_modules/`, `.git/`, `dist/`, `build/`, `.dart_tool/`, `ios/Pods/`, `android/.gradle/`.
- **ALWAYS** show the exact file list before any operation touching 5+ files.
- **ALWAYS** exclude lock files (`package-lock.json`, `bun.lock`, `yarn.lock`, `pubspec.lock`, `Podfile.lock`) from bulk modifications.
