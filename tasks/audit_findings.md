# BeTrade — Project Audit (2026-05-05)

Issues found by reading the active codebase. Severity is the operator's
risk, not opinion: 🔴 will crash or corrupt data, 🟠 silently wrong
behavior, 🟡 UX or hygiene, 🔵 cleanup.

---

## 🔴 CRITICAL — will crash / lose money

### 1. `DefaultAmountProvider._defaultAmount` is `late` and uninitialized
- File: [default_amount_provider.dart:6](../lib/data/provider/default_amount_provider.dart)
- `late int _defaultAmount;` has no default value
- `loadFromBackend()` is the only init path — and it's **commented out** in
  [HomeScreen._initializeData line 71](../lib/presentation/screens/homeScreen/HomeScreen.dart)
- Repro: brand-new account → land on Home → swipe a card → reading
  `defaultAmount` throws `LateInitializationError` → app crashes
- Fix: change to `int _defaultAmount = 0;` AND add the redirect-to-settings
  guard described below.

### 2. Swipe-buy path can double-charge on retry
- File: [home_service.dart:54](../lib/data/services/home_service.dart) `buyTrade`
- Sends only `outcome_slug + cost_ghs` — **no `idempotency_key`**
- The tap-buy path ([trade_buy_service.dart:31](../lib/data/services/trade_buy_service.dart))
  does send one, generated via `generateIdempotencyKey()`
- A network blip + user retap on the swipe-quote dialog → second order placed
- Fix: generate the key in `_handleSwipe` and forward to `HomeService.buyTrade`,
  same as the tap path

### 3. New user with `default_amount = 0` will fail every swipe-trade
- Server enforces `BELOW_MIN_COST` for cost ≤ minimum
- Today the swipe path sends `cost_ghs: defaultAmount` regardless of value
- After fix #1, the value will be `0` for new users → every swipe → server
  rejection → confusing snackbar
- Fix: see "New requirement" section below — redirect to Default Settings
  before the swipe/tap fires

---

## 🟠 HIGH — silently wrong

### 4. Hard-coded "3975 trades" on every PollCard
- [HomeScreen.dart:879](../lib/presentation/screens/homeScreen/HomeScreen.dart)
- Same string for every card. Should come from `trade_count` in the backend.

### 5. Hard-coded 67/33 vote split on every PollCard
- [HomeScreen.dart:898-900](../lib/presentation/screens/homeScreen/HomeScreen.dart)
- Same percentages for every card. Should come from the YES/NO price ratio
  returned by the backend (or the trade detail endpoint).

### 6. `TradePage` local price math vs server LMSR quote
- [trade_page.dart:60-67](../lib/presentation/screens/trade/trade_page.dart)
- `shares = amount / price` is naive — LMSR pricing has slippage, so the
  number shown to the user diverges from what the buy actually fills at
- Fix: call `TradeQuoteService.quote()` (debounced) and display its values

### 7. Server-side pagination not used
- [trade_service.dart:21](../lib/data/services/trade_service.dart) hardcodes `tradeList(1)`
- [trade_provider.dart loadMore](../lib/data/provider/trade_provider.dart) just slices already-loaded data
- Result: if the backend has 1000 trades, the user only ever sees the first page

### 8. No-op buttons that look interactive
- [login_screen.dart:356, 394](../lib/presentation/screens/signin/login_screen.dart) — two `onPressed: () {}`
- [info_chart_screen.dart:98, 113](../lib/presentation/screens/profile/info_chart_screen.dart) — two `onPressed: () {}`
- [deposit_success.dart:40](../lib/presentation/widget/deposit_success.dart) — `onPressed: () {}`
- Every `CommonShareButton(onTap: () {})` (4 occurrences) — share button is dead
- Fix: wire them or delete them. Dead controls erode user trust.

### 9. Trade detail fetched outside the provider
- [trade_page.dart:33](../lib/presentation/screens/trade/trade_page.dart) calls
  `TradeDetailService` directly in `initState`
- No caching, no shared state, no retry, no error UI beyond "No Data Found"

### 10. `null` returned silently from many service methods
- Almost every service method swallows errors and returns `null` / `[]` /
  `false` — the UI then shows a generic "No Data" or "Something went wrong"
- The user has no signal whether the network is down, the token is bad, or
  the API shape changed
- Fix: distinguish "empty" from "errored" in service returns; surface
  typed error states on providers

---

## 🟡 MEDIUM — UX / consistency

### 11. 56 deprecated `withOpacity()` calls across 19 files
- Will become hard errors in a future Flutter release
- Pattern: `Colors.black.withOpacity(0.5)` → `Colors.black.withValues(alpha: 0.5)`
- I already migrated one in `otp_screen.dart` for the pinput PR

### 12. `_isDisposed` safety only in 2 of 9 providers
- `CountryProvider` and `CategoryProvider` use `_safeNotifyListeners`
- Others may emit "notify after dispose" warnings; in practice the timer
  in `OTPScreen` already does the right thing, but `TradeProvider`,
  `ExploreProvider`, `ProfileProvider`, `WalletProvider`, `PositionsProvider`
  do not

### 13. Tap on trade card → `DraggableScrollableSheet`, not a route
- Cannot deep-link a trade
- No back-stack entry, no URL, no share-link target

