# Current Tasks

## In Progress
(none)

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
