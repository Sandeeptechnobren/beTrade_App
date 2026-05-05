# BeTrade — Forward Flow Plan

A product-and-flow plan complementing `tasks/roadmap.md`. The roadmap
fixes what exists; this plan describes what the app should *become*
across the next 1–3 months. Each section starts with the **current
state** (anchored to the code), then **gaps**, then **what to build**.

---

## Flow 1 — Onboarding & first-time UX

**Current state**
- [splash_screen.dart](../lib/presentation/screens/splash/splash_screen.dart) routes to onboarding/auth/main based on
  `LocalStorage.isOnboardingDone` + token presence.
- `onboarding_screen.dart` is a static pager (no value proposition,
  no permissions ask).
- Inside Home, a swipe-hint overlay appears once
  ([HomeScreen.dart:232-301](../lib/presentation/screens/homeScreen/HomeScreen.dart)). KYC banner appears at the top of Home if
  `showKycBanner == true`.
- Default-amount-0 redirect (just shipped) routes new users to
  Default Settings on first swipe/tap.

**Gaps**
- No explanation of *what BeTrade is* (prediction market). New users
  see categories + Yes/No bars without context.
- KYC banner is the only nudge; no progress indicator
  (e.g., 1/3 verified).
- Default amount is treated as a trade-time blocker rather than a
  setup step.

**What to build**
- A 3-screen guided welcome inside `onboarding_screen.dart`:
  *(1)* "Trade on what you predict" *(2)* "Yes/No outcomes, real money"
  *(3)* permissions + notifications opt-in.
- Replace the swipe-hint overlay with a **first-trade tutorial** that
  walks the user through one demo trade against a sandbox UUID (no real
  cash). Reuses `BuyBottomSheet` with `costGhs: 0`.
- Setup checklist on Home (collapsible card): Verify identity → Add
  payment → Set default amount → First trade. Each row links to the
  relevant screen.

---

## Flow 2 — Auth (sign-in, sign-up, OTP, KYC)

**Current state**
- Sign-in via phone + OTP ([login_screen.dart](../lib/presentation/screens/signin/login_screen.dart) →
  [otp_screen.dart](../lib/presentation/screens/signin/otp_screen.dart)).
- Sign-up multi-step ([signup_steps_pages/](../lib/presentation/screens/splash/signup_steps_pages/)) — name, gender, profile
  picture, country.
- KYC submission via [verify_account.dart](../lib/presentation/screens/verification/verify_account.dart) — calls `/kyc/submit`.
- `doc_upload_status` persisted via `LocalStorage` after OTP login.

**Gaps**
- Two no-op buttons in `login_screen.dart` (lines 356, 394) that look
  interactive but don't navigate (Phase 3.9 of roadmap).
- No password / passcode / biometric option — every session starts
  with OTP.
- No "remember device" or persistent session beyond token in plain
  `SharedPreferences` (Phase 1.2 release blocker).
- KYC progress isn't visible globally (just a banner on Home).
- No retry path if OTP delivery fails.

**What to build**
- Add **biometric / device PIN** as second-factor for high-value
  actions (buy > X GHS, withdraw any amount). Uses `local_auth` package.
- KYC progress bar in Profile and on Home banner.
- "Resend OTP via call" fallback if SMS doesn't arrive in 30s.
- Move from `SharedPreferences` token to `flutter_secure_storage`
  (already in roadmap Phase 1.2).

---

## Flow 3 — Trade discovery (Home + Explore + filters)

**Current state**
- Home tab ([HomeScreen.dart](../lib/presentation/screens/homeScreen/HomeScreen.dart)) shows `PollCard` list via
  `TradeProvider`. Server pagination just shipped (Phase 2.5).
- Filter bottom sheet ([trade_filter_bottom_sheet.dart](../lib/presentation/screens/homeScreen/trade_filter_bottom_sheet.dart)) by
  category / sort / date.
- Explore tab ([explore_page.dart](../lib/presentation/screens/explore/explore_page.dart)) has search via
  `ExploreProvider` + debounce.
- Card image + category chip + "3975 trades" + 67/33 vote bars
  (placeholders).

**Gaps**
- Vote bars and trade count are still hardcoded (Phase 2.6, blocked
  on backend).
- Filters reset on every navigation; no persistent filter preferences.
- No saved searches, no recent searches.
- No watchlist / favorites surface.
- No empty-state CTA when filter returns 0 results.

**What to build**
- **Watchlist tab** (or section in Explore): heart icon on each card,
  saved markets viewable separately. Stored locally first (synced
  later).
- **Recent searches** in Explore — persist last 10 queries.
- **Filter chips on the Home header** instead of a hidden bottom
  sheet — more discoverable.
- **"Trending" / "Closing soon" sections** on Home — server-side
  ranking, surfaced as horizontal scrollers above the main list.
