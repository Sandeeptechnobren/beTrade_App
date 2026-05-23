# Project Overview
BeTrade is a Flutter mobile client (Android + iOS) for a prediction-market / "trade" product. Users browse markets, fetch live LMSR quotes, place buy orders, track positions, and manage a wallet — all via REST calls to a Laravel backend at `api.buildacademy.io` (operated outside this repo). State is held in `provider` `ChangeNotifier`s; the bearer token, theme, and onboarding flag persist in `SharedPreferences`. There is no application database, no real-time channel beyond FCM, and no server-side code in this repo.

# Tech Stack
- Flutter / Dart (SDK `>=3.3.0 <4.0.0`), Material 3
- State management: `provider` (~14 `ChangeNotifier`s registered in `lib/main.dart`)
- Networking: `dio` (primary, via `DioClient` singleton) + `http` (legacy, in some services and the sign-in provider)
- Local persistence: `shared_preferences` (token, theme, onboarding flag); no SQL / NoSQL / Hive
- Env: `flutter_dotenv` loading `.env` (single key: `BASE_URL`)
- Firebase: `firebase_core`, `firebase_messaging` (FCM only — Firestore/Storage NOT used) + `flutter_local_notifications`
- UI: `flutter_screenutil`, `fl_chart`, `iconsax`, `lucide_icons`, `pinput`
- Camera / image: `camera`, `image_picker`, `flutter_image_compress`, `path_provider`, `permission_handler`
- Tests: `flutter_test` only — current scaffold fails on `main`
- No CI on `main`; Codemagic config exists only on unmerged feature branches

# Architecture
Layered: `lib/core/` (cross-cutting) → `lib/data/{model, provider, services}` → `lib/presentation/{screens, widget, …}`. Request flow: UI → `context.read<Provider>()` → `Service.staticMethod()` → `DioClient` → backend. Auth = bearer token from OTP, polled every 300 s by `MainScreen`. See `docs/ARCHITECTURE.md` for details.

# Directory Structure
- `lib/` — all Dart source
- `assets/` — images, logo, fonts (SFProRounded), bundled `.env`
- `test/` — Flutter tests (only the default scaffold; broken)
- `android/` — Android platform project (Kotlin/Gradle)
- `ios/` — iOS platform project (Xcode)
- `web/`, `windows/`, `macos/`, `linux/` — default Flutter scaffolds, unused
- `docs/` — `ARCHITECTURE.md`, `CODEBASE_AUDIT.md`, `PATTERNS.md`, `ACCESS.md`, `DEPLOY_LOG.md`, `SSH_CONFIG.md`
- `tasks/` — `todo.md`, `lessons.md`, roadmaps, plans
- `.claude/` — slash commands, agents, skills, settings

# Key Commands
- `flutter pub get` — install dependencies
- `flutter analyze` — static analysis (`flutter_lints` config)
- `flutter run` — debug on connected device/emulator
- `flutter test` — run tests (**currently fails on `main`**)
- `flutter build apk` / `appbundle` / `ios` / `ipa` — release artefacts
- `dart run flutter_launcher_icons` — regenerate launcher icons

# Coding Conventions
- File names: `snake_case.dart` (pre-existing exceptions documented in `docs/CODEBASE_AUDIT.md` §11)
- Classes `PascalCase`; members `camelCase`; private `_camelCase`
- Models: manual `fromJson`, no `toJson`, no codegen
- Services: abstract class + `static` methods; `Future<Model>` / `Future<List<Model>>` / `Future<bool>` / `Future<TypedResponse>`
- Providers: extend `ChangeNotifier`; public mutable `isLoading` / `error` / data fields; `notifyListeners()` after every mutation
- Imports: relative for siblings; `package:betrade/...` for cross-feature jumps; no barrel files

# Patterns
See `docs/PATTERNS.md` for examples with real code (12 patterns: API calls, persistence, error handling, auth injection, env, feature folders, tests, background work, widgets, response shapes, naming, imports).

# Testing
- Framework: `flutter_test`
- Location: `test/` (only `widget_test.dart` — the broken default scaffold)
- How to run: `flutter test` (or `flutter test --coverage`)
- No mocking package configured. Recommended next add: `mocktail` + `integration_test`.

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
- Do not touch: `.claude/skills/` (third-party), `.git/`, `build/`, `.dart_tool/`, `ios/Pods/`, `android/.gradle/`, `android/key.properties`, `*.keystore`, `*.jks`, `.env` files