### 14. Two HTTP clients coexist (`http` + `dio`)
- `lib/data/CLAUDE.md` says `TradeService` is `http`-based; the actual
  code uses `DioClient.instance` ([trade_service.dart:20](../lib/data/services/trade_service.dart))
- Stale docs everywhere — they drift faster than they're updated

### 15. Massive commented-out code blocks
- `otp_screen.dart` (lines 1-382 — 382 lines of legacy)
- `HomeScreen.dart::PollCard` (lines 986-1295 — 310 lines)
- `trade_provider.dart` (lines 1-95)
- `step_profile.dart` (~72%)
- `trade_filter_bottom_sheet.dart` (~72%)
- `dio_client.dart` (lines 1-20)
- `main.dart` (lines 129-173)
- These inflate every context window read — git history is the right archive

### 16. `_fixAvatar` workaround in `ProfileModel`
- [profile_model.dart](../lib/data/model/profile_model.dart) strips a duplicated
  `https://` prefix from backend responses
- Backend should be fixed; client workaround should die

### 17. Image.network without explicit error/loading builders on PollCard
- [HomeScreen.dart:817](../lib/presentation/screens/homeScreen/HomeScreen.dart) — the active version omits the loading and error builders
  that the legacy commented-out version had ([HomeScreen.dart:1021-1040](../lib/presentation/screens/homeScreen/HomeScreen.dart))
- Result: a slow image load shows a black box; a broken URL shows a broken-image icon

### 18. `kBackground` runZonedGuarded swallows errors silently
- [main.dart:71](../lib/main.dart) `(error, stack) { debugPrint(" Async Error: $error"); }`
- Errors only print to console — no Crashlytics, no Sentry
- Once we ship, we are blind to production crashes

---

## 🔵 LOW — cleanup

### 19. File-naming inconsistencies
- `HomeScreen.dart`, `Payment_method.dart`, `OTP_step.dart`, `Gender_step.dart`,
  `stepPhone.dart`, `newDeposit.dart`, `step_heder.dart`, `achivement_Sheet.dart`,
  `step_indecator.dart`, `theam_provider.dart`, `signIn_provider.dart`,
  `signUp_provider.dart`, `profile_Detail_Screen.dart`,
  `Common_header_withlogo.dart`
- Project convention is `snake_case.dart` with correct spelling

### 20. `TradeService.getTrades()` and `getAllTrades()` are duplicates
- Same endpoint, same payload, same parsing — only the log prefix differs
- One should be deleted

### 21. CLAUDE.md docs are stale on multiple points
- "Buy Yes / Buy No buttons are no-op stubs" — false (now wired through `TradeBuyService`)
- "TradeService is http-based" — false (uses Dio)
- "Deposit/withdraw forms have no API wiring" — false (recent commit
  `a0b9d8e feat(wallet): wire portfolio + history + deposit + withdraw to live API`)

### 22. Hard-coded asset image overlays in trade card
- [trade_page.dart:212](../lib/presentation/screens/trade/trade_page.dart) uses `assets/images/splash.png` as the trade card background
- Should use the trade's own image; fall back to a category-specific placeholder

### 23. `HomeScreen` swipe hint state not respected during loading
- [HomeScreen.dart:232-301](../lib/presentation/screens/homeScreen/HomeScreen.dart) — the swipe-hint overlay sits above
  trades but not above any in-flight loading; if a swipe-quote API call
  is in flight, the hint gesture handlers can fire on top of the loading
  overlay

### 24. `Image.network` errorBuilder uses `const SizedBox()` for app logo
- [HomeScreen.dart:146](../lib/presentation/screens/homeScreen/HomeScreen.dart) — if the bundled `IconLogo.png` is missing,
  the user sees nothing instead of a fallback brand mark

---

## NEW REQUIREMENT — block trade actions when default_amount is 0

The user's spec: "when any account login first time `default_amount` value
is 0 and when user swipe or tap it has to redirect to default settings page".

### Implementation plan
1. In `DefaultAmountProvider`:
   - Change `late int _defaultAmount;` → `int _defaultAmount = 0;`
   - Add `bool get isUnset => _defaultAmount <= 0;`
2. In `HomeScreen._initializeData`:
   - Uncomment `context.read<DefaultAmountProvider>().loadFromBackend();`
     (so backend value populates after auth)
3. In `PollCard.onTap` ([HomeScreen.dart:780](../lib/presentation/screens/homeScreen/HomeScreen.dart)):
   - Check `defaultAmountProvider.isUnset` first
   - If unset → push `DefaultSettingsPage` and show snackbar
     "Please set your default trade amount before placing a trade."
   - Else → existing `CommonBottomSheet.open(...)` flow
4. In `PollCard.onHorizontalDragEnd` (line 792, both branches):
   - Same check before `_handleSwipe(...)`
5. (Optional) inside `BuyBottomSheet` when opened from `TradePage`:
   - Same guard for symmetry — if a user clears their default to 0 mid-session,
     the manual amount field still works, so this guard is only for the
     swipe/quick-buy paths

### Acceptance criteria
- [ ] Brand-new login → tap trade card → redirected to Default Settings
- [ ] Brand-new login → swipe trade card → redirected to Default Settings
- [ ] After saving a non-zero default amount → tap/swipe behave normally
- [ ] No `LateInitializationError` thrown anywhere on a fresh install
- [ ] Backend default amount loads on Home mount (uncommented)
