# BeTrade — Developer Plan

How to build, extend, and ship the BeTrade mobile app. Practical
reference for engineers — no client-facing fluff. Anchored to the
actual code in this branch.

---

## 0. TL;DR for a new developer

```
Project        Flutter mobile app — iOS + Android, single codebase
Layers         lib/core   → cross-cutting (env, theme, network, validators)
               lib/data   → models + providers + services
               lib/presentation → screens + reusable widgets
State          provider package; ChangeNotifier per concern
HTTP           Dio singleton + ApiEndpoints + Bearer token from LocalStorage
Models         Manual fromJson, defensive defaults, no codegen
Routing        Imperative Navigator + CommonBottomSheet for sheet UX
Persistence    SharedPreferences via LocalStorage (token, theme, flags)
Push           Firebase Messaging + flutter_local_notifications
Backend        api.buildacademy.io (REST). LMSR engine lives there.
```

Read order for someone new:

1. This file → 2. `lmsr_dfd_workflow.md` → 3. `roadmap.md` → 4. `flow_plan.md` → 5. all `lib/**/CLAUDE.md` files (one per directory).

---

## 1. Repo layout

```
lib/
├── main.dart                         # Bootstraps Firebase, dotenv, LocalStorage,
│                                     # MultiProvider, ScreenUtilInit, Theme.
├── core/
│   ├── config/
│   │   ├── env_config.dart           # EnvConfig.baseUrl from .env
│   │   └── api_endpoint.dart         # ALL endpoint URL builders here
│   ├── network/
│   │   └── dio_client.dart           # Singleton Dio + multipart Dio
│   ├── theme/
│   │   ├── app_colors.dart           # Static colors + *Dynamic(context) variants
│   │   └── app_text_style.dart       # SFProRounded text styles
│   └── utils/validators/             # phone validator
├── data/
│   ├── model/                        # DTOs — manual fromJson, no toJson
│   ├── provider/                     # ChangeNotifier classes (state)
│   └── services/                     # Static-method API + storage clients
└── presentation/
    ├── auth/                         # Auth landing
    ├── onboarding/                   # First-run pager
    ├── bottom_navigation/            # Bottom nav bar
    ├── widget/                       # Reusable widgets (CommonBottomSheet, etc.)
    └── screens/
        ├── splash/                   # Splash + signup multi-step
        ├── signin/                   # Login + OTP
        ├── verification/             # KYC capture
        ├── homeScreen/               # Home + filter sheet
        ├── explore/                  # Explore + search
        ├── trade/                    # Trade detail + Details page (Info+Chart)
        ├── portfolio/                # Positions + wallet (deposit/withdraw)
        ├── profile/                  # Profile + settings + KYC + payment
        ├── camera/                   # KYC capture
        └── main_screen.dart          # IndexedStack of 5 tabs
```

Every directory has a `CLAUDE.md` — read it before editing files in
that directory.

---

## 2. State management — Provider pattern

### 2.1 The contract

Every provider extends `ChangeNotifier`, registered globally in
`lib/main.dart` inside the `MultiProvider`.

```dart
class FooProvider extends ChangeNotifier {
  // Public mutable state — no getters around fields.
  bool isLoading = false;
  String error = '';
  List<FooModel> items = [];

  Future<void> fetch() async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      items = await FooService.list();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

### 2.2 Consumption

| Pattern | When |
|---|---|
| `context.watch<T>()` | inside `build()` — rebuilds on change |
| `Consumer<T>(builder: ...)` | scoped rebuild for a subtree |
| `context.read<T>()` | one-off action (button tap, init) — does NOT rebuild |

### 2.3 Disposal safety

Replicate the `_isDisposed` + `_safeNotifyListeners` pattern from
`CountryProvider` / `CategoryProvider` / `TradeDetailProvider`:

```dart
bool _isDisposed = false;

void _safeNotify() {
  if (!_isDisposed) notifyListeners();
}

