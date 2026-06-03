# Lessons Learned
Rules added here prevent repeated mistakes. Each rule was born from an actual error.

## Code Patterns

### Frontend Design
- All AI models default to generic templates (Inter font, purple gradients, cards-in-cards). Always challenge the first design output with `/critique` before accepting.
- Animations should have purpose. Never animate just because you can. Every motion must communicate state change, guide attention, or provide feedback.
- Dark mode is not "invert colors". It requires separate consideration for contrast, shadows, and surface hierarchy.

## Common Pitfalls

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
