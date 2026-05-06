# BeTrade — LMSR Trading Rules, Data-Flow Diagram, and Workflow

A reference plan covering three things, anchored to the actual code in
this branch as of 2026-05-05:

1. **Trading rules** — how LMSR pricing works, what the BeTrade backend
   enforces, and what the client must do.
2. **Data-Flow Diagram** — context (Level-0) and process (Level-1) views.
3. **Workflow** — user journeys, developer git workflow, build & deploy.

This is a planning / architecture document. It does not change any
source files.

---

## Part 1 — LMSR Trading Rules

### 1.1 Theory (Hanson's Logarithmic Market Scoring Rule, 2003)

LMSR is the automated market-maker BeTrade uses to price prediction
markets. It guarantees liquidity (any trade can fill at any time) at
the cost of a bounded subsidy to the market.

**Cost function** for an N-outcome market with current outstanding
share quantities `q = (q₁, q₂, …, q_N)` and liquidity parameter `b`:

```
C(q) = b · ln( Σᵢ exp(qᵢ / b) )
```

**Instantaneous price** for outcome `i`:

```
pᵢ = exp(qᵢ / b) / Σⱼ exp(qⱼ / b)
```

Properties:
- Prices always sum to 1 → they're directly interpretable as
  **implied probabilities** (price 0.28 == 28% market belief).
- Buying shares of outcome `i` raises `pᵢ` and lowers all `pⱼ`
  proportionally — this is **price impact** / **slippage**.
- Cost to buy `Δq` shares of outcome `i`: `C(q + Δq·eᵢ) − C(q)`.
- Worst-case market-maker loss is **bounded** at `b · ln(N)`. For
  BeTrade's binary markets that is `b · ln(2) ≈ 0.693 · b` GHS.

`b` is set per market by the platform — higher `b` means less
slippage per GHS traded but a larger subsidy required.

### 1.2 What the BeTrade backend does (atomic per buy)

Deduced from [trade_buy_service.dart](../lib/data/services/trade_buy_service.dart) docstrings and observed
endpoints in [api_endpoint.dart](../lib/core/config/api_endpoint.dart):

For every `POST /trade/{uuid}/buy` the backend executes, in one DB
transaction:

1. **Market-open guard** — reject with `MARKET_CLOSED` if the market
   is closed or already resolved.
2. **KYC guard** — reject with `KYC_REQUIRED` if the user hasn't
   completed KYC.
3. **Cost-bounds guard** — reject with `BELOW_MIN_COST` /
   `ABOVE_MAX_COST` if the requested cost is outside the per-market
   limits.
4. **Outcome lock** — confirm `outcome_slug` exists on this market;
   reject with `UNKNOWN_OUTCOME` otherwise.
5. **Idempotency check** — short-circuit if `idempotency_key` matches
   a previously-completed Order; return the original Order without
   re-charging.
6. **Wallet lock** — reject with `INSUFFICIENT_FUNDS` if the wallet
   can't cover `cost_ghs`.
7. **LMSR fill** — compute the actual fill quantity using the cost
   function above, deduct the cost from the wallet, append shares to
   the user's position, and persist the new LMSR `q` state.

### 1.3 Endpoints used by the client

[api_endpoint.dart](../lib/core/config/api_endpoint.dart):

| Method | Path                              | Purpose                                  |
|--------|-----------------------------------|------------------------------------------|
| GET    | `/trade/list?page=N`              | Trade discovery (paginated)              |
| GET    | `/trade/explore?search=Q`         | Search                                   |
| GET    | `/trade/categories-list`          | Category filter list                     |
| GET    | `/trade/view/{uuid}`              | Trade detail                             |
| POST   | `/trade/{uuid}/quote`             | Live LMSR price quote (60/min throttled) |
| POST   | `/trade/{uuid}/buy`               | Place an order                           |
| GET    | `/trade/{uuid}/chart`             | Price history                            |

### 1.4 Client responsibilities (rules the app must follow)