- Empty-state widget with a "Clear filters" button when search/filter
  yields nothing.

---

## Flow 4 — Trade detail + buy (tap path)

**Current state**
- `PollCard` tap → `CommonBottomSheet` containing
  [trade_page.dart](../lib/presentation/screens/trade/trade_page.dart).
- Trade detail loads via `TradeDetailProvider` (Phase 2.3 just shipped).
- Live LMSR quote via `TradeQuoteService` (Phase 2.4 — debounced
  400ms).
- Buy via `BuyBottomSheet` → `TradeBuyService.buy` with idempotency key.
- Yes/No toggle, amount field, quick chips (10/20/50/100 GHS).

**Gaps**
- No price chart — `ApiEndpoints.tradeChart(uuid)` exists but is never
  called (roadmap Phase 4.2).
- Trade card image is hardcoded `assets/images/splash.png` overlay
  ([trade_page.dart:212](../lib/presentation/screens/trade/trade_page.dart)) instead of the trade's own image.
- No "Liquidity" / "Total volume" / "End date" displayed in the detail.
- No "Share market" CTA (the existing CommonShareButton onTap is `() {}`).
- Trade page opens as a sheet — no deep link, no URL, no back-stack.

**What to build**
- **Price chart** at the top of `TradePage` — wire `tradeChart(uuid)`
  endpoint, render with `fl_chart` (already in pubspec). Default
  timeframe: 24h, with chips for 1h / 24h / 7d.
- **Market metadata strip**: liquidity, total volume, end date, # of
  participants (if backend exposes).
- **Real card image** (use trade's `image` field if available, else
  category-specific fallback).
- **Share market** — generate a deep-link URL,
  `betrade://market/{uuid}`. Requires a `MaterialApp` route table or
  `go_router` migration.
- **Persistent buy intent** — if user enters an amount and closes the
  sheet, restore it next time they tap the same market.

---

## Flow 5 — Trade swipe-quote (Home card swipe)

**Current state**
- Horizontal swipe on `PollCard` → `_handleSwipe` (HomeScreen.dart:367).
- Calls `HomeService.getQuote` with `DefaultAmountProvider.defaultAmount`.
- On success → quote dialog → "Trade" button → `HomeService.buyTrade`
  with idempotency key (Phase 2.1).
- On buy failure → inline red error in dialog (just shipped).

**Gaps**
- No way to adjust amount inside the quote dialog — uses default amount
  only. If user wants 25 GHS instead of 10, must close and go to Default
  Settings.
- No way to switch outcome (YES/NO) inside the quote dialog — must
  re-swipe.
- Swipe direction → outcome mapping (right = YES, left = NO) isn't
  visible until the once-shown swipe hint.

**What to build**
- **Inline amount editor in the quote dialog** with the same quick
  chips as `TradePage`. Re-fetches quote on change (debounced).
- **"Switch to NO/YES" link** at the top of the dialog so user can
  flip without re-swiping.
- **Persistent direction hint** on the card edges (subtle gradient or
  arrow) — not a full overlay.

---

## Flow 6 — Position management (view + close)