@override
void dispose() {
  _isDisposed = true;
  super.dispose();
}
```

Use this for any provider that fires async work whose result might
arrive after the consumer is gone.

### 2.4 Current providers

| Provider | Holds | Service it wraps |
|---|---|---|
| `AuthProvider` | sign-in state | inline `http` (legacy) |
| `SignupProvider` | sign-up state | `auth_service` (Dio) |
| `ProfileProvider` | `ProfileModel?` | `profile_service` |
| `CountryProvider` | country list | inline Dio |
| `CategoryProvider` | category list | `category_service` |
| `TradeProvider` | trade list + paging | `trade_service` |
| `TradeDetailProvider` | current `TradeDetailModel?` | `trade_details_service` |
| `ExploreProvider` | search results | `explorer_service` |
| `WalletProvider` | wallet balance + tx history | `wallet_service` |
| `PositionsProvider` | open positions + per-market detail cache | `positions_service` |
| `DefaultAmountProvider` | user's default trade amount | `default_settings_service` |
| `BottomNavProvider` | current tab index | (none) |
| `ThemeProvider` | `ThemeMode` | `local_storage` |

---

## 3. HTTP layer

### 3.1 Building URLs

**Always** use `ApiEndpoints` — never hardcode URLs.

```dart
// Bad
final url = "https://api.buildacademy.io/trade/list?page=1";

// Good
final url = ApiEndpoints.tradeList(1);
```

The base URL comes from `EnvConfig.baseUrl` which validates that
`BASE_URL` is non-empty in `.env` at startup. If you need a new
endpoint, add it to `lib/core/config/api_endpoint.dart`.

### 3.2 Making requests

`DioClient.instance` is a process-wide singleton with 15s timeouts.
For multipart uploads use `DioClient.multipartInstance` (30s, fresh
Dio per upload).

```dart
final response = await DioClient.instance.post(
  ApiEndpoints.tradeBuy(uuid),
  data: { 'outcome_slug': 'yes', 'cost_ghs': 50 },
  options: Options(headers: {
    'Authorization': 'Bearer ${LocalStorage.getToken()}',
    'Accept': 'application/json',
  }),
);
```

**Note**: The codebase has both `http` and `dio` HTTP clients. New
code should use **Dio**. Old `http` call sites are tracked for
migration in `roadmap.md` Phase 3.3.

### 3.3 Token injection

Every authenticated call must include `Authorization: Bearer
<token>`. Token comes from `LocalStorage.getToken()`. There is no
shared interceptor today — every service injects manually. (Future
improvement: add a Dio interceptor in `dio_client.dart`.)

### 3.4 Error handling pattern

Every service method follows the same shape:

```dart
static Future<FooModel?> getFoo(String id) async {
  try {
    final token = LocalStorage.getToken();
    final response = await DioClient.instance.get(
      ApiEndpoints.foo(id),
      options: Options(headers: { 'Authorization': 'Bearer $token' }),
    );
    if (response.statusCode == 200 && response.data is Map) {
      final body = response.data as Map;
      if (body['status'] == true && body['data'] is Map) {
        return FooModel.fromJson(Map<String, dynamic>.from(body['data']));
      }
    }
    return null;
  } on DioException catch (e) {
    debugPrint('FooService.getFoo DioException: ${e.message}');
    return null;
  } catch (e) {
    debugPrint('FooService.getFoo error: $e');
    return null;
  }
}
```

**Sentinels**: return `[]` for `Future<List<T>>`, `null` for
`Future<T?>`, `false` for `Future<bool>`. Never throw out of a
service.

For methods that need to surface backend error codes (e.g.
`INSUFFICIENT_FUNDS`), return a typed wrapper instead — see
`BuyResponse` / `QuoteResponse` for the pattern.

---

## 4. Data models

### 4.1 Conventions

- One file per model: `lib/data/model/<name>_model.dart`
- All fields `final`; constructor params `required` (or nullable for
  truly optional).
- Single factory `Model.fromJson(Map<String, dynamic> json)`.
- **Manual JSON parsing** — no `freezed`, no `json_serializable`.
- **Defensive defaults**: `?? ''` for strings, `?? 0` for numbers.
  Never let a missing field throw.
- Helper for nullable numeric coercion:

```dart
double n(dynamic v) => v is num ? v.toDouble() : 0.0;
```

### 4.2 Adding a new model — recipe

1. Create `lib/data/model/widget_model.dart`.
2. Define `class WidgetModel { final ...; WidgetModel({required ...}); factory WidgetModel.fromJson(...) {...} }`.
3. If it has nested objects, model those separately (see
   `BuyResponse` → `OrderModel` + `QuoteModel`).
4. Reference it from the corresponding service.

### 4.3 Current models

| File | Class | Source endpoint |
|---|---|---|
| `trade_model.dart` | `TradeModel` | `/trade/list`, `/trade/explore` |
| `trade_detail_model.dart` | `TradeDetailModel` | `/trade/view/{uuid}` |
| `quote_model.dart` | `QuoteModel` | `/trade/{uuid}/quote` data |
| `order_model.dart` | `OrderModel` | embedded in buy response |
| `quote_response.dart` | `QuoteResponse` | `/trade/{uuid}/quote` full wrapper |
| `buy_response.dart` | `BuyResponse` | `/trade/{uuid}/buy` full wrapper |
| `profile_model.dart` | `ProfileModel` | `/profile`, `/edit-profile` |
| `country_model.dart` | `CountryModel` | `/countries` |
| `category_model.dart` | `CategoryModel` | `/trade/categories-list` |
| `default_settings_model.dart` | `DefaultSettingsModel` | `/userDefaultSettings/index` |
| `position_model.dart` | `PositionModel` | `/positions` |
| `graph_model.dart` | `ChartData` | `/chart` |

---

## 5. Services

### 5.1 Conventions

- `abstract class XService {}` with **only `static` methods**.
- One service per backend resource (auth, trade, wallet, profile,
  positions, …).
- Methods named `getX`, `listX`, `createX`, `updateX`, `deleteX`.
- Token injection per call (see §3.3).
- Sentinel error returns (see §3.4).

### 5.2 Current services

`auth_service`, `trade_service`, `trade_details_service`,
`trade_quote_service`, `trade_buy_service`, `home_service` (now dead
post swipe-refactor), `category_service`, `explorer_service`,
`profile_service`, `wallet_service`, `positions_service`,
`default_settings_service`, `notification_services`, `local_storage`.

---

## 6. UI patterns

### 6.1 Theming

```dart
// Color
AppColors.primary                       // static brand purple
AppColors.textPrimaryDynamic(context)   // light/dark aware

