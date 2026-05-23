# BeTrade — Patterns & Style Guide

**Repository:** `github.com/Sandeeptechnobren/beTrade_App`
**Local path:** `D:\claude\betrade`
**Date:** 2026-05-23
**Companion docs:** [`CODEBASE_AUDIT.md`](./CODEBASE_AUDIT.md), [`ARCHITECTURE.md`](./ARCHITECTURE.md)

> Real, in-repo examples for every pattern. Cite this file for *how to write
> new code* — file paths inside each section point at the canonical instance.

---

## Table of Contents

1. [API Endpoint Calls (Service Pattern)](#1-api-endpoint-calls-service-pattern)
2. [Data Queries & Persistence](#2-data-queries--persistence)
3. [Error Handling](#3-error-handling)
4. [Auth / Token Injection (Client-Side "Middleware")](#4-auth--token-injection-client-side-middleware)
5. [Environment Variables & Config](#5-environment-variables--config)
6. [Feature Folder Organisation](#6-feature-folder-organisation)
7. [Tests](#7-tests)
8. [Background Jobs / Async Work](#8-background-jobs--async-work)
9. [Frontend Components (Reusable Widgets)](#9-frontend-components-reusable-widgets)
10. [API Response Format (Success + Error Shapes)](#10-api-response-format-success--error-shapes)
11. [Naming Conventions](#11-naming-conventions)
12. [Import / Export Patterns](#12-import--export-patterns)

---

## 1. API Endpoint Calls (Service Pattern)

> Flutter has no server-side routes. "API surface" here means **how a service method calls the backend**.

### Canonical example — `lib/data/services/trade_quote_service.dart`

```dart
class TradeQuoteService {
  /// POST /api/trade/{uuid}/quote
  static Future<QuoteModel?> quote({
    required String marketUuid,
    required String outcomeSlug,
    required double costGhs,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.post(
        ApiEndpoints.tradeQuote(marketUuid),
        data: {
          'outcome_slug': outcomeSlug,
          'cost_ghs': costGhs,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        if (body['status'] == true && body['data'] is Map) {
          return QuoteModel.fromJson(
            Map<String, dynamic>.from(body['data'] as Map),
          );
        }
      }
      return null;
    } on DioException catch (e) {
      print('TradeQuoteService DioException: ${e.message}; '
          'response=${e.response?.data}');
      return null;
    } catch (e) {
      print('TradeQuoteService error: $e');
      return null;
    }
  }
}
```

### Rules

- **Service class:** abstract class with `static` methods. One file per backend resource (`trade_quote_service.dart`, `wallet_service.dart`, …).
- **Method signature:** named-parameter constructor; `Future<Model?>` for single-entity reads, `Future<List<Model>>` for lists, `Future<bool>` for fire-and-forget mutations, `Future<TypedResponse>` for envelope responses (see §10).
- **URL construction:** always via `ApiEndpoints.xxx(...)` from `lib/core/config/api_endpoint.dart`. Don't hard-code URLs. (`explorer_service.dart` and `trade_details_service.dart` currently violate this — don't replicate.)
- **HTTP client:** `DioClient.instance` for JSON, `DioClient.multipartInstance` for file uploads. **Do not** add a second `Dio()` or import `package:http/http.dart` in new code — the audit flags the dual-client situation as cleanup work.
- **Token:** read with `LocalStorage.getToken()` and pass via `options.headers['Authorization']`. The `DioClient` already sets it globally via `setToken`, but per-call injection is the dominant defensive pattern.
- **Parsing:** narrow `response.data` to `Map` before reaching into it; pass `Map<String, dynamic>.from(...)` into `Model.fromJson`. Never call `fromJson` on an unchecked dynamic.
- **Return:** typed model on success; `null` / `[]` / `false` sentinel on any failure (see §3).

---

## 2. Data Queries & Persistence

> **There is no application database.** No SQL, no Firestore reads, no Hive, no Drift. All structured data is HTTP-mediated. The only local persistence is `SharedPreferences` for three flat values.

### Local persistence — `lib/data/services/local_storage.dart`

```dart
class LocalStorage {
  static const String themeKey = "theme_mode";
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future setToken(String token) async {
    await _prefs.setString("token", token);
  }
  static String? getToken() => _prefs.getString("token");
  static Future clearToken() async {
    await _prefs.remove("token");
    await _prefs.remove("doc_upload_status");
  }

  static Future setOnboardingDone() async {
    await _prefs.setBool("onboardingDone", true);
  }
  static bool isOnboardingDone() {
    return _prefs.getBool("onboardingDone") ?? false;
  }
}
```

### Rules for `LocalStorage`

- All methods `static`. The `_prefs` field is initialised exactly once, from `lib/main.dart` (`await LocalStorage.init();`) before `runApp`.
- One read + one write method per key. Never call `SharedPreferences.getInstance()` from outside this class.
- Sentinel defaults for nullable types (`?? false`, `?? ""`).
- Clear related keys together (`clearToken` also clears `doc_upload_status`).

### JSON → object (the closest thing to a "query")

Models live in `lib/data/model/`. Each has a manual `factory fromJson(...)` and **no `toJson`** — outbound payloads are inline `Map<String, dynamic>` literals built in the service.

`lib/data/model/quote_model.dart`:

```dart
class QuoteModel {
  final String outcomeSlug;
  final double costGhs;
  final double shares;
  // … other doubles …

  QuoteModel({required this.outcomeSlug, required this.costGhs, /* … */ });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => (v is num) ? v.toDouble() : 0.0;

    return QuoteModel(
      outcomeSlug: json['outcome_slug']?.toString() ?? '',
      costGhs: n(json['cost_ghs']),
      shares: n(json['shares']),
      // …
    );
  }
}
```

### Rules for models

- All fields `final`; `required` named params in the constructor.
- Single `factory ModelName.fromJson(Map<String, dynamic> json)`.
- Defensive defaults: `?? ''` for strings, `?? 0` / `0.0` for numbers, `?? false` for bools. **Do not** ship a model that throws on a missing key. (`CountryModel` and `ChartData` are existing offenders — do not copy them.)
- Snake-case JSON keys → camelCase Dart fields, mapped manually inside `fromJson`.
- No code generation. No `freezed`, `json_serializable`, `build_runner`. Keep models hand-written.
- Numeric/date-shaped fields are sometimes deliberately kept as `String` (e.g., `TradeModel.minTradeAmount`, `endDate`) — parse at the call site.

---

## 3. Error Handling

### Pattern A — sentinel return (read-only endpoints)

From `lib/data/services/trade_quote_service.dart`:

```dart
try {
  // … HTTP call …
  if (response.statusCode == 200 && response.data is Map) {
    // parse + return
  }
  return null;
} on DioException catch (e) {
  print('TradeQuoteService DioException: ${e.message}; '
      'response=${e.response?.data}');
  return null;
} catch (e) {
  print('TradeQuoteService error: $e');
  return null;
}
```

### Pattern B — typed envelope return (mutating endpoints with business errors)

From `lib/data/services/trade_buy_service.dart`:

```dart
} on DioException catch (e) {
  // Backend ships typed error codes in the response body for the
  // 402 / 403 / 409 / 422 paths (see TradeController::errorFor).
  //   INSUFFICIENT_FUNDS → "Top up wallet" CTA
  //   KYC_REQUIRED       → push KYC screen
  //   MARKET_CLOSED      → close sheet + refresh detail
  //   BELOW/ABOVE_*COST  → in-line cost validation hint
  //   UNKNOWN_OUTCOME    → developer bug; show generic
  final body = e.response?.data;
  print('TradeBuyService DioException: ${e.message}; response=$body');
  if (body is Map) {
    return BuyResponse.fromJson(Map<String, dynamic>.from(body));
  }
  return BuyResponse.networkFailure(e.message);
} catch (e) {
  print('TradeBuyService error: $e');
  return BuyResponse.networkFailure();
}
```

### Rules

- **Always wrap network calls in `try/catch`.** Catch `DioException` *first*, then a general `catch (e)`. Don't let exceptions cross the service boundary.
- **Read-only / lookup endpoints** → return `null` (single) / `[]` (list) / `false` (bool) on failure. Caller checks for the sentinel.
- **Mutating endpoints with business-level error codes** → return a typed envelope (see `BuyResponse` in §10). The UI inspects `response.code` to branch.
- **Logging:** `print('<ServiceName> <kind>: …')` with the error and (when available) `e.response?.data`. There are ~202 `print`/`debugPrint` calls today — no structured logger, no crash-reporting SDK. The audit recommends adding one; until then, follow the existing convention.
- **Never** `rethrow` from a service. The contract is "service returns a typed result; UI never sees an exception."
- **Never** show raw exception text to the user. Map the typed `code` to a user-readable message in the screen layer.

---

## 4. Auth / Token Injection (Client-Side "Middleware")

There is no server-side middleware in this repo. The closest equivalent is the `DioClient` singleton, which holds the bearer token on its shared `Authorization` header.

### `lib/core/network/dio_client.dart`

```dart
class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? "",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {"Accept": "application/json"},
    ),
  );

  static Dio get instance => _dio;

  static void setToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  static void removeToken() {
    _dio.options.headers.remove("Authorization");
  }

  static Dio get multipartInstance {
    final multipartDio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? "",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {"Accept": "application/json"},
      ),
    );
    if (_dio.options.headers.containsKey("Authorization")) {
      multipartDio.options.headers["Authorization"] =
          _dio.options.headers["Authorization"];
    }
    return multipartDio;
  }
}
```

### Token lifecycle

| Stage | Where |
|-------|-------|
| Issue | `AuthService.verifyLoginOtp()` / `AuthService.verifyOtp()` (registration) receive the token in the response. |
| Persist | `LocalStorage.setToken(token)` |
| Apply globally | `DioClient.setToken(token)` |
| Use per-call | Service injects `'Authorization': 'Bearer $token'` into `Options.headers` defensively (see §1) — even though `DioClient` already has it set. Follow this convention. |
| Validate | `MainScreen` polls `AuthService.verifyToken()` every **300 s** (`lib/presentation/screens/main_screen.dart:58`). On `false`, shows a "Session Expired" dialog and bounces to login. |
| Revoke | `AuthService.logout()` POSTs `/logout`, then `LocalStorage.clearToken()` + `DioClient.removeToken()`. |

### Rules

- The unauthenticated routes are `/register`, `/verify-otp/register`, `/login`, `/verify-otp/login`, `/countries`. Every other call must carry the bearer header.
- Never read the token from `SharedPreferences` directly. Always go through `LocalStorage.getToken()`.
- Multipart uploads use `DioClient.multipartInstance`, which copies the current `Authorization` header into a fresh `Dio` with a longer timeout (30 s).

---

## 5. Environment Variables & Config

### `lib/core/config/env_config.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception("BASE_URL not found in .env");
    }
    return url;
  }
}
```

### Rules

- **One sanctioned reader of `dotenv`: `EnvConfig`.** New env vars get a new getter on this class.
- **Validate at read time.** If the value is missing or empty, throw — fail fast at startup rather than producing mysterious empty-URL requests.
- **Loading happens once,** in `lib/main.dart`: `await dotenv.load(fileName: ".env");` before `runApp`.
- **Direct `dotenv.env['…']` reads are a code smell.** `dio_client.dart:27` does this (legacy); the audit flags it as cleanup. Don't add new direct reads.
- `.env` lives at the repo root and is bundled as a Flutter asset via `pubspec.yaml`. **Currently committed to git** — see audit §9 before adding any new key.

### Adding a new env var (checklist)

1. Add the line to `.env`.
2. Add a getter to `EnvConfig` that validates non-empty.
3. Read it via `EnvConfig.yourKey` everywhere — never via `dotenv.env[...]`.
4. Note it in `docs/ARCHITECTURE.md` §10 and `docs/ACCESS.md`.

---

## 6. Feature Folder Organisation

A feature spans **three layers**; the trade-buy flow is the cleanest example.

```
lib/
├── presentation/
│   └── screens/
│       └── trade/                                ← UI
│           └── trade_page.dart
│           └── trade_details_page.dart
│
├── data/
│   ├── provider/
│   │   ├── trade_provider.dart                   ← state (ChangeNotifier)
│   │   └── trade_detail_provider.dart
│   ├── services/
│   │   ├── trade_service.dart                    ← HTTP
│   │   ├── trade_quote_service.dart
│   │   ├── trade_buy_service.dart
│   │   └── trade_details_service.dart
│   └── model/
│       ├── trade_model.dart                      ← DTOs
│       ├── trade_detail_model.dart
│       ├── quote_model.dart
│       ├── order_model.dart
│       └── buy_response.dart
│
└── core/                                          ← cross-cutting only
    ├── config/        api_endpoint.dart
    ├── network/       dio_client.dart
    ├── theme/         app_colors.dart, app_text_style.dart
    └── utils/         validators/, animations/
```

### Rules

- **One folder per feature under `presentation/screens/`.** Subfolders are allowed (e.g. `portfolio/deposit/`, `portfolio/withdraw/`).
- **Match each screen folder with sibling `provider/`, `service/`, `model/` files** by the same feature name (`trade_*`). Multiple files per feature are fine.
- **Cross-feature widgets** go in `lib/presentation/widget/`. Feature-only widgets stay co-located with the screen.
- **No business logic in `core/`.** It is for env, network, theme, and pure utilities only.
- **No barrel files.** No `index.dart` re-exports. Each consumer imports the specific file it needs.
- The widget tree never imports a service directly except for two pre-existing exceptions documented in the audit (`verify_account.dart`, `trade_page.dart`). Don't add a third — go through a provider.

---

## 7. Tests

> **The test suite is broken today.** `flutter test` fails on `main` because `test/widget_test.dart` is the unmodified `flutter create` scaffold and asserts on widgets (`find.text('0')`, `find.byIcon(Icons.add)`) that don't exist in `MyApp` (which renders `SplashScreen`). There is no `integration_test/` folder and no mocking package in `dev_dependencies`.

### What exists today (do not extend this — replace it)

`test/widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:betrade/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

### Target shape for the first real test (smoke test)

When you add the first real test, follow this layout. (Not yet committed.)

```dart
// test/app_smoke_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:betrade/data/provider/theme_provider.dart';
// …other providers as needed…
import 'package:betrade/presentation/screens/splash/splash_screen.dart';

void main() {
  testWidgets('App boots and renders the splash screen', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          // mock the rest of the providers used by SplashScreen
        ],
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
```

### Target shape for a service unit test (with `mocktail`)

```dart
// test/services/trade_quote_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
// …

class _MockDio extends Mock implements Dio {}

void main() {
  group('TradeQuoteService.quote', () {
    test('returns QuoteModel on 200 with status=true', () async {
      // arrange a mock Dio, stub .post, swap DioClient.instance via a seam
      // act
      // assert
    });

    test('returns null on DioException', () async { /* … */ });
  });
}
```

### Rules

- **Framework:** `flutter_test` (already in `dev_dependencies`).
- **First add:** `mocktail` (preferred over `mockito` — no codegen) and `integration_test` for E2E.
- **File naming:** `<thing_under_test>_test.dart`. One `void main()` per file; group related cases with `group(...)`.
- **Always assert behaviour, not implementation.** "What should happen?" not "what was called?"
- **Run before pushing:** `flutter test`. Failing tests block merge (per `CLAUDE.md`).
- **Coverage:** `flutter test --coverage` → `coverage/lcov.info` (gitignored).
- **Regression rule:** when a bug is found, add a test that fails on the broken behaviour *first*, then fix.

---

## 8. Background Jobs / Async Work

> **No server-side queues live in this repo.** No `WorkManager`, no isolates, no `flutter_background_service`. All client work runs on the main isolate, except the FCM background handler.

### Pattern A — periodic polling (`Timer.periodic`)

From `lib/presentation/screens/main_screen.dart:38–73`:

```dart
class _MainScreenState extends State<MainScreen> {
  Timer? _tokenTimer;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _startTokenChecker();
  }

  void _startTokenChecker() {
    _tokenTimer = Timer.periodic(const Duration(seconds: 300), (timer) async {
      try {
        final token = LocalStorage.getToken();
        if (token == null || token.isEmpty) return;
        final isValid = await AuthService().verifyToken(token);
        if (!mounted) return;
        if (isValid == true) return;
        if (isValid == null) {
          debugPrint("Token check skipped (network issue)");
          return;
        }
        if (isValid == false && !_isDialogShowing) {
          _isDialogShowing = true;
          _tokenTimer?.cancel();
          // … show "Session Expired" dialog …
        }
      } catch (_) { /* swallow */ }
    });
  }

  @override
  void dispose() {
    _tokenTimer?.cancel();
    super.dispose();
  }
}
```

### Pattern B — one-shot debounce (`Timer(...)`)

From `lib/presentation/screens/trade/trade_page.dart:167`:

```dart
_quoteDebounce?.cancel();
_quoteDebounce = Timer(const Duration(milliseconds: 200), _fetchQuote);
```

### Pattern C — FCM background isolate

From `lib/main.dart` — top-level function registered via `FirebaseMessaging.onBackgroundMessage(...)`:

```dart
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Runs in its own isolate when the app is terminated.
  // Keep it minimal — no providers, no UI.
}

void main() async {
  // …
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  // …
}
```

### Rules

- **Always cancel timers in `dispose()`.** Hold the `Timer?` as a state field, not a local.
- **Guard async continuations with `if (!mounted) return;`** before touching widget state.
- **One `Timer.periodic` per concern.** Don't multiplex multiple checks into one timer.
- **The FCM background handler must be a top-level (file-scope) function** annotated with `@pragma('vm:entry-point')`. It cannot be a closure, a method, or anything that captures state — it runs in a separate isolate with no shared memory.
- **Simulated "live" data:** `info_chart_screen.dart` uses a 700 ms `Timer.periodic` with a random walk to animate the chart. This is **not** a real backend stream; new "live data" features should call the backend, not fake motion locally.

---

## 9. Frontend Components (Reusable Widgets)

### Canonical example — `lib/presentation/widget/primary_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const PrimaryButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }
}
```

### Rules

- **`StatelessWidget` unless internal state is required.** Use `StatefulWidget` only for controllers, timers, focus, scroll, animations.
- **All inputs as `final` fields.** `const` constructor with `super.key`. Required fields go through `required`.
- **Sizing through `flutter_screenutil`.** Heights with `.h`, widths with `.w`, radii with `.r`, font sizes with `.sp`. Avoid hard-coded pixels.
- **Colours through `AppColors`** (`lib/core/theme/app_colors.dart`). Text through `AppTextStyle`. Use `AppColors.*Dynamic(context)` variants for dark-mode awareness.
  - `PrimaryButton` itself hard-codes `Colors.purple` / `Colors.deepPurple` — this is **pre-existing tech debt**. New widgets should pull from `AppColors`.
- **No HTTP, no providers, no `LocalStorage`** inside a widget in `lib/presentation/widget/`. Widgets receive data via constructor args and emit events via `VoidCallback` / `ValueChanged<T>` callbacks.
- **`CLAUDE.md` rules for design** (Impeccable Frontend Design): no Inter/Arial/Roboto, no pure gray, no nested cards, no gray text on coloured backgrounds, no bounce/elastic easing. Don't default to purple gradients on new surfaces — pick from the palette in `AppColors`.

### Provider consumption in screens

```dart
// One-off mutation
context.read<TradeProvider>().fetchTrades();

// Reactive rebuild on a specific provider
Consumer<TradeProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return const CircularProgressIndicator();
    return ListView.builder(/* … */);
  },
)

// Watch + rebuild for simple cases
final theme = context.watch<ThemeProvider>();
```

- Kick off fetches in `initState` via `WidgetsBinding.instance.addPostFrameCallback((_) { … })` so the first frame paints loading state before the request fires.

---

## 10. API Response Format (Success + Error Shapes)

The backend returns JSON envelopes. The client parses them via typed wrappers in `lib/data/model/`.

### Success envelope

```jsonc
{
  "status": true,
  "message": "Order placed",
  "data": {
    "order":  { "shares": 123.45, "avg_fill_price": 0.405, "total_cost_ghs": 50.0, "fee_ghs": 0.5 },
    "quote":  { /* QuoteModel shape */ },
    "wallet_balance": 450.0
  }
}
```

### Typed error envelope

```jsonc
{
  "status": false,
  "message": "Insufficient funds",
  "code":   "INSUFFICIENT_FUNDS"
}
```

Known typed codes (from `TradeBuyService` comments — backend `TradeController::errorFor`):

| Code | Meaning |
|------|---------|
| `INSUFFICIENT_FUNDS` | Wallet too low → show "Top up" CTA |
| `KYC_REQUIRED` | KYC not complete → push KYC screen |
| `MARKET_CLOSED` | Cannot trade → close sheet + refresh detail |
| `BELOW_MIN_COST` | Cost below market minimum |
| `ABOVE_MAX_COST` | Cost above market maximum |
| `UNKNOWN_OUTCOME` | Client/server contract bug → show generic error |

### Canonical parser — `lib/data/model/buy_response.dart`

```dart
class BuyResponse {
  final bool success;
  final String? message;
  final String? code;
  final OrderModel? order;
  final QuoteModel? quote;
  final double? walletBalance;

  BuyResponse({
    required this.success,
    this.message,
    this.code,
    this.order,
    this.quote,
    this.walletBalance,
  });

  factory BuyResponse.fromJson(Map<String, dynamic> json) {
    final dataField = json['data'];
    final data = dataField is Map
        ? Map<String, dynamic>.from(dataField as Map)
        : null;

    OrderModel? order;
    QuoteModel? quote;
    double? walletBalance;

    if (data != null) {
      if (data['order'] is Map) {
        order = OrderModel.fromJson(Map<String, dynamic>.from(data['order'] as Map));
      }
      if (data['quote'] is Map) {
        quote = QuoteModel.fromJson(Map<String, dynamic>.from(data['quote'] as Map));
      }
      if (data['wallet_balance'] is num) {
        walletBalance = (data['wallet_balance'] as num).toDouble();
      }
    }

    return BuyResponse(
      success: json['status'] == true,
      message: json['message']?.toString(),
      code: json['code']?.toString(),
      order: order,
      quote: quote,
      walletBalance: walletBalance,
    );
  }

  factory BuyResponse.networkFailure([String? message]) => BuyResponse(
        success: false,
        message: message ?? 'Buy failed. Please try again.',
      );
}
```

### Rules

- **Top-level fields are flat:** `status` (bool), `message` (string), `code` (string, error-only), `data` (object, success-only).
- **`success` reads from `status == true`.** Never trust the HTTP status alone — the backend can return 200 with `status: false`.
- **Always provide a `networkFailure` factory** for the "no JSON body to parse" case (timeouts, DNS, malformed body).
- **Nested objects** (`data.order`, `data.quote`) get their own model with its own `fromJson`. Compose, don't flatten.
- **List endpoints** return `{ status, message, data: [...] }` — parse with `(body['data'] as List).map((e) => Model.fromJson(...)).toList()`.

---

## 11. Naming Conventions

### Files

- **Dart files:** `snake_case.dart` — e.g. `trade_quote_service.dart`, `primary_button.dart`.
- **Model files:** `<name>_model.dart` matching `<Name>Model` class.
- **Service files:** `<name>_service.dart` matching `<Name>Service` class.
- **Provider files:** `<name>_provider.dart` matching `<Name>Provider` class.
- **Pre-existing exceptions** (do not replicate, do not rename in-flight either — see audit §11):
  - `HomeScreen.dart`, `OTP_step.dart`, `Payment_method.dart`, `Gender_step.dart`, `Common_header_withlogo.dart`, `customSnackBar.dart` — wrong case.
  - `step_indecator.dart`, `step_heder.dart`, `achivement_Sheet.dart` — typos.
  - `api_endpoint..dart` — double-dot typo propagated to 7 importers; preserve when importing existing references.
  - `graph_model.dart` defining `ChartData` — filename doesn't match class.

### Classes & members

- **Classes:** `PascalCase` — `TradeQuoteService`, `BuyResponse`, `PrimaryButton`.
- **Public members:** `camelCase` — `getProfile`, `walletBalance`.
- **Private members:** `_camelCase` — `_tokenTimer`, `_isDialogShowing`, `_fixAvatar`, `_prefs`.
- **Constants:** `camelCase` (`themeKey`), not `SCREAMING_SNAKE_CASE`.
- **Booleans:** prefix with `is` / `has` / `should` — `isLoading`, `isOnboardingDone`, `hasMore`.
- **Future-returning methods:** verb names — `quote`, `buy`, `getTrades`. Not `fetchQuoteAsync` (the `Future` return type already says so).

### JSON ↔ Dart

- **Wire format (JSON):** `snake_case` keys — `outcome_slug`, `avg_price_per_share`, `wallet_balance`.
- **Dart fields:** `camelCase` — `outcomeSlug`, `avgPricePerShare`, `walletBalance`.
- **Mapping is manual** inside `fromJson` — no codegen.

### URL paths

- **REST paths:** kebab-case or single-word — `/verify-otp/login`, `/edit-profile`, `/trade/list`, `/trade/categories-list`, `/userDefaultSettings/index` (the last is an outlier; new endpoints should be kebab-case).
- **Path params:** `{uuid}`, `{market_uuid}`.
- **Query params:** snake_case — `?type=deposit&page=2`.

### "Database columns"

There are no client-owned columns. Backend column names are observable only via JSON keys; they follow snake_case (e.g. `avg_fill_price`, `cost_ghs`, `closing_date_time`). The `_ghs` suffix is a Ghanaian Cedi unit marker on monetary fields.

---

## 12. Import / Export Patterns

Dart does not have "default vs named exports" — every import resolves a top-level identifier. There are two conventions in this codebase.

### Convention A — relative imports for in-feature siblings

From `lib/data/services/trade_quote_service.dart`:

```dart
import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/quote_model.dart';
import 'local_storage.dart';
```

### Convention B — `package:` imports for cross-feature jumps

From `lib/presentation/screens/main_screen.dart`:

```dart
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/explore/explore_page.dart';
import 'package:betrade/presentation/screens/homeScreen/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/local_storage.dart';
```

### Rules

- **Package imports come first**, then a blank line, then relative imports. (Soft convention — some files mix them.)
- **Sibling imports stay relative:** `import 'local_storage.dart';` inside `services/` referring to another services file.
- **Cross-feature imports** can be either relative (`../../data/provider/...`) or `package:betrade/...`. Both are present in the codebase. Pick relative when the consumer is close to the target; pick `package:` when traversing multiple levels.
- **External packages:** `package:dio/dio.dart`, `package:flutter/material.dart`, `package:flutter_screenutil/flutter_screenutil.dart`, etc.
- **No barrel files.** No `index.dart` that re-exports a folder. Each import points at the file that declares the symbol.
- **No `show` / `hide` clauses** are in current use. Add one only when there's a real conflict — don't pre-emptively narrow imports.
- **No path aliases.** Dart honours `package:betrade/...` as the project's root alias (driven by `pubspec.yaml`'s `name:`). There is no `tsconfig`-style alias map.

### What to import vs avoid

| Import this | Avoid |
|-------------|-------|
| `EnvConfig.baseUrl` | `dotenv.env['BASE_URL']` (legacy) |
| `ApiEndpoints.xxx(...)` | Hard-coded URLs |
| `DioClient.instance` / `multipartInstance` | A second `Dio()`; new `package:http` calls |
| `LocalStorage.getToken()` | `SharedPreferences.getInstance()` outside `local_storage.dart` |
| `AppColors.*` / `AppTextStyle.*` | Inline `TextStyle(...)`, literal `Color(0x…)`, raw `Colors.purple` |
| `flutter_screenutil` extensions (`.h`, `.sp`) | Hard-coded `double` pixel values |

---

**End of style guide.** Every pattern documented above has a real instance at the cited file path. When introducing a new pattern (or when an existing one is split into a "right" and "wrong" variant), update this document in the same PR.