- **Generate a fresh UUID-v4 `idempotency_key` per Buy tap** — see
  [TradeBuyService.generateIdempotencyKey](../lib/data/services/trade_buy_service.dart). The same key
  is reused for retries of the same intent so the wallet is never
  double-charged. Both buy paths now do this:
  - Tap path → `BuyBottomSheet._placeBuy` → `TradeBuyService.buy`.
  - Swipe path → after the recent refactor, swipe also opens
    `TradePage` and uses the same `BuyBottomSheet`, so they share a
    single buy code path.
- **Show the server quote, not a local approximation.**
  [TradeQuoteService.quote()](../lib/data/services/trade_quote_service.dart) returns the LMSR-aware
  numbers; client must debounce (≥300 ms) to respect the 60/min
  backend throttle. [TradePage](../lib/presentation/screens/trade/trade_page.dart) now uses 400 ms
  debounce and a request-ID guard to drop stale results.
- **Map typed error codes to actionable UX:**
  - `INSUFFICIENT_FUNDS` → "Top up wallet" CTA.
  - `KYC_REQUIRED` → push KYC screen.
  - `MARKET_CLOSED` → close the buy sheet, refresh detail.
  - `BELOW_MIN_COST` / `ABOVE_MAX_COST` → in-line cost validation.
  - `UNKNOWN_OUTCOME` → developer error; show generic + log.
- **Pre-trade validation:** cost must be `> 0` and within the per-market
  `min_trade_amount` / `max_trade_amount` window.
- **Default trade amount must be set** before swipe/tap fires
  (`DefaultAmountProvider.defaultAmount > 0`). Phase 0.1 enforces this
  by routing to `DefaultSettingsPage` when unset.

### 1.5 BeTrade-specific application rules

- All markets are **binary** (YES vs NO).
- Currency is **GHS** (Ghana Cedi).
- **Quick-amount chips:** 10 / 20 / 50 / 100 GHS in `TradePage`.
- **Price interpretation:** the YES price is the implied probability
  the market is assigning to YES. The Details page renders this as
  `"X% Chance"` (`currentPricePerShare * 100`).
- **Vote bars on home cards** are *currently hard-coded* (67/33);
  Phase 2.6 in `roadmap.md` blocks on backend supplying real
  `yes_price` / `no_price` per market in `/trade/list`.

---

## Part 2 — Data-Flow Diagram (DFD)

### 2.1 Level-0 (Context Diagram)

```
                    ┌────────────────────────┐
                    │         User           │
                    │  (mobile, single role) │
                    └──────────┬─────────────┘
                               │
                  taps / swipes / types
                               │
                               ▼
   ┌──────────────────────────────────────────────────────────┐
   │                                                          │
   │                BeTrade Mobile App                        │
   │   (Flutter / Material 3 / provider state mgmt)           │
   │                                                          │
   └──┬───────────────┬────────────────┬───────────────┬──────┘
      │               │                │               │
      │ HTTPS         │ HTTPS          │ FCM push      │ R/W
      │ (Bearer)      │ (Bearer)       │               │
      ▼               ▼                ▼               ▼
   ┌──────┐     ┌──────────┐      ┌──────────┐   ┌─────────────┐
   │ KYC  │     │ Trade /  │      │ Firebase │   │ Shared-     │
   │ API  │     │ Wallet / │      │ Cloud    │   │ Preferences │
   │      │     │ Profile  │      │ Messaging│   │ (on device) │
   │      │     │ APIs     │      │          │   │             │
   └──────┘     └──────────┘      └──────────┘   └─────────────┘
       all of these live under api.buildacademy.io
```

External entities:
- **User** — single role; no admin or moderator surfaces in the app.
- **Backend API** — `api.buildacademy.io` — REST endpoints for auth,
  trade, wallet, profile, KYC, notifications.
- **Firebase Cloud Messaging** — push notifications inbound only.
- **SharedPreferences** — on-device persistent KV store for the auth
  token, theme mode, onboarding flag, and a few business flags.

### 2.2 Level-1 (Major processes inside the app)

