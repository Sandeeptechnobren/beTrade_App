# Trade Flow Plan — From Home Card Tap

This doc traces what happens when a user interacts with a `PollCard` on the
Home tab, end-to-end. Two gesture paths exist on the same card: **tap**
(opens full detail sheet) and **horizontal swipe** (one-tap quote → buy).

---

## Path A — Tap on card → Trade detail bottom sheet

### Step 1 — Card tap captured
- File: [HomeScreen.dart:780](../lib/presentation/screens/homeScreen/HomeScreen.dart)
- Widget: `PollCard.GestureDetector.onTap`
- Action: prints `"CLICK UUID: ${trade.uuid}"`, then calls `CommonBottomSheet.open(...)`

### Step 2 — Bottom sheet opens
- File: [common_bottom_sheet.dart:5](../lib/presentation/widget/common_bottom_sheet.dart)
- Wraps the screen in `showModalBottomSheet` + `DraggableScrollableSheet`
- Sizing: `initialChildSize: 0.9`, `minChildSize: 0.7`, `maxChildSize: 0.95`
- Passes a `ScrollController` into the builder so the inner page can drive drag-to-resize

### Step 3 — `TradePage` mounts
- File: [trade_page.dart:8](../lib/presentation/screens/trade/trade_page.dart)
- Required props: `tradeUuid`, `scrollController`
- Initial state: `isYesSelected = true`, `amount = 0`, `tradeData = null`, `isLoading = true`
- `initState` → `fetchTradeDetail()`

### Step 4 — Detail API call
- File: [trade_details_service.dart:7](../lib/data/services/trade_details_service.dart)
- Endpoint: `GET /trade/view/{uuid}` (`ApiEndpoints.tradeView`)
- Client: `DioClient.instance` with `Authorization: Bearer <LocalStorage.getToken()>`
- Returns: `Map<String, dynamic>?` (no model class)
- Failure: returns `null`; UI shows `"No Data Found"` (no retry, no error message)

### Step 5 — UI renders
- Loading: `CircularProgressIndicator`
- Loaded:
  - Header strip with category + description over `assets/images/splash.png`
  - Yes/No toggle pill (sets `isYesSelected`)
  - Amount field (`TextField`) + 4 quick-amount chips: 10/20/50/100 GHS
  - Live local computation:
    - `price = tradeData["current_price_per_share"]`
    - `shares = amount / price`
    - `payout = shares * price`
    - `profit = payout - amount`
  - Bottom CTA: "Buy Yes" (green) or "Buy No" (red) — disabled until `amount > 0`

### Step 6 — Buy CTA opens nested sheet
- File: [trade_page.dart:72](../lib/presentation/screens/trade/trade_page.dart) `_openBuySheet`
- Opens `BuyBottomSheet(marketUuid, outcomeSlug, costGhs, marketTitle)` via another modal
- Captures `ScaffoldMessenger` BEFORE the await (avoids `use_build_context_synchronously` lint)

### Step 7 — `BuyBottomSheet` runs the quote → buy round-trip
- Quote: [TradeQuoteService.quote()](../lib/data/services/trade_quote_service.dart) — `POST /trade/{uuid}/quote`
- Buy: [TradeBuyService.buy()](../lib/data/services/trade_buy_service.dart) — `POST /trade/{uuid}/buy`
- Idempotency: `TradeBuyService.generateIdempotencyKey()` (RFC 4122 v4 UUID)
- Typed errors: `INSUFFICIENT_FUNDS`, `KYC_REQUIRED`, `MARKET_CLOSED`, `BELOW_MIN_COST`, `ABOVE_MAX_COST`, `UNKNOWN_OUTCOME`

### Step 8 — Success path
- Sheet returns `true`
- `TradePage.fetchTradeDetail()` re-runs (refresh prices/volume to reflect own fill)
- Snackbar: `"Order filled."`

---

## Path B — Horizontal swipe on card → One-tap quote dialog

### Step 1 — Swipe gesture captured
- File: [HomeScreen.dart:792](../lib/presentation/screens/homeScreen/HomeScreen.dart) `onHorizontalDragEnd`
- Threshold: `details.primaryVelocity.abs() >= 300`
- Right swipe (`velocity > 0`) → `_handleSwipe("yes")`
- Left swipe (`velocity < 0`) → `_handleSwipe("no")`

