# Project Overview
Betrade is a Flutter mobile client app (Android + iOS) for a "trade" / prediction-market product. It talks to a single REST backend at `api.buildacademy.io` for OTP-based auth, KYC, profile, and trade browsing. State is held in `provider` `ChangeNotifier`s; the bearer token, theme, and onboarding flag persist in `SharedPreferences`. There is no application database, no real-time channel, and no server-side code in this repo — it is a client-only codebase.

# Tech Stack
- Flutter / Dart (SDK `>=3.3.0 <4.0.0`), Material 3
- State management: `provider` (9 `ChangeNotifier`s, registered in `lib/main.dart`)
- Networking: `http` and `dio` (both used; `http` is the dominant pattern)
- Local persistence: `shared_preferences` (token, theme, onboarding flag)
- Env: `flutter_dotenv` loading `.env` (single key: `BASE_URL`)
- UI: `flutter_screenutil`, `fl_chart`, `iconsax`, custom theme tokens
- Capture: `camera`, `image_picker`, `permission_handler`, `flutter_image_compress`, `path_provider`
- Tests: `flutter_test` (only the default scaffold currently — `flutter test` fails on `main`)
- No CI on `main`; Codemagic config exists on a feature branch

# Architecture
Layered: `lib/core/` (cross-cutting) → `lib/data/{model, provider, services}` → `lib/presentation/{screens, widget, ...}`. Request flow: UI → `context.read<Provider>()` → `Service.staticMethod()` → `http`/`dio` → backend. Single environment, single backend at `api.buildacademy.io`.

See `docs/ARCHITECTURE.md` for details.

# Directory Structure
- `lib/` — all Dart source
- `assets/` — images, logo, fonts (SFProRounded), bundled `.env`
- `test/` — Flutter tests (currently only the default scaffold)
- `android/` — Android platform project (Kotlin/Gradle)
- `ios/` — iOS platform project (Xcode)
- `web/`, `windows/`, `macos/`, `linux/` — default Flutter scaffolds (unmodified)
- `docs/` — project documentation (AUDIT, ARCHITECTURE, PATTERNS, ACCESS, DEPLOY_LOG, SSH_CONFIG)
- `tasks/` — `todo.md` and `lessons.md`
- `.claude/` — slash commands, agents, skills, settings

# Key Commands
- `flutter pub get` — install dependencies
- `flutter analyze` — static analysis
- `flutter run` — run on connected device/emulator
- `flutter test` — run tests (currently fails on `main`)
- `flutter build apk` / `appbundle` / `ios` / `ipa` — release builds
- `dart run flutter_launcher_icons` — regenerate launcher icons

# Coding Conventions
- File names: `snake_case.dart` (existing inconsistencies documented in `docs/CODEBASE_AUDIT.md` §11)
- Classes: `PascalCase`; members: `camelCase`; private: `_camelCase`
- Models: manual `fromJson`, no `toJson`, no codegen
- Services: `static` methods returning `Future<Model>` / `Future<List<Model>>`; sentinel returns (`[]`, `null`, `false`) on error
- Providers: extend `ChangeNotifier`; public mutable fields (`isLoading`, `error`, data); `notifyListeners()` after every mutation
- Imports: relative for siblings; `package:betrade/...` for cross-feature jumps; no barrel files

# Patterns
See `docs/PATTERNS.md` for examples with real code.

# Testing
- Framework: `flutter_test`
- Location: `test/` (currently only `widget_test.dart` — the default scaffold; `flutter test` fails on `main`)
- How to run: `flutter test` (or `flutter test --coverage`)
- No mocking package configured (`mockito`/`mocktail` not in dev_deps yet)

# Task Management
- Before starting work, write plan to `tasks/todo.md`
- Track progress by marking items complete
- After ANY correction or mistake, update `tasks/lessons.md` with a rule that prevents it
- After completing work, add entry to `CHANGELOG.md`

# Git Workflow
- Always create a feature branch: `feature/[your-name]/[short-description]`
- Never commit directly to `main`
- Every PR must have a clear description of what changed and why
- Run tests before pushing
- Request review from at least one team member

