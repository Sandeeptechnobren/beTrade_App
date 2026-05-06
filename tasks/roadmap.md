# BeTrade — What's Next

Updated 2026-05-05 after merge commit `c32ddf3` (restored OTP to pre-today
state, dropped `pinput`, merged `48f447e` from main) **plus** Phase 0 + 2.1
through 2.5 implementation in this session. Phases ordered by **risk
reduction first**, then user-visible value, then polish.

---

## ✅ DONE this session

### Conflict resolution
- OTP merge conflict resolved. `otp_screen.dart` and `pubspec.yaml`
  restored to merge-base (`8a6dfff`). `pinput` removed entirely from this
  branch. Merge commit: `c32ddf3`.

### Phase 0 (the default-amount-0 redirect)
- **0.1 — `_ensureReadyToTrade()` helper** added to
  [HomeScreen.dart:421](../lib/presentation/screens/homeScreen/HomeScreen.dart). Both swipe and tap on a `PollCard` now
  route the user to `DefaultSettingsPage` (via `CommonBottomSheet`) when
  `DefaultAmountProvider.defaultAmount <= 0`. Loading-state warning
  preserved for the brief window before the backend fetch resolves.

### Phase 2 — Trade flow hardening
- **2.1 — `idempotency_key` on the swipe-buy path.**
  [HomeService.buyTrade](../lib/data/services/home_service.dart) now requires
  `idempotencyKey`; HomeScreen generates a fresh
  `TradeBuyService.generateIdempotencyKey()` per Trade tap. Eliminates
  the swipe-path double-charge risk.
- **2.2 — Typed DTOs.** Added five model files under `lib/data/model/`:
  - `trade_detail_model.dart` (`TradeDetailModel`)
  - `quote_model.dart` (`QuoteModel`)
  - `order_model.dart` (`OrderModel`)
  - `buy_response.dart` (`BuyResponse` — wraps success/code/message/order/quote/walletBalance)
  - `quote_response.dart` (`QuoteResponse` — wraps success/code/message/quote)

  Migrated callers:
  - [TradeDetailService.getTradeDetail](../lib/data/services/trade_details_service.dart) → `Future<TradeDetailModel?>`
  - [TradeQuoteService.quote](../lib/data/services/trade_quote_service.dart) → `Future<QuoteModel?>`
  - [TradeBuyService.buy](../lib/data/services/trade_buy_service.dart) → `Future<BuyResponse>`
  - [HomeService.getQuote](../lib/data/services/home_service.dart) → `Future<QuoteResponse>`
  - [HomeService.buyTrade](../lib/data/services/home_service.dart) → `Future<BuyResponse>`
  - [BuyBottomSheet](../lib/presentation/widget/buy_bottom_sheet.dart) — uses `QuoteModel` + `BuyResponse`
  - [TradePage](../lib/presentation/screens/trade/trade_page.dart) — uses `TradeDetailModel`
  - [HomeScreen](../lib/presentation/screens/homeScreen/HomeScreen.dart) `_showQuotePopup` / `_showTradeSuccessPopup` — typed parameters
- **2.3 — `TradeDetailProvider` created** at [trade_detail_provider.dart](../lib/data/provider/trade_detail_provider.dart),
  registered in [main.dart](../lib/main.dart). TradePage now consumes provider state
  (`context.watch<TradeDetailProvider>()`) instead of fetching the
  detail directly in `initState`. Race protection via `_currentUuid`
  tracking, dispose-safe `_safeNotify`. `_openBuySheet` refresh now
  routes through the provider too.
- **2.4 — Server LMSR quote replaces local price math** in TradePage:
  - 400 ms debounced `TradeQuoteService.quote()` triggered by amount
    change, quick-amount chip, or Yes/No toggle.
  - Request-ID guard drops stale responses if the user changes inputs
    mid-fetch.
  - Build prefers `_serverQuote.{shares, avgPricePerShare, maxPayoutGhs,
    potentialProfitGhs}`; falls back to a naive local estimate while a
    quote is pending or amount is 0.
  - Bonus: added a `dispose()` to TradePage (timer + amount controller —
    closes a pre-existing `TextEditingController` leak).
- **2.5 — Server-side pagination.** [TradeService.getTrades](../lib/data/services/trade_service.dart) now takes
  `{int page = 1}`. [TradeProvider.loadMore](../lib/data/provider/trade_provider.dart) is now
  `Future<void>` and actually fetches the next server page,
  appending to `_allTrades`. `hasMore` is now driven by an empty page
  response from the server, not by client-side slicing exhaustion.
  `_applyPagination` simplified (server already paginates the source).

---

## 🚧 BLOCKED / OPEN in Phase 2

- **2.6 — Real vote bars + trade counts.** Still hard-coded "3975 trades"
  and 67/33 split in [HomeScreen.dart:879-900](../lib/presentation/screens/homeScreen/HomeScreen.dart). **Blocked on backend
  coordination** — no field names exist in the codebase for `trade_count`
  / `yes_price` / `no_price` / similar. Two paths forward:
  1. Confirm backend `/trade/list` response shape with the API team, then
     extend `TradeModel.fromJson` to parse the real fields, and bind
     PollCard to them.
  2. If backend won't add these soon, replace the hard-coded literals
     with a neutral placeholder (e.g. blank counter, 50/50 bars) so the
     UI stops lying to users.