```
                              ┌────────────────────┐
              POST /login →   │  P1   Auth         │
              /verify-otp     │  (signin/, signup/)│
              /register   ←   └────────┬───────────┘
                                       │ token
                                       ▼
                                 ┌──────────┐
                                 │ D1       │
                                 │ Local-   │ ← theme, onboardingDone,
                                 │ Storage  │   doc_upload_status
                                 └────┬─────┘
                                      │ token
                                      ▼
   ┌─────────────────────────────────────────────────────────────┐
   │                MainScreen (IndexedStack, 5 tabs)            │
   │                                                             │
   │   ┌────────┐ ┌────────┐ ┌──────────┐ ┌─────────┐ ┌────────┐ │
   │   │  Home  │ │Explore │ │ InfoChart│ │Portfolio│ │Profile │ │
   │   │ (P3)   │ │ (P3)   │ │ (P5/chart│ │  (P6)   │ │  (P8)  │ │
   │   └───┬────┘ └───┬────┘ └────┬─────┘ └────┬────┘ └────┬───┘ │
   └───────┼──────────┼───────────┼────────────┼───────────┼─────┘
           │          │           │            │           │
           ▼          ▼           ▼            ▼           ▼
        ┌────────────────┐  ┌──────────┐  ┌────────┐  ┌────────┐
        │ P3 Trade       │  │ P4 Trade │  │ P6     │  │ P8     │
        │   Discovery    │→ │  Detail  │→ │Position│  │Profile │
        │ (Trade/Explore │  │ + Buy    │  │ Mgmt   │  │ + KYC  │
        │  Provider)     │  │  (P5)    │  │        │  │        │
        └───────┬────────┘  └─────┬────┘  └────┬───┘  └───┬────┘
                │                 │            │          │
                ▼                 ▼            ▼          ▼
            ┌────────────────────────────────────────────┐
            │          P9 HTTP Layer (Dio + http)         │
            │   token injection, request/response, error │
            └────────────────────┬───────────────────────┘
                                 │ HTTPS Bearer
                                 ▼
                        api.buildacademy.io
```

### 2.3 Process catalogue

| ID  | Process            | Provider(s)                                | Service(s)                                  | Endpoints                                                    |
|-----|--------------------|--------------------------------------------|---------------------------------------------|--------------------------------------------------------------|
| P1  | Auth               | `AuthProvider`, `SignupProvider`           | `auth_service`                              | `/login`, `/verify-otp/login`, `/register`, `/verify-otp/register`, `/logout`, `/verify-token` |
| P2  | KYC                | (direct — no provider)                     | (direct in `verify_account.dart`)           | `/kyc/submit`, `/profile/preferences`                        |
| P3  | Trade Discovery    | `TradeProvider`, `ExploreProvider`, `CategoryProvider` | `trade_service`, `explorer_service`, `category_service` | `/trade/list?page=N`, `/trade/explore?search=Q`, `/trade/categories-list` |
| P4  | Trade Detail       | `TradeDetailProvider`                      | `trade_details_service`                     | `/trade/view/{uuid}`                                         |
| P5  | Trade Buy          | (sheet-local state)                        | `trade_quote_service`, `trade_buy_service`  | `/trade/{uuid}/quote`, `/trade/{uuid}/buy`                   |
| P5b | Trade Chart        | (page-local state)                         | (TODO — endpoint exists, unused)            | `/trade/{uuid}/chart`                                        |
| P6  | Position Mgmt      | `PositionsProvider`                        | `positions_service`                         | `/positions`, `/positions/{marketUuid}`                      |
| P7  | Wallet             | `WalletProvider`                           | `wallet_service`                            | `/wallet`, `/wallet/transactions`, `/wallet/deposit`, `/wallet/withdraw` |
| P8  | Profile            | `ProfileProvider`, `CountryProvider`, `ThemeProvider`, `DefaultAmountProvider` | `profile_service`, `default_settings_service` | `/profile`, `/edit-profile`, `/countries`, `/userDefaultSettings/index`, `/userDefaultSettings/update` |
| P9  | Notifications      | (FCM background handler in `main.dart`)    | `notification_services`                     | (Firebase, no REST)                                          |

### 2.4 Data stores

