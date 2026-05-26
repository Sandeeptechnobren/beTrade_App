# Changelog
All notable changes to this project are documented here.
Format: [DATE] [AUTHOR] Description

## [Unreleased]

### Changed
- 2026-05-26 — **Rankings tab now shows a "Coming Soon" dialog** on `feature/abhiCloude`:
  - `main_screen.dart` — `CustomBottomNav` onTap now intercepts `index == 2` and shows a centered Material `Dialog` (leaderboard icon, "Coming Soon" + "The Rankings feature is on its way. Stay tuned!" + Got it button) instead of switching tabs. The selected tab stays where it was.
  - `IndexedStack` slot 2 changed from `InfoChartScreen()` to `const SizedBox.shrink()` so the chart screen is no longer instantiated; `info_chart_screen.dart` import removed.
  - Rationale: Rankings is absent from the current Figma cut, so we surface "Coming Soon" rather than ship the legacy chart placeholder.
- 2026-05-26 — **Achievements sheet (`achivement_Sheet.dart`) aligned to Figma spec** on `feature/abhiCloude`:
  - Badge swapped from a transparent `CircleAvatar(radius: 30)` to a 64×64 `Container` with `1px #F4F4F5` border and `DecorationImage` (matches Figma's bordered circle badges).
  - Title text restyled from 12sp/500/black87 to 16sp/500/`#52525B` with `height: 1.2` per Figma's 120% line-height.
  - Replaced `GridView.builder` with two `Row`s of 4 `Expanded` cells (24.h gap between rows, 8.w between columns). The grid's `childAspectRatio` was clipping the 2-line title by ~1px on narrower devices; natural cell sizing eliminates the overflow entirely.
  - Outer padding `8/8/8/16` → `20/24/20/24` (matches Figma's 20px side padding and 24px header→content gap).
  - Removed orphan `AppColors` import and trailing `SizedBox(height: 12.h)`.
  - `profile_page.dart` — Achievements bottom-sheet size reduced from `0.55/0.45/0.6` to `0.5/0.45/0.55` to hug the now-tighter content and eliminate the empty band below row 2.
- 2026-05-26 — **Personal Info sheet (`edit_profile.dart`) rewritten to Figma spec** on `feature/abhiCloude`:
  - Removed avatar + camera-picker block and Email field — sheet now shows only the 5 Figma fields (First Name, Last Name, Country of residence, Preferred Currency, Language) plus the Save button.
  - Re-enabled the Country dropdown (was commented out); selection now defaults to the user's saved country when available instead of always picking `countries.first`.
  - Field styling tokens: label 16/600/`#09090B`, input box bg `#F4F4F5`, radius 16, height 62, content padding 24/20; input text 16/500/`#09090B`; dropdown chevron `#1C274C` 24sp; 23px gap between fields.
  - Save button is now a custom 60-tall `#8E10FC` pill (radius 32, text 16/700/white), with `withOpacity(0.5)` in the disabled state per Figma — replacing the shared `Button` (50-tall, 25-radius) for this screen only.
  - Removed `dart:io` / `image_picker` imports and the `selectedImage`/`pickImage` plumbing now that avatar editing is gone.
- 2026-05-26 — **Profile page UI aligned with Figma spec** on `feature/abhiCloude`:
  - `lib/presentation/screens/profile/profile_page.dart` rewritten end-to-end against Figma frames 1171276434/35/36. Card bg `#FAFAFA`, hairline border `1px #F4F4F5`, radius 20; inner stat/icon boxes white with same hairline + radius 12.
  - Avatar now wears the 4px `#D9ADFF` ring (84×84 outer); name 20/600/`#09090B`; stat value 16/600/`#09090B`; stat label 14/400/`#3F3F46`.
  - Stats row uses 3 `Expanded` boxes with 4px gaps (Figma flex-grow), replacing the prior fixed `90.w` + `spaceBetween`.
  - Achievement title `#52525B` 16/600; badges 64×64 with 1px hairline (purple translucent bg removed).
  - Settings card: row gap unified to 20.h between items (was 12.h vertical padding = 24 between); text 16/400/`#3F3F46`; icon container white + 1px hairline; icon/arrow `#52525B`.
  - Replaced default `Switch` with `_FigmaSwitch` (57×32 `#E4E4E7` off track, primary on track, 24×24 white thumb, animated slide).
  - Dark mode preserved via per-token light/dark resolvers; functional surface (refresh, sheets, logout, all 8 rows) untouched.

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
- 2026-05-26 — **`GlobalAppBar` no longer turns gray when content scrolls underneath** on `feature/abhiCloude`:
  - `Common_header_withlogo.dart` — added `scrolledUnderElevation: 0` and `surfaceTintColor: Colors.transparent` to the `AppBar`. Without them, Material 3 applies a tinted surface overlay (and a 3pt elevation) once body content scrolls past the AppBar — that's what was turning the profile-page header from white to gray on scroll. Fix applies to every screen that uses `GlobalAppBar`.

- 2026-05-23 — **Chart-page Buy Yes/No now opens the quote view** on `feature/vandana_claude`:
  - `trade_details_page.dart` `_openNewTrade` — taps on the chart/info page's Buy Yes / Buy No buttons now open `TradePage` with `useDefaultAmount: true`, so the user lands directly on the quote view (shares, price, max payout, potential profit) instead of an empty amount input. Mirrors the home-screen swipe path.
  - Added the same readiness gate `HomeScreen._ensureReadyToTrade()` uses (purple `showLoader` while default amount is still fetching; red `showError` + open `DefaultSettingsPage` if loaded-but-zero). Imports `DefaultAmountProvider`, `DefaultSettingsPage`, `CustomSnackBar`.
  - TODO noted in the file: extract the gate to a shared helper to avoid duplicating the logic with HomeScreen.
- 2026-05-23 — **Layout polish (QA #7, #8, #9)** on `feature/vandana_claude`:
  - `wallet_history.dart` `_menuItem` — added `width: double.infinity`. The Container previously sized to its `Text` child, so the selected-row highlight only covered the label and left an empty strip on the right (QA #7).
  - `achivement_Sheet.dart` `gridDelegate` — `mainAxisSpacing` 20.h → 10.h. The 20.h vertical gap was disproportionate to the 6.w horizontal gap, producing a visibly empty band between badge rows (QA #8).
  - `profile_page.dart` — between-card SizedBoxes 20.h → 16.h (profile-summary↔achievements and achievements↔settings). Now matches the 16.w horizontal margin so the gaps form a consistent square grid instead of feeling top-heavy (QA #9). Top padding (20.h before first card) and bottom padding kept as-is.
- 2026-05-23 — **Swipe-on-PollCard race condition (QA #6)** on `feature/vandana_claude`:
  - `default_amount_provider.dart` — separated `_isFetching` from `_hasLoaded`. The previous version set `_hasLoaded = true` BEFORE awaiting the response, so during the request window `hasLoaded` lied. `_isFetching` now tracks in-flight state; `_hasLoaded` only flips after the response is parsed.
  - `HomeScreen.dart` `_ensureReadyToTrade()` — fixed the order and the null-handling. Was checking `defaultAmount == 0` first (which silently skipped `null`), then `!hasLoaded` (which never fired thanks to the optimistic flag above). Now checks `!hasLoaded || defaultAmount == null` first (shows purple `showLoader` snackbar "Loading your settings, please wait..."), then `defaultAmount <= 0` (shows red `showError` "Please set your default trade amount first" + opens DefaultSettingsPage).
  - `HomeScreen.dart` `onTap` — dropped the `_ensureReadyToTrade()` gate from the tap path. Tap opens `TradePage` with `useDefaultAmount: false` and the user types their own cost, so a missing default amount shouldn't block tapping. Only the swipe path (which pre-fills the cost) gates on the provider state.
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
