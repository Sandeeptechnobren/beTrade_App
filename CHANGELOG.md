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
- 2026-05-26 — **Post-signup profile shows nothing without re-login** on `feature/vandana_claude`:
  - Root cause: `auth_service.dart` `completeSignup` returned `bool` and discarded the response body. The backend issues the FINAL session token at `/complete-profile` (the `/verify-otp/register` token from step 2 is only a limited "registration" token). Without capturing the new token, the user landed on MainScreen still holding the registration token, `/profile` silently 401'd, and the only way to see profile data was logout + re-login.
  - Fix: parse the `completeSignup` response; extract `data['token']` / `data['access_token']` (with fallback to nested `data['data']['token']`); persist via `LocalStorage.setToken()` then `DioClient.setToken()` (same disk-first ordering as `verifyOtp` / `verifyLoginOtp`). `completeSignup` still returns `bool` so no caller refactor needed.
- 2026-05-26 — **Play Store release readiness pass** on `feature/vandana_claude`:
  - **QA #14** placeholder text too dark — added `AppColors.hintTextDynamic` token (grey.shade400 in light, grey.shade500 in dark). Applied across `login_screen`, `OTP_step`, `newDeposit`, `new_Payment_method`, `explore_page`. Hints now read as hints in both themes.
  - **QA #15** dark mode inconsistencies — only 2 active static `AppColors.inputFieldBg` usages found (`wallet_history` border + `country_picker_sheet` spinner color). Both replaced with theme-aware variants (`borderDynamic` and `AppColors.primary` respectively).
  - **QA #16** navbar turns grey on scroll — root cause was Material 3 surface tinting bleeding into the unset `BottomNavigationBar.backgroundColor`. Added `AppColors.bottomNavBackgroundDynamic` token + `backgroundColor` + `elevation: 0` on `bottom_nav.dart`.
  - **Production logging hygiene** — created `lib/core/utils/logger.dart` (`AppLogger` facade with `d`/`i`/`w`/`e`/`dRedacted` levels gated by `kDebugMode`). Then redacted **23 sensitive log statements** across `auth_service.dart` (12× response/token dumps), `profile_service.dart` (full PII profile dump + response bodies), `wallet_service.dart` (4× balance/transaction body dumps), `trade_buy_service.dart` (1× response body). Status codes / error messages preserved; data bodies and field-level PII stripped.
  - **Scope discipline** — explicitly did NOT modify anything ranking-related (#5 deferred): the `Rankings` label in `bottom_nav.dart` lines 144 + 54 untouched, IndexedStack routing in `main_screen.dart` untouched, `info_chart_screen.dart` untouched.
- 2026-05-26 — **Production typography pass (QA #2)** on `feature/vandana_claude`:
  - `lib/core/theme/app_text_style.dart` — bumped three heading presets to align with Material 3 / Cred / PhonePe / Zomato production scale:
    - `heading`: **20 → 22sp** (screen titles, matches Material 3 `titleLarge`)
    - `headingWhite`: **20 → 22sp** (variant — kept consistent)
    - `headingWhitebig`: **22 → 26sp** (onboarding marketing copy, hero text)
  - Body (16), subHeading (18), small/smallGrey/smallNav (14), button (16), bodyBig (16), subHeadingBold (18) **left unchanged** — already at production-norm. `smallNav` doubles as the KYC form-label style ("Country", "Currency", "Language"), so shrinking it to 12sp (typical bottom-nav norm) would have shrunk form labels too — kept at 14sp.
  - No layout breakage expected: the 3 bumped presets are used in headers, screen titles, and onboarding hero text — all width-flexible containers. Analyzer: "No issues found!" Static code review showed no width-constrained Row siblings that would overflow.
- 2026-05-26 — **High-res avatars + logo refresh + avatar off-by-one bug** on `feature/vandana_claude`:
  - **QA #4 (avatars)** — replaced all 16 `assets/images/avt1 (1)..(16).png` files with designer-provided high-res versions (~30–56 KB each, was ~7–10 KB). All clear character portraits — mix of genders, ethnicities, styles (hijab, kimono, hoodies, etc.).
  - **QA #3 (in-app logo)** — replaced `assets/logo/IconLogo.png` and `assets/images/IconLogo.png` (143×176, used in headers and splash) with new `Frame 18.png` exported by designer. **Intentionally did NOT replace `assets/logo/app_icon.png`** (the launcher icon source) because the new file is 143×176 while current `app_icon.png` is 1024×1024 — replacing would have caused a blurry launcher on every device.
  - Latent off-by-one: `step_profile.dart:32` used `List.generate(16, (i) => "...avt1 ($i).png")` which generates `avt1 (0)`–`(15)`. But files are `avt1 (1)`–`(16)`. Result: `avt1 (0)` 404'd (broken first avatar) and `avt1 (16)` was never displayed. Changed to `(i + 1)` so all 16 designer avatars actually appear.
  - `Frame 5 1.png` (28×33 thumbnail variant) NOT applied — no widget consumes that size; saved for future use.
- 2026-05-23 — **PollCard share button now actually shares** on `feature/vandana_claude`:
  - Added `share_plus: ^10.1.4` dependency.
  - `HomeScreen.dart` `_shareTradeCard(trade)` — opens the OS share sheet (WhatsApp, Messages, Mail, etc.) with the trade description, category, and image URL. Wired into the previously-stubbed `CommonShareButton(onTap: () {})` on PollCard. No deep-link URL scheme yet — recipient sees text content only.
  - Other `CommonShareButton` stub at `info_chart_screen.dart:81` still TODO (not in scope for this commit).
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