| ID  | Store                  | Lives in                           | Holds                                                         |
|-----|------------------------|------------------------------------|---------------------------------------------------------------|
| D1  | LocalStorage           | `SharedPreferences` (on disk)      | `token`, `theme_mode`, `onboardingDone`, `doc_upload_status`  |
| D2  | TradeProvider state    | RAM (singleton in `MultiProvider`) | List of `TradeModel`, paging cursor, filter, error            |
| D3  | TradeDetailProvider    | RAM                                | Current `TradeDetailModel`, isLoading, error, currentUuid     |
| D4  | Other providers        | RAM                                | Profile, Categories, Countries, Wallet, Positions, Theme, etc.|
| D5  | Sheet-local state      | Widget state                       | Buy amount, quote in flight, buyError                         |

### 2.5 Key data flows (call → response)

#### Buy flow (the most critical path)

```
[User: tap card or swipe]
    │
    ▼
PollCard.onTap / _handleSwipe
    │  read DefaultAmountProvider.defaultAmount
    │  if ≤ 0 → push DefaultSettingsPage and stop
    ▼
CommonBottomSheet.open ⇒ TradePage(initialOutcome)
    │
    ▼
TradePage.initState
    │  context.read<TradeDetailProvider>().fetch(uuid)
    ▼
TradeDetailService.getTradeDetail(uuid)
    │  GET /trade/view/{uuid} → TradeDetailModel
    │
[user types amount or taps quick chip]
    │
    ▼
_scheduleQuoteFetch (400 ms debounce, request-ID guard)
    │
    ▼
TradeQuoteService.quote(uuid, outcome, cost)
    │  POST /trade/{uuid}/quote → QuoteModel
    │
[user taps Buy]
    │
    ▼
BuyBottomSheet._placeBuy
    │  generateIdempotencyKey()
    ▼
TradeBuyService.buy(uuid, outcome, cost, idempotencyKey)
    │  POST /trade/{uuid}/buy
    │  ↳ atomic backend tx (see Part 1.2)
    │  → BuyResponse(success, code, message, order, quote, walletBalance)
    ▼
On success: pop sheet with `true`
    │
    ▼
TradePage._openBuySheet handles the `true`:
    │  detailProvider.fetch(uuid)  ← refresh price/volume
    │  show "Order filled." snackbar
```

#### Auth flow (sign-in)

```
[User enters phone] → AuthProvider.sendOtp(phone)
                      └─ POST /login → {success, message}
[User enters OTP]   → AuthProvider.verifyOtp(phone, otp)
                      └─ POST /verify-otp/login → {token, doc_upload_status}
                      └─ LocalStorage.setToken(token)
                      └─ LocalStorage.setDocUploadStatus(status)
                      └─ navigate to MainScreen(showWelcomePopup, docUploadStatus)
```

---

## Part 3 — Workflows

### 3.1 User journeys

#### A. First-time install
```
SplashScreen
  ├─ no token → onboarding pager → AuthScreen
  ├─ Sign Up → multi-step (name → gender → photo → country) → KYC → MainScreen
  └─ Sign In → phone → OTP → MainScreen
                                  ├─ KYC banner if doc_upload_status incomplete
                                  └─ swipe-hint overlay (one-time)
```

#### B. Returning user
```
SplashScreen → token present → /verify-token
  ├─ valid → MainScreen
  └─ invalid → AuthScreen (token cleared)
```

#### C. Trade buy (post-Phase-2 refactor — single path)
```
HomeScreen / ExplorePage
  └─ tap card OR swipe card
       ├─ default amount > 0 ? → no, push DefaultSettingsPage → stop
       └─ default amount > 0 ? → yes, open TradePage in CommonBottomSheet
             ├─ TradePage shows description / amount / quote
             ├─ tap title card → push TradeDetailsPage (Info | Chart)
             └─ enter amount → server quote (400 ms debounce)
                   └─ tap Buy → BuyBottomSheet
                          └─ confirm → BuyResponse
                                ├─ success → close, refresh detail
                                └─ typed error → inline UI in sheet
```

#### D. Position management
```
PortfolioPage
  └─ Open Positions list (PositionsProvider)
        └─ tap row → position detail screen
              └─ TODO: sell / close-position flow (Phase 4 of roadmap)
```

#### E. Wallet
```
PortfolioPage / wallet section
  ├─ deposit → /wallet/deposit
  ├─ withdraw → /wallet/withdraw
  └─ history → /wallet/transactions?type=&page=
```