**Current state**
- Open Positions list landed via [d49fd49](https://github.com/Sandeeptechnobren/beTrade_App/commit/d49fd49) — see
  `PositionsProvider` and the portfolio detail screen.
- Position detail shows the user's stake + market info.

**Gaps**
- **No sell / close-position flow** — once you buy, there's no way to
  exit before market resolution. This is the single biggest UX gap.
- No P&L over time — just current value.
- No grouping (by market category, by status: open / resolved / pending).
- No notifications when a position resolves.

**What to build**
- **Close-position flow**:
  1. Position detail → "Sell" button.
  2. Sheet showing current sell price (LMSR), receive amount, fees.
  3. Confirm → POST `/positions/{uuid}/sell` (backend endpoint to
     coordinate with API team).
  4. Wallet balance updates, position moves to "Closed" tab.
- **P&L sparkline** on each position row (intraday change).
- **Tabs in Portfolio**: Open · Pending · Closed.
- **Resolution notifications** — push when a market with an open
  position is resolved.

---

## Flow 7 — Wallet (deposit + withdraw + history)

**Current state**
- Wallet wired to live API via [a0b9d8e](https://github.com/Sandeeptechnobren/beTrade_App/commit/a0b9d8e):
  `WalletService`, `wallet_history.dart`, deposit + withdraw screens.
- Endpoints: `/wallet`, `/wallet/transactions`, `/wallet/deposit`,
  `/wallet/withdraw`.

**Gaps**
- No payment-provider integration visible — likely manual / external.
- No "balance below threshold" alert for withdrawals.
- Wallet history doesn't filter by transaction type or date range
  (the endpoint accepts `type` param — `walletTransactions({type, page})`).
- Stray `print(response.data)` in [wallet_service.dart:30](../lib/data/services/wallet_service.dart) (roadmap
  Phase 3.7).

**What to build**
- **Filter chips** on wallet history — `Deposits / Withdrawals /
  Trades`. Wire the existing `type` param.
- **CSV export** of transactions for tax / records.
- **Recurring deposit reminders** (opt-in).
- **Withdrawal limits & timeline** UI (e.g., "withdrawals processed in
  24h").
- **Top-up CTA** in the swipe-quote dialog when `INSUFFICIENT_FUNDS`
  error fires — direct deep link into deposit.

---

## Flow 8 — Profile + settings

**Current state**
- [profile_page.dart](../lib/presentation/screens/profile/profile_page.dart) hub: edit profile, KYC, notifications,
  default settings, payment methods, theme, info chart, help &
  support.
- [edit_profile.dart](../lib/presentation/screens/profile/edit_profile.dart) — name, phone, email, photo.
- Many sub-screens; some have file-naming inconsistencies (Phase 3.6).

**Gaps**
- No "Account info" section (email, phone, member since).
- No "Logout from all devices" option.
- No "Delete account" (legal requirement in many regions).
- No language selector — `ApiEndpoints.languages` exists but isn't
  surfaced.
- No data export / privacy controls.

**What to build**
- **Account section** with email, phone, member-since, ID.
- **Privacy section**: data download (GDPR), delete account, sign out
  everywhere.
- **Language selector** — wire `/languages` endpoint, persist via
  `LocalStorage`.
- **About / Legal** section — Terms, Privacy, Licenses, App version.

---

## Flow 9 — Notifications

**Current state**
- Firebase Messaging wired in [main.dart:43](../lib/main.dart) (background
  handler).
- `flutter_local_notifications` in pubspec.
- `NotificationService.init()` called in main.
- `notification_page.dart` exists in profile area.

**Gaps**
- No per-topic subscription UI (currently all-or-nothing).
- No preferences for *what* to notify on (price alerts? resolutions?
  marketing?).
- No notification history inside the app.
- KYC status updates probably not pushed.

**What to build**
- **Notification preferences screen** under Profile:
  - Market resolutions ✓
  - Price alerts (per-watchlist-market threshold)
  - Promotions ✗
  - System updates ✓
- **In-app notification center** — list of past notifications with
  deep-link CTAs.
- **Per-market price alerts** — long-press card → "Notify me at YES > X%".

---

## Flow 10 — Live data (NEW infrastructure)

**Current state**
- All data is fetched on-demand via REST. No WebSocket, no streaming.
- Trade quote refreshes only on user input (400ms debounce).
- Open positions show stale prices until manual refresh.

**Why it matters**
- Prediction markets move minute-to-minute when news breaks. Static
  prices feel slow vs. competitors.

**What to build**
- **WebSocket channel** for `current_price_per_share` per subscribed
  market. Subscribe when `TradePage` opens, unsubscribe on dispose.
- **Position P&L stream** — push current value updates without polling.
- **Market-resolved push event** — instant notification + force-refresh
  positions list.
- Backend coordination required (this is a new endpoint).

---

## Cross-cutting: New screens / surfaces to add

1. **Watchlist screen** — bookmarked markets, sortable.
2. **Trade history** — separate from positions; chronological log of all
   buys/sells with status.
3. **Notification center** — in-app history of pushes.
4. **Demo / sandbox screen** — first-trade tutorial.
5. **Setup checklist card** — collapsible on Home for incomplete profiles.
6. **Sell/close-position sheet** — biggest gap today.

---

## Priority sequencing (next 12 weeks)

| Sprint | Goal | Items |
|---|---|---|
| **W1-2** | Release blockers | Phase 1.1, 1.2, 1.3 from `roadmap.md` (keystore, secure storage, cleartext) + first 5 tests |
| **W3-4** | Sell flow + chart | Position close (Flow 6), trade chart (Flow 4) |
| **W5-6** | Watchlist + recent searches | Flow 3 additions |
| **W7-8** | Notification preferences + alerts | Flow 9 |
| **W9-10** | Live prices (WebSocket) | Flow 10 — backend dependency |
| **W11-12** | Onboarding tutorial + setup checklist | Flow 1 |

---

## Dependencies on backend / API team

To unblock this plan, confirm or build:
1. `/trade/list` response shape — `yes_price`, `trade_count` fields
   for Phase 2.6.
2. `/positions/{uuid}/sell` (or equivalent) for Flow 6.
3. `/trade/{uuid}/chart` actual response shape for Flow 4 chart.
4. WebSocket endpoint for live prices (Flow 10).
5. Push topic registration & per-topic subscribe API (Flow 9).
6. Account deletion endpoint (Flow 8).
7. Per-market price alert subscription (Flow 9).

Surface these to the API team early — they're the long-pole items
across the whole plan.