# Bulk Operation Safety
- NEVER run bulk find-and-replace (`sed`, `grep -rl | xargs`) without excluding: `.claude/skills/`, `.git/`, `build/`, `.dart_tool/`, `ios/Pods/`, `android/.gradle/`, `pubspec.lock`, `ios/Podfile.lock`
- Safe bulk rename: `grep -rl 'old' --exclude-dir=.git --exclude-dir=build --exclude-dir=.dart_tool --exclude-dir=ios/Pods --exclude-dir=android/.gradle --exclude-dir=.claude/skills . | xargs sed -i 's/old/new/g'`
- ALWAYS show the list of files that will be affected BEFORE running any bulk operation
- ALWAYS ask for confirmation before executing bulk changes

# Security Rules (Enforced on Every Task)
- NEVER store auth tokens in plain `SharedPreferences` for production — use `flutter_secure_storage`
- NEVER surface raw exception messages, stack traces, or file paths in the UI — map typed backend codes (`INSUFFICIENT_FUNDS`, `KYC_REQUIRED`, etc.) to user messages
- NEVER concat user input into URL paths without `Uri.encodeComponent`
- NEVER commit `.env`, signing keystores (`*.jks`, `*.keystore`), `key.properties`, or hardcoded secrets to git
- ALWAYS validate environment variables at app startup (`EnvConfig.baseUrl` already does this; throws on missing `BASE_URL`)
- ALWAYS use HTTPS for all API calls; remove `android:usesCleartextTraffic="true"` before release
- ALWAYS verify FCM message origin before acting on payload-driven navigation
- Backend security (parameterised SQL, password hashing, webhook signatures, rate-limiting) lives in the external Laravel API — out of scope for this client repo

# Deployment Rules
- This is a mobile app — "deployment" means producing signed binaries (APK / AAB / IPA), not pushing to a server
- Release Android builds currently use the **debug** keystore — must be fixed before Play Store distribution (`android/app/build.gradle.kts:30`; see `docs/CODEBASE_AUDIT.md` §8)
- iOS releases need `DEVELOPMENT_TEAM` + provisioning profile configured — currently absent
- Log every release build / TestFlight upload to `docs/DEPLOY_LOG.md`
- Server-targeting slash commands (`/deploy`, `/test-live`, `/monitor`, `/logs`, `/db`) require a server target — see `docs/SSH_CONFIG.md`. Currently no server is provisioned.
- NEVER run bulk `sed` / find-replace without excluding the paths in the Bulk Operation Safety section above
- Before ANY operation touching 5+ files, show the file list and wait for `APPROVED`

# Testing Rules
- Every new feature MUST have at least one widget or unit test
- Every new service MUST have a unit test that stubs `Dio` / `http`
- Tests must verify **behaviour** (what SHOULD happen), not implementation
- Run `flutter test` before every push — no exceptions
- After human QA finds a bug, add a regression test so it's caught automatically next time
- Test categories: API contract, business logic, integration, security
- For human QA test cases, run `/generate-qa-sheet` before release
- Multi-tenant / tenant-isolation tests are NOT applicable — single-tenant app

# Subdirectory Docs
- `lib/CLAUDE.md`, `lib/core/CLAUDE.md`
- `lib/data/CLAUDE.md`, `lib/data/model/CLAUDE.md`, `lib/data/provider/CLAUDE.md`, `lib/data/services/CLAUDE.md`
- `lib/presentation/CLAUDE.md`, `lib/presentation/screens/CLAUDE.md`, `lib/presentation/widget/CLAUDE.md`
- `test/CLAUDE.md`, `android/CLAUDE.md`, `ios/CLAUDE.md`, `assets/CLAUDE.md`

# Context Window Budget
Claude's context window is finite. These rules protect it:
- Root `CLAUDE.md`: under 150 lines (this file)
- Each subdirectory `CLAUDE.md`: under 80 lines
- `tasks/lessons.md`: prune entries older than 30 days to an archive file
- `docs/explorations/`: delete explorations older than 2 weeks (re-explore if needed)
- `.claudeignore`: keeps build artifacts, dependencies, and large binaries out of context
- When context feels heavy: run `/compact` to compress conversation history
- One task per session — start fresh, don't carry over context from previous tasks
