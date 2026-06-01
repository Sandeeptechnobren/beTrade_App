# Changelog
All notable changes to this project are documented here.
Format: [DATE] [AUTHOR] Description

## [Unreleased]

### Changed
- 2026-06-01 — **Flutter-side security, money-safety & resilience hardening** on `feature/challenge` (from the project challenges assessment; backend/server items are reported separately to those teams):
  - **Secure token storage (F1)** — bearer token moved from plaintext `SharedPreferences` to `flutter_secure_storage` (Keychain / Keystore) with an in-memory cache so `LocalStorage.getToken()` stays synchronous; any legacy plaintext token is migrated then wiped on first launch (`local_storage.dart`).
  - **Idempotency reuse (F3)** — buy / sell / deposit / withdraw now generate ONE idempotency key per logical order, hold it in state and reuse it on retries (reset on input change), so a re-tap after a timeout can't create a duplicate charge. New `core/utils/idempotency.dart`; `TradeBuyService.generateIdempotencyKey` delegates to it. Touched `buy_bottom_sheet.dart`, `sell_position_sheet.dart`, `newDeposit.dart`, `withdrawal.dart`.
  - **Money precision + validation (F2, F5)** — new `core/utils/money.dart` (safe parse, round-to-2dp, format, `validateAmount`). Deposit / withdraw / buy validate the amount (numeric, > 0, ≤ 2 decimals, min/max, balance cap on withdraw) with inline errors before any API call. (Integer minor-units on the wire remains a backend item — B4.)
  - **Cleartext off (F7)** — Android `usesCleartextTraffic` → `false`; iOS ATS already secure. Certificate pinning is a documented follow-up (needs the cert).
  - **Crash reporting (F10)** — `firebase_crashlytics` added; Flutter + uncaught async errors and `AppLogger.e` route to Crashlytics (collection off in debug) in `main.dart`. The Android Gradle Crashlytics plugin (symbol upload) is an optional follow-up.
  - **Connectivity + retry (F9)** — `RetryInterceptor` retries transient failures on idempotent GET/HEAD with backoff and surfaces a clear "no internet" message when offline (`connectivity_plus`); mutating calls are never auto-retried. `dio_client.dart` now reads `EnvConfig.baseUrl` and dropped its dead code.
  - **Structured logger (F16)** — new `core/utils/app_logger.dart` (levels + Bearer-token redaction + Crashlytics sink). Removed a raw `print(token)` leak in `home_service.dart`; money-service errors now flow through `AppLogger.e`.
  - **FCM payload hardening (F14)** — notification payload values coerced defensively; added a route whitelist (`_safeRoute`) so any future payload-driven navigation can only reach known screens.
  - **Rankings gated (F18)** — mock leaderboard now sits behind a documented `_useMockRankings` flag (behaviour unchanged; one-line switch before release).
  - **Tests (F6)** — removed the broken default-scaffold test; added unit tests for `Money` + `Idempotency` (12 tests). Added `mocktail` dev dep.
  - **Networking cleanup (F8)** — confirmed live code is Dio-only; removed the unused `http` dependency.
  - Verified: `flutter analyze` = 0 errors, `flutter test` = all pass. By request / scope: the simulated chart is left as-is (F4); session refresh (F11) and a deeper provider refactor (F12) are backend-dependent / deferred; `api_endpoint.dart` rename (F17) was already done upstream.
- 2026-05-27 — **PortfolioPage aligned with Figma spec** on `feature/abhiCloude`:
  - **Wallet card** — solid `#2E1065` background replaces the `splash.png` decoration. Header now uses 16/400/`#FAFAFA` "Available to trade" with a 20sp `#F8FAFC` eye icon; balance jumps to 40sp/600 with the currency code rendered as 16sp baseline-aligned suffix. The `···` menu chip shrunk to a 28×28 `#C178FF` circle. Deposit/Withdraw are now 52-tall pill buttons (radius 9999) with 8.w gap — Deposit `#8E10FC` / white text, Withdraw white / `#18181B` text, both 15.6sp/700.
  - **Tabs** — `RoundedTabIndicator` swapped for a custom `_FigmaTabIndicator` painter rendering a 47×6 rounded rectangle in `#3D006D` directly below the active label. Labels 16/600 (`#09090B` active, `#71717A` inactive).
  - **Open-position card** — full redesign to match `Frame 1171276423`: white background with 1px `#E4E4E7` border, 12-radius. Inside is the market question (16/400/`#09090B`) plus a `#F4F4F5` inner panel (radius 6, padding 12, gap 4) holding four label/value rows — `Entry Price`, `Prediction`, `Profit Earned`, `Shares` (each 14sp; labels 400/`#71717A`, values 500/`#71717A`; profit value flips to `#16A34A` green or `#DC2626` red by sign). Card footer is an outlined "Close position" pill (white bg, 1px border, radius 9999, height 44, text 16/500/`#18181B`) that opens `PositionDetailPage` — actual close-position API is a follow-up. The previous BUY YES/NO chip + Avg/Now subtitle + Value/PnL row were removed in favor of this layout.
  - Dropped the `splash.png` `DecorationImage`, the `rounded_tab_indicator.dart` import, and the now-unused `AppColors` import; removed the stale `hide DepositPage` clause on the withdrawal import.