// Text
AppTextStyle.heading
AppTextStyle.body
AppTextStyle.small.copyWith(color: ...)
```

Avoid `Colors.purple` / hardcoded hex values — always go through
`AppColors`.

### 6.2 Sizing

Use `flutter_screenutil` extensions. **No hardcoded pixel values.**

```dart
SizedBox(height: 16.h)
EdgeInsets.symmetric(horizontal: 20.w)
Container(width: 50.w, height: 65.h)
TextStyle(fontSize: 14.sp)
BorderRadius.circular(12.r)
```

Design size for the project is `Size(393, 852)` (iPhone 13
dimensions) — set in `main.dart` `ScreenUtilInit`.

### 6.3 Sheets — use `CommonBottomSheet`

```dart
CommonBottomSheet.open(
  context: context,
  builder: (controller) => MyPage(scrollController: controller),
);
```

The `controller` is a `ScrollController` from `DraggableScrollableSheet`
— pass it to your inner scrollview so drag-to-resize works.

**Inside a sheet, do NOT use `Scaffold + AppBar`.** Use `Scaffold` +
`SafeArea` + `Column` with a custom header `Row` at top. See
`TradePage` and `TradeDetailsPage` for the canonical pattern:

```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        _buildHeader(),     // Row(back arrow, title, ..., toggle)
        const Divider(height: 1),
        Expanded(child: _bodyContent()),
      ],
    ),
  ),
);
```

### 6.4 Stacked sheets vs replace

Two choices when one sheet opens another:

```dart
// Stacked — back returns to the parent sheet
void _openDetails() {
  CommonBottomSheet.open(context: context, builder: (c) => Details(...));
}

