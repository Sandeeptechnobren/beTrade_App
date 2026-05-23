# Current Tasks

## In Progress

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