- 2026-05-26 — **Both Google + Apple social buttons now shown on every platform** on `feature/abhiCloude`:
  - `login_screen.dart` + `signup_screen.dart` — removed the `if (Platform.isIOS)` wrap around the Apple half of the social-button row. Both buttons render on Android and iOS, matching the Figma. `dart:io` import dropped from both files (no longer needed).
  - `signin_provider.dart` — added a `SignInWithAppleNotSupportedException` catch in `signInWithApple()` so Android taps (which the package can't handle without `WebAuthenticationOptions`) surface a clear "Apple sign-in isn't available on this device. Please use another sign-in option." message instead of a generic error. To enable Apple on Android later, pass `WebAuthenticationOptions(clientId, redirectUri)` to `SignInWithApple.getAppleIDCredential` (comment in file).

### Added
- 2026-05-26 — **"Continue with Apple" sign-in wired end-to-end** on `feature/abhiCloude`:
  - `pubspec.yaml` — added `sign_in_with_apple: ^6.1.4`.
  - `ios/Runner/Runner.entitlements` (new) — declares `com.apple.developer.applesignin = [Default]`. Pair with Xcode's "Sign In with Apple" capability on the Runner target so debug+release builds pick it up.
  - `lib/data/services/apple_auth_service.dart` (new) — wraps `SignInWithApple.getAppleIDCredential` and returns a typed `AppleAuthCredential` record. Heavily commented re: why email/name are null on second login and why Firebase Auth is intentionally not used.
  - `lib/data/services/notification_services.dart` — added `static Future<String?> getFcmToken()` helper so auth flows can fetch the current FCM token without touching `FirebaseMessaging` directly.
  - `lib/data/services/auth_service.dart` — added `socialLogin({provider, identityToken, authorizationCode, email?, firstName?, lastName?})` instance method. Mirrors `verifyLoginOtp` for token persistence (`LocalStorage.setToken` → `DioClient.setToken`) and `doc_upload_status` parsing. Backend payload: `{provider, identity_token, authorization_code, fcm_token, device_type, email?, first_name?, last_name?}` → `POST /auth/apple`.
  - `lib/core/config/api_endpoint.dart` — added `socialLogin` endpoint constant (`/auth/apple`).
  - `lib/data/provider/signin_provider.dart` — added `signInWithApple()` on `AuthProvider`. Orchestrates Apple sheet → backend, maps `SignInWithAppleAuthorizationException.canceled` to a silent `{cancelled: true}` response (no snackbar), maps other Apple/Dio/unknown errors to user-friendly messages.
  - `lib/presentation/screens/signin/login_screen.dart` — Apple `OutlinedButton.onPressed` now calls `_handleAppleSignIn` (re-entry guarded via existing `_isLoading`). On success: `Navigator.pushAndRemoveUntil` to `MainScreen` (mirrors OTP-verified login). Apple button + its leading spacer wrapped in `if (Platform.isIOS)` so Android gets a full-width Google button.
  - `lib/presentation/screens/splash/signup_screen.dart` — same wiring inside `_buildSocialAuthButtons`; on success skips OTP/gender/name/profile steps and lands the user on `MainScreen`.
  - Backend contract: existing `/verify-otp/login` envelope reused — `{status|success, token|access_token, user.doc_upload_status, message}`. **TODO(backend):** confirm `/auth/apple` path and that the response shape matches.

- 2026-05-26 — **Continue with Google / Apple buttons on signup phone step** on `feature/abhiCloude`:
  - `authlayout.dart` — added optional `Widget? bottomExtra` slot rendered inside the bottom bar's `SafeArea`, directly under the Continue button (12.h gap). Default null preserves prior behavior for every other call site.
  - `signup_screen.dart` — when `step == 1` (StepPhone), passes a `_buildSocialAuthButtons` row to `bottomExtra`: two equal-width `OutlinedButton`s ("Continue with [Google]" / "Continue with [Apple]") mirroring the existing `LoginScreen` styling (50.h height, 25.r pill, `borderDynamic` outline, `buttonSecondaryDynamic` bg). `onPressed` are stubs — real OAuth wiring isn't in this layout pass.
  - Other signup steps (OTP, gender, name, profile) unaffected — `bottomExtra` resolves to null.

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