// Replace — close parent first, then open child. Back returns to caller.
void _openDetails() {
  Navigator.pop(context);
  CommonBottomSheet.open(context: context, builder: (c) => Details(...));
}
```

`TradePage._openDetails()` currently uses **replace** (Vandana's
choice). Pick consciously per UX.

### 6.5 Navigation

No central route table. No `go_router`. Imperative only:

```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => MyScreen()));
```

For pop:

```dart
Navigator.of(context).pop();        // route or sheet
Navigator.of(context).pop(true);    // return a value to the caller
```

If `Navigator.push` is from inside a sheet, the new route stacks on
top of the sheet — expected behavior.

---

## 7. LMSR client integration

The LMSR engine lives on the backend. Client responsibilities are:

### 7.1 Quote — show live LMSR price as user types

```dart
// Debounce 400 ms after last input
Timer? _quoteDebounce;
int _quoteRequestId = 0;

void _scheduleQuoteFetch() {
  _quoteDebounce?.cancel();
  if (amount <= 0) {
    setState(() => _serverQuote = null);
    return;
  }
  _quoteDebounce = Timer(const Duration(milliseconds: 400), _fetchQuote);
}

Future<void> _fetchQuote() async {
  if (!mounted || amount <= 0) return;
  final myRequestId = ++_quoteRequestId;
  final result = await TradeQuoteService.quote(
    marketUuid: widget.tradeUuid,
    outcomeSlug: isYesSelected ? 'yes' : 'no',
    costGhs: amount,
  );
  // Drop stale results — race protection
  if (!mounted || _quoteRequestId != myRequestId) return;
  setState(() => _serverQuote = result);
}
```

Backend throttle: **60/min** per the docstring on
`TradeQuoteService.quote()`. 400 ms debounce keeps us well below.

### 7.2 Buy — generate fresh idempotency key per intent

```dart
final result = await TradeBuyService.buy(
  marketUuid: widget.tradeUuid,
  outcomeSlug: 'yes',
  costGhs: 50,
  idempotencyKey: TradeBuyService.generateIdempotencyKey(),
);

if (result.success) {
  Navigator.of(context).pop(true);
  return;
}

// Map typed error codes to messages
final msg = switch (result.code) {
  'INSUFFICIENT_FUNDS' => 'Not enough wallet balance.',
  'KYC_REQUIRED'       => 'KYC verification required.',
  'MARKET_CLOSED'      => 'Market is closed.',
  'BELOW_MIN_COST'     => 'Below minimum trade amount.',
  'ABOVE_MAX_COST'     => 'Above maximum trade amount.',
  'UNKNOWN_OUTCOME'    => 'Unknown outcome.',
  _                    => result.message ?? 'Buy failed.',
};
```

The same `idempotencyKey` should be reused on a retry of the same
buy intent — that's how the backend short-circuits to the original
order without re-charging.

### 7.3 Detail refresh after buy

Always refetch the trade detail on success — the user's own fill
moves the price:

```dart
if (result == true) {
  detailProvider.fetch(widget.tradeUuid);
}
```

---

## 8. Auth flow & local storage

### 8.1 Sign-in

`AuthProvider.sendOtp(phone)` → `verifyOtp(phone, otp)` →
`LocalStorage.setToken(token)` + `LocalStorage.setDocUploadStatus(status)` →
navigate to `MainScreen`.

### 8.2 LocalStorage — what's allowed

```dart
LocalStorage.getToken()              // bearer token
LocalStorage.setToken(String)
LocalStorage.clearToken()

LocalStorage.getThemeMode()          // 'light' | 'dark' | 'system'
LocalStorage.saveThemeMode(...)

LocalStorage.isOnboardingDone()
LocalStorage.setOnboardingDone(bool)

