# Lessons Learned
Rules added here prevent repeated mistakes. Each rule was born from an actual error.

## Build & Install

### Always use split APKs for device installs (2026-05-27)
User directive: **"reinstall the split apks all time when new update comes in"**. Going forward, every device install MUST follow this exact pattern:

```bash
# 1. Build the per-ABI split APKs (NOT --target-platform — that produces a single APK with versionCode 10)
flutter build apk --debug --split-per-abi

# 2. Install the arm64 split (the vivo V2143 + most modern phones are arm64-v8a)
adb -s <DEVICE> install -r build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk
```

Why:
- arm64 split is ~110 MB vs ~198 MB universal → ~45% faster transfer over wireless ADB.
- The split build adds +2000 to versionCode (1000 for armeabi-v7a, 2000 for arm64-v8a, 4000 for x86_64). Mixing build modes triggers `INSTALL_FAILED_VERSION_DOWNGRADE` — if it ever happens, `adb uninstall com.build.betrade` then fresh install (user has to log in again afterward).

Do NOT use `flutter build apk --debug --target-platform android-arm64` — it builds an arm64-only APK but with the BASE versionCode (10), which is treated as a downgrade after any previous split install.

## Code Patterns

### Frontend Design
- All AI models default to generic templates (Inter font, purple gradients, cards-in-cards). Always challenge the first design output with `/critique` before accepting.
- Animations should have purpose. Never animate just because you can. Every motion must communicate state change, guide attention, or provide feedback.
- Dark mode is not "invert colors". It requires separate consideration for contrast, shadows, and surface hierarchy.

## Common Pitfalls

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