#### F. KYC
```
ProfilePage → Verify Account
  └─ camera capture → /kyc/submit
        └─ /profile/preferences updates user defaults
```

### 3.2 Developer / Git workflow

Per `CLAUDE.md`:

- **Branch naming:** `feature/[your-name]/[short-description]`. Never
  commit directly to `main`.
- **PR rules:** every PR has a clear summary, links to the work item /
  todo.md entry, and a test plan. At least one teammate review.
- **CHANGELOG:** every PR adds an entry to `CHANGELOG.md`.
- **`tasks/todo.md` and `tasks/lessons.md`:** before starting work,
  write the plan to `todo.md`. After every correction or mistake,
  add a rule to `lessons.md` so the same mistake doesn't recur.
- **Bulk-operation safety:** never `sed`/find-replace without
  excluding `.claude/skills/`, `.git/`, `build/`, `.dart_tool/`,
  `ios/Pods/`, `android/.gradle/`, lock files. Always show the file
  list and wait for `APPROVED` before bulk-editing 5+ files.

### 3.3 Branch state today

```
main                ── 8a6dfff (Merge PR #14) ── 48f447e (vandana, otp_screen_ui)

feature/vandana_claude (latest tip)
  ↑
  0979704 — swipe→bottom-sheet + Details page
  fb1c571 — inline error UI on swipe-buy + flow_plan
  b7910c2 — Phase 0 + Phase 2.1-2.5 (DTOs, server quote, pagination, idempotency)
  c32ddf3 — Merge main: revert OTP to pre-today state, drop pinput
  63f5158 — feat(otp): migrate OTP screen to pinput plugin (since reverted)
  8a6dfff (merge-base with main)
```

### 3.4 Build / deploy workflow

- **Android debug:** `flutter run` (current Gradle config uses debug
  keystore for *all* builds — release blocker noted in roadmap Phase 1).
- **Android release:** `flutter build apk` / `flutter build appbundle`
  → must replace debug keystore before Play Store distribution.
- **iOS:** `flutter build ios` / `flutter build ipa` — Codemagic config
  exists on a feature branch (not yet on main).
- **Push notifications:** `firebase_options.dart` is committed; FCM
  topic / token registration with backend still TBC.
- **No CI on `main` today** — flutter analyze + flutter test should be
  wired up via Codemagic before next release (Phase 1.6 in roadmap).
- **Every release / TestFlight upload** logged to `docs/DEPLOY_LOG.md`.

### 3.5 Test workflow (target — current state is `flutter test`
fails on `main`)

- **Per-feature minimum:** 1 widget or unit test per new feature.
- **Categories:** API contract, business logic, integration,
  security, tenant isolation.
- **Required gates before push:** `/test`, `/audit` (UI work),
  `/polish` (UI work).
- **Regression rule:** any QA-found bug gets a regression test added.

### 3.6 Key rules to enforce in CI when wired

- `flutter analyze` exit 0 on touched files (must not introduce new
  warnings; pre-existing `withOpacity` etc. tracked separately).
- All providers extend `ChangeNotifier` and call `notifyListeners()`
  after every mutation.
- All services use `static` methods returning `Future<Model>` /
  `Future<List<Model>>` with sentinel returns (`[]`, `null`, `false`)
  on error.
- Every new feature carries at least one widget/unit test.
- Lock files (`pubspec.lock`) committed.

---

## Appendix — Where this plan diverges from current code

This plan reflects the **target state** after the Phase 0 + Phase 2
work in this branch. A few items still gap:

- **Vote bars + trade counts on home cards** are hard-coded
  (Phase 2.6, blocks on backend).
- **Trade chart endpoint** exists but is unwired — chart tab in the
  new Details page renders sample data (see `tasks/todo.md`).
- **HomeService is now unused dead code** post the swipe→sheet
  refactor; queued for cleanup.
- **Sell / close-position flow** does not exist — biggest single UX
  gap (see `tasks/flow_plan.md` Flow 6).
- **Auth token is in plain `SharedPreferences`** — release blocker.
- **Android release uses the debug keystore** — release blocker.