LocalStorage.getDocUploadStatus()
LocalStorage.setDocUploadStatus(int)
```

### 8.3 Things NOT to store in `SharedPreferences`

- ❌ Auth token in production builds — **release blocker**, must move
  to `flutter_secure_storage` (roadmap Phase 1.2).
- ❌ Card numbers / financial data of any kind (always defer to
  payment gateway).
- ❌ Plain-text passwords or PINs.
- ❌ KYC document images.

---

## 9. Adding a new feature — step-by-step recipe

Example: add a "Watchlist" tab.

1. **Backend confirmation** — confirm endpoints exist:
   `GET /watchlist`, `POST /watchlist/{uuid}`, `DELETE /watchlist/{uuid}`.
2. **`api_endpoint.dart`** — add three URL builders.
3. **Model** — add `lib/data/model/watchlist_item_model.dart` (or
   reuse `TradeModel`).
4. **Service** — add `lib/data/services/watchlist_service.dart` with
   `static Future<List<TradeModel>> list()`,
   `static Future<bool> add(String uuid)`, `static Future<bool> remove(String uuid)`.
5. **Provider** — add `lib/data/provider/watchlist_provider.dart`
   following the standard pattern: `isLoading`, `error`, `items`,
   `fetch()`, `add(uuid)`, `remove(uuid)`. Apply `_isDisposed` safety.
6. **Register in `main.dart`** — add
   `ChangeNotifierProvider(create: (_) => WatchlistProvider())` to the
   `MultiProvider`.
7. **Screen** — add `lib/presentation/screens/watchlist/watchlist_page.dart`.
   Use `Scaffold` + `SafeArea` + `Column` (sheet-friendly if you'll
   ever open it as a sheet). `context.watch<WatchlistProvider>()` in
   `build`. Empty state, loading state, error state, list state.
8. **Entry point** — add a heart icon to `PollCard` (HomeScreen) and
   to the `TradePage` header. Tap → `provider.add(uuid)` /
   `provider.remove(uuid)`.
9. **Tab** — register the new screen in `MainScreen`'s `IndexedStack`
   and `BottomNavProvider`.
10. **Test** — at least one widget test exercising the empty-state and
    loaded-state in `test/watchlist_page_test.dart`.
11. **Update docs** — `lib/data/CLAUDE.md` and
    `lib/presentation/screens/CLAUDE.md` mention the new files.
12. **Add a CHANGELOG entry**, write to `tasks/todo.md`, push as
    `feature/<author>/watchlist`.

---

## 10. Coding conventions

| Rule | Example |
|---|---|
| Files: `snake_case.dart` | `trade_detail_model.dart` |
| Classes: `PascalCase` | `TradeDetailModel` |
| Members: `camelCase` | `categoryName` |
| Private: `_camelCase` | `_isDisposed` |
| One class per file (UI screens may have a private `State` partner) | |
| Imports ordered: dart → flutter → packages → relative | |
| Cross-feature imports: `package:betrade/...` | |
| Sibling imports: `'./my_file.dart'` or `'../folder/my_file.dart'` | |
| No barrel files (`index.dart`) | |
| `const` everywhere it compiles | |
| Always `dispose()` controllers, timers, focus nodes | |
| `if (!mounted) return;` after every `await` in widgets | |

Existing inconsistencies (do NOT replicate; will be fixed per Phase
3.6 of `roadmap.md`):
- `HomeScreen.dart`, `Payment_method.dart`, `Common_header_withlogo.dart` etc.
  use wrong casing.
- `theam_provider.dart`, `step_indecator.dart`, `step_heder.dart`,
  `achivement_Sheet.dart` have spelling errors.
- `api_endpoint..dart` historical typo (now resolved to single dot).

---

## 11. Build & deploy

### 11.1 Local development

```bash
flutter pub get          # install / refresh deps
flutter run              # run on connected device
flutter analyze          # static check before pushing
flutter test             # unit + widget tests (currently fails on main)
```

### 11.2 Release builds

```bash
flutter build apk --release        # Android APK (test track)
flutter build appbundle --release  # Android AAB (Play Store)
flutter build ios --release        # iOS
flutter build ipa --release        # iOS for App Store / TestFlight
```

**Release blocker today:** Android release builds use the **debug
keystore** — must replace before Play Store distribution. See
`docs/CODEBASE_AUDIT.md` §8 and roadmap Phase 1.1.

### 11.3 CI

A Codemagic config exists on a feature branch (not yet on `main`).
Once merged, CI will run `flutter analyze` + `flutter test` on every
PR. Until then, run them locally before push.

### 11.4 Logs every release

Every release / TestFlight upload gets one entry in
`docs/DEPLOY_LOG.md`. No exceptions.

---

## 12. Testing

### 12.1 Current state

`flutter test` currently runs only the default scaffold test and
fails on `main`. We're starting from zero.

### 12.2 Targets per roadmap

Minimum 5 tests to land first:

1. **OTP entry → verify** (widget test)
2. **Trade list pagination** (provider unit test, mocked service)
3. **Quote → buy success** (end-to-end widget test, mocked service)
4. **Quote → buy `INSUFFICIENT_FUNDS` typed error** (widget test)
5. **Token persistence + clear-on-401** (unit test)

### 12.3 Patterns

- Use `mocktail` (preferred) for mocking services in widget tests.
- Wrap widgets under test with `MultiProvider` providing the mocks.
- `pumpWidget` → `tap` → `pump` → `find.text` / `expect`.
- Add **mocktail** to `dev_dependencies` when first test lands.

---

## 13. Common pitfalls (lessons from this codebase)

1. **`late` without initialization** crashes with
   `LateInitializationError`. Use `int x = 0;` instead of `late int x;`
   when the field has a sensible default. (`DefaultAmountProvider` had
   this bug.)
2. **`context.read` after an `await`** — invalid context after async
   gap. Capture it before:
   ```dart
   final messenger = ScaffoldMessenger.of(context);
   await foo();
   if (!mounted) return;
   messenger.showSnackBar(...);
   ```
3. **`notifyListeners` after `dispose()`** logs a warning and may
   crash in debug. Use `_isDisposed` flag pattern.
4. **`fetchTrades()` synchronously in `initState`** — works, but
   triggers a build with stale state for one frame. Use
   `WidgetsBinding.instance.addPostFrameCallback(...)` if the
   provider's initial state isn't `isLoading: true`.
5. **`onPressed: () {}`** stubs that look real to users. Either wire
   them or delete them. (Multiple still in `login_screen.dart`,
   `info_chart_screen.dart`, `deposit_success.dart`.)
6. **Hardcoded URLs** — bypass `EnvConfig.baseUrl`. Don't do it.
   `explorer_service.dart` had this; now flagged.
7. **Withdrawing token from plain prefs** — release blocker. Use
   `flutter_secure_storage`.
8. **`withOpacity()`** is deprecated. Use `.withValues(alpha: 0.5)`
   in new code.

---

## 14. Open issues / where to look

| Topic | Doc |
|---|---|
| Release blockers + remediation phases | `tasks/roadmap.md` |
| Feature flow plan (10 user flows) | `tasks/flow_plan.md` |
| LMSR theory + DFD + workflow reference | `tasks/lmsr_dfd_workflow.md` |
| Bug audit (LateInit, idempotency, etc.) | `tasks/audit_findings.md` |
| Trade tap-flow trace from Home | `tasks/trade_flow_from_home.md` |
| Hardcoded values + backend gaps | `tasks/todo.md` |
| Codebase audit (SOC2-style) | `docs/CODEBASE_AUDIT.md` |
| Style guide | `docs/PATTERNS.md` |
| Architecture overview | `docs/ARCHITECTURE.md` |
| Per-directory READMEs | `lib/**/CLAUDE.md` |

---

## 15. Daily developer flow

```
1. git checkout main && git pull
2. git checkout -b feature/<your-name>/<short-desc>
3. Open `tasks/todo.md` → write the plan you intend to ship
4. Code. Run `flutter analyze` after each meaningful change.
5. Run `flutter test`. Add a test for the new feature.
6. Commit small, push the feature branch.
7. Open a PR with description (what + why) and a test plan.
8. After merge: add a CHANGELOG entry. Mark `tasks/todo.md` done.
9. If you hit a bug or rule worth remembering, append to
   `tasks/lessons.md`.
```