### Step 2 — Quote with default amount
- File: [HomeScreen.dart:363](../lib/presentation/screens/homeScreen/HomeScreen.dart) `_handleSwipe`
- Reads `DefaultAmountProvider.defaultAmount` (set in Profile → Default Settings)
- Sets `isSending = true` → loading overlay on card
- Calls [HomeService.getQuote()](../lib/data/services/home_service.dart) — `POST /trade/{uuid}/quote`
- Backend codes handled: `MARKET_CLOSED` → "Market is closed or already resolved"

### Step 3 — Quote dialog
- File: [HomeScreen.dart:439](../lib/presentation/screens/homeScreen/HomeScreen.dart) `_showQuotePopup`
- Shows: shares • avg price • amount paid • max payout • potential profit • fee • price impact
- Two buttons: `Close` and `Trade`

### Step 4 — Trade button → buy
- File: [HomeScreen.dart:460](../lib/presentation/screens/homeScreen/HomeScreen.dart) `onTradePressed`
- Calls [HomeService.buyTrade()](../lib/data/services/home_service.dart) — `POST /trade/{uuid}/buy`
- ⚠ Sends `outcome_slug + cost_ghs` only — **no idempotency_key** (diverges from `TradeBuyService.buy`)

### Step 5 — Success dialog
- File: [HomeScreen.dart:635](../lib/presentation/screens/homeScreen/HomeScreen.dart) `_showTradeSuccessPopup`
- Shows: shares bought • avg fill price • amount paid • max payout • potential profit • fee • new wallet balance
- Single `Close` button

---

## State + side effects involved

| Provider / Service | Role | File |
|---|---|---|
| `TradeProvider` | Holds list, runs initial fetch + pagination + filters | [trade_provider.dart](../lib/data/provider/trade_provider.dart) |
| `CategoryProvider` | Fetches filter category list on mount | [category_provider.dart](../lib/data/provider/category_provider.dart) |
| `DefaultAmountProvider` | Supplies default GHS for swipe-buy | [default_amount_provider.dart](../lib/data/provider/default_amount_provider.dart) |
| `LocalStorage.getToken` | Bearer token per request | [local_storage.dart](../lib/data/services/local_storage.dart) |
| `DioClient.instance` | HTTP client (15s timeout) | [dio_client.dart](../lib/core/network/dio_client.dart) |
| `ApiEndpoints` | URL builders | [api_endpoint.dart](../lib/core/config/api_endpoint.dart) |

---

## Endpoints touched in this flow

- `GET /trade/view/{uuid}` — detail (tap path)
- `POST /trade/{uuid}/quote` — live LMSR quote (both paths)
- `POST /trade/{uuid}/buy` — order placement (both paths)

---

## Gaps + risks worth fixing later

1. **Inconsistent buy implementations.** `HomeService.buyTrade()` (swipe path) and `TradeBuyService.buy()` (tap path) hit the same endpoint with different payloads. Only the tap path sends `idempotency_key` → swipe-buy retries can double-charge.
2. **No detail/quote/buy DTOs.** All responses are raw `Map<String, dynamic>` — backend shape changes won't trip a compile error.
3. **`TradePage` skips the provider.** Fetches detail directly in `initState`. No caching, no shared state with the rest of the app.
4. **Local price math duplicates server quote.** `trade_page.dart:60-67` recomputes shares/payout/profit client-side; can diverge from the LMSR-aware server quote.
5. **`TradePage` opened as a bottom sheet, not a route.** No deep-linking, no back-stack entry, no URL.
6. **Hard-coded "3975 trades" on the card** ([HomeScreen.dart:879](../lib/presentation/screens/homeScreen/HomeScreen.dart)).
7. **Vote bar percentages are hard-coded** 67/33 ([HomeScreen.dart:898-900](../lib/presentation/screens/homeScreen/HomeScreen.dart)).
8. **No in-flight guard** between swipe-quote loading and tap — user can tap into detail while swipe quote is pending.
9. **`SchedulerBinding.instance.addPostFrameCallback`** in `initState` triggers two parallel fetches (categories + trades) without coordination.
10. **`onBannerTap` for KYC banner is `VoidCallback?`** — silently no-ops if not provided.
