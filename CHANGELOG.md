# Changelog
All notable changes to this project are documented here.
Format: [DATE] [AUTHOR] Description

## [Unreleased]

### Added
- 2026-04-30 — Initial Claude Code documentation layer (`CLAUDE.md`, `docs/`, `tasks/`, `.claude/`).
- 2026-04-30 — `docs/CODEBASE_AUDIT.md` — read-only audit covering structure, tech stack, data flow, models, endpoints, tests, build/deploy, env vars, integrations, and dead code.
- 2026-04-30 — `docs/ARCHITECTURE.md` — system overview, layered architecture, directory map, API surface, auth model, deployment notes.
- 2026-04-30 — `docs/PATTERNS.md` — descriptive style guide with real code examples for the 12 standard pattern categories.
- 2026-04-30 — Per-directory `CLAUDE.md` files in `lib/`, `lib/core/`, `lib/data/`, `lib/data/model/`, `lib/data/provider/`, `lib/data/services/`, `lib/presentation/`, `lib/presentation/widget/`, `lib/presentation/screens/`, `test/`, `android/`, `ios/`, `assets/`.
- 2026-04-30 — Slash commands in `.claude/commands/` (explore, plan, review, done, pickup, test, security, deploy, rollback, monitor, logs, status, generate-manual, db, plus the testing suite and Impeccable bootstrap).
- 2026-04-30 — `.claude/agents/doc-updater.md` — documentation maintenance agent.
- 2026-04-30 — `.claudeignore`, `tasks/todo.md`, `tasks/lessons.md`, `docs/DEPLOY_LOG.md`, `docs/SSH_CONFIG.md`, `docs/ACCESS.md`.

### Changed
- 2026-05-23 — Refreshed Claude Code documentation layer with current state. Corrected stale counts (~14 providers, ~13 models — were 9/5) and token-polling interval (300 s — was 10 s). `.claude/settings.json` Bash permissions adapted from Node-style (`npm`/`pnpm`/`docker`/`pg_dump`) to Flutter-native (`flutter`/`dart`/`pod`/`./gradlew`/`adb`/`firebase`/`flutterfire`) and gained Write/Edit denies for `.env`, `android/key.properties`, `*.keystore`/`*.jks`, and Firebase service files. Root `CLAUDE.md`, docs/, all 13 subdirectory `CLAUDE.md` files, 15 slash commands, and the `doc-updater` subagent rewritten; pre-existing maintainer content in `tasks/todo.md`, `tasks/lessons.md`, prior `CHANGELOG.md` entries, `docs/ACCESS.md`, `docs/SSH_CONFIG.md`, and `.claudeignore` preserved as supersets of provided templates.
- 2026-05-05 — `lib/presentation/screens/signin/otp_screen.dart` migrated to `pinput` (^5.0.0) for the 6-cell OTP input. Replaces the manual `List<TextEditingController>` + `List<FocusNode>` + per-cell `TextField` with a single `Pinput` widget; gains paste-fill, haptics, fade animation, and platform SMS-autofill hooks. All business logic (timer, verify, resend, navigate, error handling) preserved unchanged.

### Fixed
- 2026-05-23 — **Trading UX critical bugs (4 fixes from QA report)** on `feature/claude/docs-refresh`:
  - `success_animation.dart` — `SuccessScreen` now navigates to `MainScreen` after the success animation instead of bouncing the user back to `AuthScreen`. The signup OTP-verify in step 2 has already persisted a token, so the user is authenticated — sending them to AuthScreen forced a redundant login (QA #1). Passes `showWelcomePopup: true` + `docUploadStatus` from `LocalStorage`, surfacing the KYC banner inside MainScreen so verification starts right after signup (QA #13).
  - `trade_page.dart` `selectQuickAmount` (renamed from `addQuickAmount`) — quick-amount chip taps now **replace** the current amount instead of adding to it. Tapping 10 then 20 now gives 20 GHS instead of 30 (QA #11, wrong-amount trades).
  - `trade_page.dart` quick-amount chip Row — chips now visually reflect selection: filled purple background + white text when `amount == chip value`, transparent + purple text + grey border otherwise. `AnimatedContainer` for a 150 ms transition (QA #10).
  - `trade_details_page.dart` — added Buy Yes / Buy No `bottomNavigationBar` to the chart/info bottom sheet. Tapping either closes the details sheet and reopens `TradePage` (the New Trade modal) with the chosen outcome pre-selected via `initialOutcome` (QA #12).
- 2026-05-23 — **Login + OTP critical bugs (7 fixes)** on `feature/claude/docs-refresh`:
  - `auth_service.dart` `verifyOtp` + `verifyLoginOtp` — persist token to `SharedPreferences` BEFORE setting the in-memory `DioClient` header. Prevents an inconsistent recovery state if the app dies between the two operations.
  - `local_storage.dart` `setToken` + `auth_service.dart` `saveFcmToken` — dropped `print(token)` calls that were leaking bearer / FCM tokens to `adb logcat`.
  - `profile_page.dart` `logoutUser` — always run `LocalStorage.clearToken()` + `DioClient.removeToken()` in `finally`, regardless of whether the server-side `/logout` call succeeded. Prevents stale `Authorization` header leaking into `DioClient.multipartInstance` for the next user's file uploads, and unblocks logout when the token is already server-revoked.
  - `otp_screen.dart` (login OTP) + `OTP_step.dart` (signup OTP) — distribute pasted OTP digits across all 6 cells (was keeping only the last char). Removed `maxLength: 1` from each cell; added `LengthLimitingTextInputFormatter(6)` so paste survives into `onChanged`.
  - `otp_screen.dart` `_verifyOtp` — stop calling `_clearOtpFields()` on verify failure. Users can now fix a one-digit typo without re-entering all six cells.
  - `login_screen.dart` `_handleContinue` — `_isLoading` field was declared but never set, so the `CircularProgressIndicator` block was unreachable. Now set synchronously in a `setState` before the `await`, with `finally` reset. Replaces the stale `loginProvider.isLoading` gate (login flow doesn't use `LoginProvider`).
  - `login_screen.dart` `_handleContinue` — synchronous re-entry guard (`if (_isLoading) return;`) prevents rapid double-taps from firing duplicate OTP-send requests. Network failures now show "Network error. Please check your connection." instead of leaking raw `DioException` text.

### Removed
(none)