# Important Rules
- NEVER modify code without an approved plan
- NEVER skip tests
- ALWAYS check `docs/PATTERNS.md` before creating new patterns
- ALWAYS update `CHANGELOG.md` with your changes
- Do not touch: `.claude/skills/` (third-party), `.git/`, `build/`, `.dart_tool/`, `ios/Pods/`, `android/.gradle/`, `.env` files

## Frontend Design Rules (Impeccable)
- For ANY frontend/UI work, run `/audit` after `/review` and `/polish` before final commit
- Never use Inter, Arial, Roboto, or system fonts as primary typeface — pick distinctive fonts
- Never use pure gray — always tint neutrals toward the brand color
- Never nest cards inside cards
- Never use gray text on colored backgrounds — check contrast
- Never use purple gradients as default — commit to a project-specific color palette
- Never use bounce/elastic easing — it feels dated
- See `.claude/skills/frontend-design/` for full design reference

# Bulk Operation Safety
- NEVER run bulk find-and-replace (`sed`, `grep -rl | xargs`) without excluding: `.claude/skills/`, `.git/`, `build/`, `.dart_tool/`, `ios/Pods/`, `android/.gradle/`, lock files
- Safe bulk rename pattern: `grep -rl 'old' --exclude-dir=.git --exclude-dir=build --exclude-dir=.dart_tool --exclude-dir=.claude/skills . | xargs sed -i 's/old/new/g'`
- ALWAYS show the list of files that will be affected BEFORE running any bulk operation
- ALWAYS ask for confirmation before executing bulk changes

# Security Rules (Enforced on Every Task)
- NEVER store auth tokens in plain `SharedPreferences` for production builds — use `flutter_secure_storage`
- NEVER return stack traces, file paths, or internal errors in app-visible messages
- NEVER concat user input into URL paths without `Uri.encodeComponent`
- NEVER commit `.env` files, signing keystores, or hardcoded secrets in source code
- ALWAYS validate environment variables at app startup (`EnvConfig.baseUrl` already does this)
- ALWAYS use HTTPS for all API calls; remove `android:usesCleartextTraffic="true"` before release
- ALWAYS hash any user passwords on the backend with bcrypt/argon2 (out of scope for this client)

# Deployment Rules
- This is a mobile app — "deployment" means building signed binaries (APK / AAB / IPA)
- Release Android builds currently use the **debug** keystore — must be fixed before Play Store distribution (see `docs/CODEBASE_AUDIT.md` §8)
- Log every release build / TestFlight upload to `docs/DEPLOY_LOG.md`
- For server-targeting commands (`/deploy`, `/test-live`, `/monitor`, `/logs`, `/db`), see `docs/SSH_CONFIG.md` — these only apply once a build/deploy server is added
- NEVER run bulk `sed`/find-replace without excluding: `.claude/skills/`, `.git/`, `build/`, `.dart_tool/`, lock files
- Before ANY operation touching 5+ files, show the file list and wait for `APPROVED`

# Testing Rules
- Every new feature MUST have at least one widget or unit test
- Tests must verify **behaviour** (what SHOULD happen), not just implementation
- Run `/test` before every push — no exceptions
- After human QA finds a bug, add a regression test so it's caught automatically next time
- Test categories: API contract, business logic, integration, security
- For human QA test cases, run `/generate-qa-sheet` before release

# Subdirectory Docs
- `lib/CLAUDE.md`, `lib/core/CLAUDE.md`
- `lib/data/CLAUDE.md`, `lib/data/model/CLAUDE.md`, `lib/data/provider/CLAUDE.md`, `lib/data/services/CLAUDE.md`
- `lib/presentation/CLAUDE.md`, `lib/presentation/widget/CLAUDE.md`, `lib/presentation/screens/CLAUDE.md`
- `test/CLAUDE.md`, `android/CLAUDE.md`, `ios/CLAUDE.md`, `assets/CLAUDE.md`

# Context Window Budget
- Root `CLAUDE.md`: under 150 lines (this file)
- Each subdirectory `CLAUDE.md`: under 80 lines
- `tasks/lessons.md`: prune entries older than 30 days to an archive file
- `docs/explorations/`: delete explorations older than 2 weeks (re-explore if needed)
- `.claudeignore` keeps build artifacts, lockfiles, and binary assets out of context
- When context feels heavy: run `/compact` to compress conversation history
- One task per session — start fresh, don't carry over context from previous tasks
