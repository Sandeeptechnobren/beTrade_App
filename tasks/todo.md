# Current Tasks

## In Progress

### 2026-06-03 — Complete Google Sign-In (Android + iOS)

Pulled `c1dbf82` (Abhishek's popup-only Google integration: opens chooser, gets idToken, stops — no backend exchange). Standardizing on **betrade-new** Firebase project (Abhishek extended it with OAuth clients; FCM unaffected). Discarding the `vibetrade-6b4af` file.

Backend `/login-with-google`, `/profile/attach-phone`, `/profile/verify-attach-phone`, and the `google_id` column are all live + migrated on the server. Only the `GOOGLE_OAUTH_*` env vars are missing (0 set).

Built via 3 parallel agents against a shared contract (data layer / new screen / screen-wiring — disjoint file sets), then verified the seams with `flutter analyze` (0 errors).

| # | File / target | Change | Status |
|---|---------------|--------|--------|
| 1 | `lib/core/config/api_endpoint.dart` | add `loginWithGoogle`, `attachPhone`, `verifyAttachPhone` endpoints | ✅ Done |
| 2 | `lib/data/services/auth_service.dart` | add `loginWithGoogle(idToken)` (POST {id_token}, store token+doc_status), `attachPhone(phone)`, `verifyAttachPhone(phone,otp)` | ✅ Done |
| 3 | `lib/data/provider/signin_provider.dart` | rewrite `signInWithGoogle()` → call backend, best-effort FCM save, return {success,cancelled,message,needs_phone,email,doc_status}; add attachPhone/verifyAttachPhone | ✅ Done |
| 4 | `lib/presentation/screens/signin/attach_phone_screen.dart` (NEW) | phone → OTP → verify → MainScreen (applies the OTP-bug-fix patterns) | ✅ Done |
| 5 | `lib/presentation/screens/signin/login_screen.dart` | `_handleGoogleSignIn` → needs_phone ? AttachPhone : MainScreen | ✅ Done |
| 6 | `lib/presentation/screens/splash/signup_screen.dart` | same navigation (+ removed now-dead `_showSuccess`) | ✅ Done |
| 7 | `lib/presentation/auth/auth_bottom_sheet.dart` | same navigation | ✅ Done |
| 8 | `ios/Runner/Info.plist` | CFBundleURLTypes = REVERSED_CLIENT_ID | ⏭️ Deferred (iOS round — Android first per user) |
| 9 | server `.env` | set `GOOGLE_OAUTH_WEB_CLIENT_ID` (…o3mkqr4d1…) + `ANDROID_CLIENT_ID` (…f3ua65m1…); config:cache; apache restart | ✅ Done + verified (endpoint returns 401 "Invalid Google sign-in token" for dummy token = config gate passes) |

**⚠ BLOCKING — user action (Google Cloud Console):** add debug SHA-1 `e4c3a212aca301ad78b695072f91ddae71bdd76a` to the **betrade-new** Android OAuth client (package `com.build.betrade`). Takes effect for the already-installed app (no rebuild needed). Without it, the native chooser throws `ApiException: 10` (DEVELOPER_ERROR).

iOS env (`GOOGLE_OAUTH_IOS_CLIENT_ID` = …27nsvg4v…) + Info.plist URL scheme to be done together in the iOS round.



### 2026-06-02 — Client-reported OTP bugs (sign-in flow)

Two bugs raised by client during testing:
1. **"After entering pin the button is not responsive"** — login OTP screen `isOtpComplete` state can desync from the visible cells; button at `otp_screen.dart:412` is gated on `isOtpComplete` and goes `onPressed: null`. Signup OTP has a related issue: failed verify nukes `isOtpValid` but leaves the 6 cells filled, so user sees full input + disabled button.
2. **"When OTP fails to send it doesn't issue a resend"** — login screen failed `sendLoginOtp` shows only a transient snackbar; the OTP screen (where Resend lives) is never reached. AND when OTP screen IS reached, its `_resendOtp` ignores `status:false` from the API and runs the success path anyway, locking the user for another 30 s on a silently-failed resend.

| # | File | Change | Status |
|---|------|--------|--------|
| 1 | `signin/otp_screen.dart` | Button always tappable when `!_isVerifying`; `_verifyOtp` handles "incomplete OTP" message internally | ✅ Done |
| 2 | `signin/otp_screen.dart` | `_resendOtp` inspects `{status,message}`; only restart cooldown on success; keep Resend tappable on failure | ✅ Done |
| 3 | `signin/otp_screen.dart` | `_showMessage` actually respects `isError` (was always calling `showError`) | ✅ Done |
| 4 | `signin/login_screen.dart` | Persistent inline error chip below phone row when send fails; clear on type; button label switches to "Try again" | ✅ Done |
| 5 | `splash/signup_screen.dart` | On failed verify, stop calling `provider.setOtp("")` + `isOtpValid=false` — leave the user's 6 digits visible so they can correct one cell | ✅ Done |

Backend "fire-and-forget" `dispatchAfterResponse` for WhApi is by design (Phase 2 server hardening would be a separate task). Client-side mitigation = the resend + retry UX above.

Verified: `flutter analyze` on the 3 edited files = 0 errors, no new warnings. Awaiting APK build + user verification on device.

---

### 2026-06-01 — Flutter-side challenge fixes (branch `feature/challenge`)

Scope: fix only the **Flutter-side** items from the challenges PDF (F1–F18). Backend (B*) / Server (S*) reported to those teams. No commit/push — left for user verification.

| # | Item | Status | Notes |
|---|------|--------|-------|
| F1 | Plaintext token | ✅ Done | `flutter_secure_storage` + sync cache + legacy migration |
| F2 | Floating-point money | ✅ Done (client) | `core/utils/money.dart`; minor-units = backend B4 |
| F3 | Idempotency per tap | ✅ Done | one key/order reused on retry; buy/sell/deposit/withdraw |
| F4 | Simulated chart | ⏭️ Skipped | user asked to leave the chart as-is |
| F5 | Money input validation | ✅ Done | min/max/decimals/balance + inline errors |
| F6 | Broken tests | ✅ Done | scaffold removed; 12 unit tests (Money, Idempotency) green |
| F7 | Cleartext traffic | ✅ Done | Android `false`; iOS ATS already secure; pinning = follow-up |
| F8 | Two HTTP clients | ✅ Done | live code Dio-only; removed unused `http` dep |
| F9 | No retry/offline | ✅ Done | `RetryInterceptor` + `connectivity_plus` offline message |
| F10 | No crash reporting | ✅ Done | `firebase_crashlytics` wired; Gradle symbol plugin = follow-up |
| F11 | Abrupt session expiry | ⏳ Backend-dep | poll+dialog OK on client; true refresh needs backend B6 |
| F12 | Provider sprawl | ⏳ Deferred | existing pattern reasonable; deep refactor = risk > value |
| F13 | Pagination | ✅ Already present | HomeScreen scroll → `loadMore()` already wired |
| F14 | FCM payload trust | ✅ Done | safe coercion + route whitelist |
| F16 | print logging | ✅ Done (core) | `app_logger.dart` + redaction; killed `print(token)` leak; full migration = mechanical follow-up |
| F17 | Filename typo / dead code | ✅ Rename already done | `api_endpoint.dart` already single-dot; commented dead-code = cosmetic follow-up |
| F18 | Rankings stub | ✅ Done | mock behind documented `_useMockRankings` flag |

Verified: `flutter analyze` = 0 errors; `flutter test` = all pass. New deps: `flutter_secure_storage`, `connectivity_plus`, `firebase_crashlytics`, `mocktail` (dev); removed `http`.

---

### 2026-05-23 — Login + OTP critical bug fixes (COMPLETED — see Completed section)

Status: implemented & committed. Verification pending APK smoke test on device.

Moved to Completed below.

---

### Original plan (kept for reference until smoke-tested)

#### 2026-05-23 — Login + OTP critical bug fixes (was: awaiting APPROVED)

**Branch:** `feature/claude/docs-refresh`. **Scope:** 7 fixes across 5 files. No application code touched until user types `APPROVED`.

| # | File | Bug | Fix | Ripple |
|---|------|-----|-----|--------|
| 1 | `lib/data/services/auth_service.dart` lines 138-149 & 393-399 | `DioClient.setToken` (sync) runs before `await LocalStorage.setToken` (async). If app crashes between: token in memory but not on disk → user lands in inconsistent state on next launch. | Reverse order: `await LocalStorage.setToken(token);` first, `DioClient.setToken(token);` second. | None — defensive reordering only. |
| 2 | `lib/data/services/local_storage.dart:15` + `auth_service.dart:456` | Bearer token & FCM token printed to OS log stream via `print()`. Observable through `adb logcat`. | Delete the two `print(token);` lines. | None. |
| 3 | `lib/presentation/screens/profile/profile_page.dart:42-76` | If `AuthService.logout()` returns false (token already revoked server-side OR network drop), local token is **not** cleared. `DioClient.removeToken()` is **never** called anywhere, so the singleton Dio retains the stale `Authorization` header across logout — `multipartInstance` then leaks it into file uploads. | Wrap server-side logout in try/catch/finally. Always run `LocalStorage.clearToken()` + `DioClient.removeToken()` + navigate to `AuthScreen` in `finally`, regardless of server result. | Logout becomes resilient to backend unreachable. Stale token can no longer leak into multipart uploads. After logout, any next API call gets 401 (correct). |
| 4 | `lib/presentation/screens/signin/otp_screen.dart` lines 201-226 + TextField at 257-310, and `OTP_step.dart` lines 102-133 + TextField | Each cell has `maxLength: 1`, so pasting "123456" truncates to a single char per box. Users can't paste an OTP from SMS. | Remove `maxLength: 1`. Add `LengthLimitingTextInputFormatter(otpLength)` (caps at 6 but allows multi-char paste). In `_onOtpChanged`: if `value.length > 1` → sanitise digits, distribute across all cells from index 0, move focus to next empty cell (or unfocus if all filled). Keep single-char typing path unchanged. | Single-char typing, backspace, focus advance all keep working. Same change applied to BOTH login-OTP and signup-OTP screens (they share the bug). Manual smoke test needed for paste + type + backspace. |
| 5 | `lib/presentation/screens/signin/otp_screen.dart:142` | Wrong-OTP path calls `_clearOtpFields()` → wipes all 6 cells. User can't fix a one-digit typo. | Remove the `_clearOtpFields();` call from the verify-failure branch. Keep clear-on-resend (line 166). | None. UX improvement only. |
| 6 | `lib/presentation/screens/signin/login_screen.dart` lines 27, 123-166, 197, 326-335 | Three interlocking bugs: (a) `_isLoading` field declared but **never set** → CircularProgressIndicator block at 326-331 is unreachable dead code. (b) Button uses `loginProvider.isLoading` for disable gate, but login calls `AuthProvider.sendOtp` (not `LoginProvider.sendOtp`) → `loginProvider.isLoading` stays `false` → button never disabled. (c) No internal `_handleContinue` guard → rapid taps fire duplicate OTP-send requests. | Add `if (_isLoading) return;` synchronously at top of `_handleContinue`. Wrap in `setState(() => _isLoading = true); try { … } finally { setState(() => _isLoading = false); }`. Button binds to `_handleContinue` directly. Drop now-pointless `context.watch<LoginProvider>()` at line 197 and its `isLoading` reference at line 334. Add try/catch around `provider.sendOtp` (no catch today → network errors leak as raw exception). | `LoginProvider` class stays registered globally in `main.dart` (it's still a registered provider) — only the watch in this screen is removed. The flow now has a single source of truth (`_isLoading`) for the loader and the disable gate. **The circular loader now actually appears** — that's what the user asked for. |
| 7 | `lib/presentation/screens/signin/login_screen.dart` `_handleContinue` (no catch today) and `otp_screen.dart` `_verifyOtp` (catches but generic message) | On `DioException` (network down, DNS fail), raw exception text could leak to UI or get silently swallowed. No distinction between "no internet" vs "server rejected". | In login `_handleContinue`: wrap in try/catch. On `DioException` → `"Network error. Please check your connection."`. On `Map result with success: false` → show backend `message` (already mostly there). In OTP `_verifyOtp`: distinguish network failure ("Check your connection") from backend rejection (use backend `message`). | Consistent user-facing error UX. No raw stack traces in snackbars. |

#### Out of scope for this approval cycle

Deferred (acknowledged in the bug-hunt report, not addressed here):
- KYC camera hard-coded `isFront: false` (`verify_account.dart:494`) — KYC scope, not login.
- Unifying the two divergent OTP UIs (`otp_screen.dart` vs `OTP_step.dart`) — major refactor.
- `_isDialogShowing` flag never reset in `main_screen.dart` — session-lifecycle scope.
- 300 s polling ignores app backgrounding — needs `WidgetsBindingObserver`.
- `CountryModel` / `ChartData` lack defensive `fromJson` defaults — model audit.
- Wallet deposit/withdraw forms have no API wiring — feature scope.
- Stub `onPressed: () {}` buttons across the app — feature scope.
- ~900 lines of commented-out legacy code — cleanup PR.

#### Complexity
Medium. ~150 lines changed across 5 files. No API contract changes. No DB. No new deps.

#### Manual smoke test plan (since `flutter test` is broken)
1. **Token persistence**: log in successfully, force-kill app immediately, relaunch → should be either fully logged in or fully logged out, never an inconsistent in-between.
2. **Logout resilience**: log in, turn off WiFi, tap Logout → still navigates to AuthScreen, local token cleared.
3. **OTP paste**: send OTP, copy 6 digits to clipboard, long-press the first OTP cell and paste → all 6 cells fill, Confirm enables.
4. **OTP wrong code**: enter wrong OTP, tap Confirm → see "Invalid OTP" error, **cells still hold your input** (not wiped).
5. **Login loader**: tap Continue → spinner appears, button disabled, rapid double-tap fires only **one** sendOtp.
6. **Login network failure**: airplane mode → tap Continue → "Network error. Please check your connection." snackbar, button re-enables.
7. **Token log audit**: `adb logcat | grep -E "Bearer|token"` during login → no token value in output.

#### Files I will modify (5)
1. `lib/data/services/auth_service.dart`
2. `lib/data/services/local_storage.dart`
3. `lib/presentation/screens/profile/profile_page.dart`
4. `lib/presentation/screens/signin/login_screen.dart`
5. `lib/presentation/screens/signin/otp_screen.dart`
6. `lib/presentation/screens/splash/signup_steps_pages/OTP_step.dart`

(actually 6, plus possibly a small import update — no other files touched)

## Planned

## Planned

### Trade Details screen — backend gaps (hardcoded fallbacks today)

The new [TradeDetailsPage](../lib/presentation/screens/trade/trade_details_page.dart) (pushed when the
user taps the title card on the trade-detail bottom sheet) renders
several values that should come from the API. Until the backend
confirms field names / wires the data, the UI shows hardcoded
fallbacks defined inline in [trade_details_page.dart](../lib/presentation/screens/trade/trade_details_page.dart).

| Field                | UI shows when null      | Expected backend key (best-guess)                       |
|----------------------|-------------------------|---------------------------------------------------------|
| Current Price        | "12.40 GHS per share"   | `current_price_per_share` — already returned, just rendered |
| Market Status        | "Open"                  | `market_status` OR `status`                             |
| Total Volume         | "410,250 GHS"           | `total_volume_ghs` OR `total_volume`                    |
| Liquidity            | "92,000 GHS"            | `liquidity_ghs` OR `liquidity`                          |
| Closes On            | "31/12/2026 • 11:59PM ET" | `closes_at` OR `end_date`                             |
| Resolution Source    | (~5-line hardcoded blurb) | `resolution_source`                                   |

[TradeDetailModel](../lib/data/model/trade_detail_model.dart) accepts both alias names with defensive defaults so
backend can ship either. Once the canonical name is locked, prune the
secondary alias from `fromJson`.

### Chart tab — needs `/trade/{uuid}/chart` wired

Currently the chart tab in [TradeDetailsPage](../lib/presentation/screens/trade/trade_details_page.dart) renders a
hardcoded series of 14 sample points. Backend endpoint
[`ApiEndpoints.tradeChart(uuid)`](../lib/core/config/api_endpoint.dart) exists but is never called.

To wire:
1. Confirm `/trade/{uuid}/chart` response shape with backend (likely
   `{ data: [{ time: ..., value: ... }, ...] }` matching the existing
   [`ChartData`](../lib/data/model/graph_model.dart) model in `graph_model.dart`).
2. Add `TradeChartService.getChart(uuid, range)` static method.
3. Replace the hardcoded `spots` list in `_chart()` with fetched data.
4. Wire the `_selectedRange` state ('1D' / '1W' / '1M' / '1Y' / 'MAX')
   so changing the range re-fetches with a `range=` query param.
5. Replace the hardcoded "20% ▼" 24h-delta badge with a real computed
   delta from the chart data.

## Completed

### 2026-05-23 — Layout polish (QA #7, #8, #9)
- **QA #7** — `wallet_history.dart` `_menuItem`: added `width: double.infinity` so the selected-row highlight spans the full menu width (was shrinking to fit the label).
- **QA #8** — `achivement_Sheet.dart` `gridDelegate.mainAxisSpacing`: 20.h → 10.h. Rows now sit closer, proportional to the 6.w `crossAxisSpacing`.
- **QA #9** — `profile_page.dart` between-card spacing: 20.h → 16.h for both card gaps (profile↔achievements, achievements↔settings). Matches the 16.w horizontal margin for a consistent rhythm.

Analyzer: 0 new issues. Manual smoke test pending APK build.

### 2026-05-23 — Swipe-on-PollCard race fix (QA #6)
Race condition between user swiping a PollCard and `DefaultAmountProvider.loadFromBackend()` completing. Provider was setting `_hasLoaded = true` optimistically before the await, so `_ensureReadyToTrade()` would falsely return true on a still-null amount, then TradePage would immediately pop and open DefaultSettingsPage — user perceived this as "swipe doesn't work".

Three fixes:
1. `default_amount_provider.dart` — separated `_isFetching` (in-flight) from `_hasLoaded` (response parsed). `_hasLoaded` only set after a successful fetch.
2. `HomeScreen.dart` `_ensureReadyToTrade()` — handle null explicitly (was `null == 0` → false → skipped), use `CustomSnackBar.showLoader` for the still-loading case and `CustomSnackBar.showError` for the user-has-no-default case with clear messages ("Loading your settings, please wait..." / "Please set your default trade amount first").
3. `HomeScreen.dart` `onTap` — removed the `_ensureReadyToTrade()` gate. Tap path doesn't pre-fill from default amount, so it shouldn't block on missing default.

Analyzer: 0 new issues. Manual smoke test pending APK build.

### 2026-05-23 — Trading UX critical bugs (4 fixes from QA report)
- **QA #1 + #13** — `lib/core/animations/success_animation.dart`: after signup, the SuccessScreen was navigating to AuthScreen (dumping the user back at login). Fixed to navigate to MainScreen with `showWelcomePopup: true` + `docUploadStatus` from LocalStorage. KYC banner now appears immediately after signup, satisfying both bugs.
- **QA #11** — `lib/presentation/screens/trade/trade_page.dart` `selectQuickAmount` (renamed from `addQuickAmount`): chip taps now **replace** the amount instead of adding. Tapping 10 then 20 → 20 GHS (was 30).
- **QA #10** — same file, quick-amount chip Row: chips visually reflect selection state with `AnimatedContainer` (filled purple + white text when matched).
- **QA #12** — `lib/presentation/screens/trade/trade_details_page.dart`: added Buy Yes / Buy No bottomNavigationBar. Taps close the details sheet and reopen `TradePage` (new trade modal) with the chosen outcome pre-selected.
- Analyzer: "No issues found!" on all 3 modified files. Manual smoke test pending APK build (build environment hitting cross-drive Kotlin incremental cache bug — see Build Issues below).

### 2026-05-23 — Claude Code documentation layer refresh
Refreshed every doc-layer file with current audit findings:
- Root `CLAUDE.md` rewritten to 124 lines (under the 150-line budget), 17 sections per the project spec, Flutter-adapted security rules.
- All 13 subdirectory `CLAUDE.md` files rewritten (28–36 lines each, under the 80-line budget), with corrected counts (~14 providers, ~13 models, ~16 services) and the token-polling interval fixed at 300 s (was incorrectly documented as 10 s in earlier subdir docs but the actual code in `lib/presentation/screens/main_screen.dart:58` uses 300 s).
- `docs/CODEBASE_AUDIT.md`, `docs/ARCHITECTURE.md`, `docs/PATTERNS.md` rewritten from a fresh three-agent investigation.
- 15 slash commands + the `doc-updater` subagent rewritten verbatim from the project template.
- `.claude/settings.json` Bash permissions adapted for Flutter (replaced `npm`/`docker`/`pg_dump`/`playwright` with `flutter`/`dart`/`pod`/`./gradlew`/`adb`/`firebase`/`flutterfire`) and gained Write/Edit denies for `.env`, keystores, Firebase service files.
- Pre-existing maintainer content in `tasks/todo.md`, `tasks/lessons.md`, `CHANGELOG.md`, `docs/ACCESS.md`, `docs/SSH_CONFIG.md`, `.claudeignore` preserved — they were already supersets of the provided templates.
- Committed to a new feature branch (`feature/claude/docs-refresh`); no application code touched.

### 2026-05-05 — OTP migration via `pinput`
Migrated to `pinput` (^5.0.0) with custom themes. Reverted later in
favor of pre-today TextField-based code per user request.

### 2026-05-05 — Phase 0 + Phase 2.1-2.5 (`b7910c2`)
Default-amount-0 redirect, idempotency on swipe-buy, typed DTOs,
TradeDetailProvider, server LMSR quote in TradePage, server-side
pagination. See `tasks/roadmap.md`.

### 2026-05-05 — Inline error UI on swipe-buy (`fb1c571`)
Replaced red snackbar with inline `_buyError` widget in the swipe
quote dialog. *(Now superseded — the swipe quote dialog itself is
removed in the next commit, and the same error path is delivered by
`BuyBottomSheet._buyError` since the swipe now opens `TradePage`.)*

### 2026-05-05 — Swipe → bottom sheet, Trade Details page (uncommitted)
- `_handleSwipe` on `PollCard` now opens the same `TradePage` bottom
  sheet as a card tap (with `initialOutcome: 'yes' | 'no'` based on
  swipe direction). Removed `_showQuotePopup` /
  `_showTradeSuccessPopup` / `_formatBuyError` / `_quoteRow` /
  `_formatNum` / `isSending` / `_isPlacingOrder` / `_buyError` from
  `_PollCardState` (~370 lines of dead code purged) plus 4 unused
  imports (`buy_response`, `quote_model`, `home_service`,
  `trade_buy_service`, `purple_button`).
- New `TradeDetailsPage` ([trade_details_page.dart](../lib/presentation/screens/trade/trade_details_page.dart)) pushed when
  user taps the title card in `TradePage`. Two tabs:
    - **Info** — Title card, Market Activity rows (current price,
      status, volume, liquidity, closes-on), Resolution Source.
    - **Chart** — Chance %, time-range chips, line chart (placeholder
      data — see "Chart tab — needs wiring" above).
- `TradeDetailModel` extended with optional `marketStatus`,
  `totalVolumeGhs`, `liquidityGhs`, `closesAt`, `resolutionSource`
  fields (defensive defaults; UI falls back to hardcoded values when
  null).
- `TradePage` accepts new `initialOutcome` ctor param and wraps the
  title container in a `GestureDetector` that pushes the new Details
  page.

### Side note — `HomeService` is now unused

After the swipe-to-bottomsheet refactor, [home_service.dart](../lib/data/services/home_service.dart) has
no callers. The file (and its associated `BuyResponse` /
`QuoteResponse` returns from the swipe path) is dead code on this
branch. Leaving in place for now per "don't change unrelated logic" —
flag for removal in a future cleanup pass.