---

## Phase 1 — Pre-release hardening (release blockers)

1. Replace the debug keystore for release Android builds.
2. Move auth token to `flutter_secure_storage` (away from plain
   `SharedPreferences`).
3. Remove `android:usesCleartextTraffic="true"`.
4. HTTPS audit (mostly done — `EnvConfig.baseUrl` is the single env URL).
5. **First real test pass.** Suggested floor of 5:
   - OTP entry → verify
   - Trade list pagination (server-side now)
   - Quote → buy success
   - Quote → buy `INSUFFICIENT_FUNDS` typed-error
   - Token persistence + clear-on-401
6. Wire CI (Codemagic config exists on a feature branch).

---

## Phase 3 — Code health

1. Delete the giant commented-out blocks: `otp_screen.dart` (1–382),
   `HomeScreen.dart::PollCard` (986–1295), `trade_provider.dart` (1–95),
   `step_profile.dart` (~72%), `trade_filter_bottom_sheet.dart` (~72%),
   `dio_client.dart` (1–20), `main.dart` (129–173).
2. De-dup `TradeService.getTrades()` and `getAllTrades()` — same
   endpoint, same payload.
3. Pick one HTTP client (`http` or `dio`).
4. Migrate `withOpacity()` → `.withValues(alpha:)` (analyzer reports ~50+
   call sites across the project).
5. Replicate `_isDisposed` + `_safeNotifyListeners` pattern from
   `CountryProvider`/`CategoryProvider`/`TradeDetailProvider` (just
   added) to the other providers.
6. Fix file-name inconsistencies (`HomeScreen.dart`, `Payment_method.dart`,
   `OTP_step.dart`, `Gender_step.dart`, `stepPhone.dart`, `newDeposit.dart`,
   `step_heder.dart`, `achivement_Sheet.dart`, `step_indecator.dart`,
   `theam_provider.dart`, `signIn_provider.dart`, `signUp_provider.dart`,
   `profile_Detail_Screen.dart`, `Common_header_withlogo.dart`).
7. Remove debug `print(response.data)` in [wallet_service.dart:30](../lib/data/services/wallet_service.dart) (added by `48f447e`).
8. Remove unused `signup_screen.dart` import in [main.dart:7](../lib/main.dart) (added by `48f447e`).
9. Wire the no-op buttons (or delete them):
   - [login_screen.dart:356, 394](../lib/presentation/screens/signin/login_screen.dart) — two `onPressed: () {}`
   - [info_chart_screen.dart:98, 113](../lib/presentation/screens/profile/info_chart_screen.dart) — two `onPressed: () {}`
   - [deposit_success.dart:40](../lib/presentation/widget/deposit_success.dart)
   - Every `CommonShareButton(onTap: () {})` (4 occurrences) — share
     button is dead.
10. Remove `_fixAvatar` workaround in `ProfileModel` once backend stops
    double-prefixing `https://`.
11. Refresh stale CLAUDE.md docs ("Buy Yes/No buttons are no-op" is no
    longer true; "TradeService is http-based" was never true; the
    pinput migration noted on main is reverted on this branch).

---

## Phase 4 — Feature completeness

1. **Deep linking.** `TradePage` opens as a `DraggableScrollableSheet` —
   no route, no URL, no back-stack. Switch to a real route.
2. **Real chart on trade detail.** `ApiEndpoints.tradeChart(uuid)` exists
   but is never called from `TradePage`.
3. **Push notifications wiring check.** Confirm topic/token reaches
   backend.
4. **Real card image** instead of `assets/images/splash.png` overlay
   ([trade_page.dart:212](../lib/presentation/screens/trade/trade_page.dart)).
5. **Watchlist / favorites.**
6. **Search history + recent searches** in the explore tab.
7. **Pull-to-refresh on every list** (Home has it; apply to Explore,
   Portfolio, Wallet history).
8. **Position close / sell flow** — Open Positions list landed via
   [d49fd49](https://github.com/Sandeeptechnobren/beTrade_App/commit/d49fd49); audit detail screen for sell UX.

---

## Phase 5 — Launch readiness

1. **Crash reporting** — add `firebase_crashlytics`. The
   `runZonedGuarded` block in `main.dart` only `debugPrint`s.
2. **Analytics** — add `firebase_analytics`.
3. **Privacy policy + ToS screens.**
4. **App store assets.**
5. **`docs/DEPLOY_LOG.md` discipline.**
6. **Rotating doc-review cadence** for `tasks/lessons.md` and
   `docs/CODEBASE_AUDIT.md`.

---

## What I'd do next (in order)

1. **Confirm backend response shape for `/trade/list`** so we can finish
   2.6 properly (real vote bars + trade counts). 1-day async with API team.
2. **Move auth token to `flutter_secure_storage`** (Phase 1.2) — half a
   day, blocks release.
3. **Replace debug keystore** (Phase 1.1) — half a day, blocks release.
4. **Stand up the first real test** (Phase 1.5) — half a day, sets the
   pattern for future PRs.
5. **Code-hygiene sweep** (Phase 3.1, 3.2, 3.7, 3.8) — quick wins, ~1 hr.

Everything else queues behind these.
