# Betrade — Patterns & Style Guide

- **Source**: `github.com/Sandeeptechnobren/beTrade_App` — `main` branch (HEAD `6c546de`)
- **Date**: 2026-04-30
- **Companion docs**: [`CODEBASE_AUDIT.md`](./CODEBASE_AUDIT.md), [`ARCHITECTURE.md`](./ARCHITECTURE.md)

This document describes the patterns **as they exist in the codebase today**. It is a snapshot of conventions in use, not a prescriptive ideal. Where the codebase has multiple competing variants of the same pattern (it does, in several places), the canonical example is the variant that's repeated most often and the alternative is noted under "Variants in the codebase".

A few patterns commonly found in style guides do not apply to this codebase (no relational database, no backend routing, no background-job framework, no real frontend/backend split) — those sections explain what's used in their place.

---

## 1. How a typical API call is structured

The dominant pattern is a **service class with `static` methods** that bundle three concerns: read the auth token from `LocalStorage`, build the URL via `ApiEndpoints`, and parse the response into a model. The `http` package is used directly inside each method (no shared client wrapper).

**Canonical example** — `lib/data/services/trade_service.dart:47-85` (`TradeService.getAllTrades`):

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_endpoint.dart';
import '../model/trade_model.dart';
import 'local_storage.dart';

class TradeService {
  static Future<List<TradeModel>> getAllTrades() async {
    try {
      String? token = LocalStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndpoints.tradeList(1)),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == true) {
          final List list = decoded['data']['items'];
          return list.map((e) => TradeModel.fromJson(e)).toList();
        } else {
          throw Exception("API status false");
        }
      } else {
        throw Exception("Failed to load trades");
      }
    } catch (e) {
      print("EXPLORE ERROR: $e");
      return [];
    }
  }
}
```

**Shape of a service method**:
1. Open `try`.
2. `String? token = LocalStorage.getToken();`.
3. `await http.{get|post|put}(Uri.parse(ApiEndpoints.<name>), headers: {Authorization: "Bearer $token", Accept: "application/json"})`.
4. Branch on `response.statusCode == 200`.
5. `jsonDecode(response.body)` → check `decoded['status'] == true` (the backend's success flag).
6. Map JSON → model with `Model.fromJson(e)`.
7. `catch (e)` → `print(...)` → return a sentinel (`[]`, `null`, or `false`).

**Variants in the codebase** (use the canonical pattern above for new code):

- `lib/data/services/auth_service.dart` uses `dio` instead of `http`, talking through `DioClient.instance`.
- `lib/data/provider/signIn_provider.dart` does its HTTP calls **inline in the provider** with **hard-coded URL literals**, bypassing both `EnvConfig` and any service class. This is the legacy sign-in pipeline and not the pattern to follow.
- Several services hard-code full URLs even when the endpoint exists in `ApiEndpoints` (e.g., `ExplorerService` hard-codes `/trade/explore` while `ApiEndpoints.searchTrades(query)` is defined and unused).

---

## 2. How "queries" are written (no DB — JSON parsing & SharedPreferences)

There is **no database, no ORM, no SQL, and no query language** in this codebase. The two persistence-style operations are (a) decoding API JSON into Dart models and (b) reading/writing key-value entries in `SharedPreferences`.

### 2a. JSON → model: manual `fromJson` factory constructor

**Canonical example** — `lib/data/model/trade_model.dart`:

```dart
class TradeModel {
  final String uuid;
  final String categoryName;
  final String description;
  final String minTradeAmount;
  final String? image;
  final String endDate;

  TradeModel({
    required this.uuid,
    required this.categoryName,
    required this.description,
    required this.minTradeAmount,
    this.image,
    required this.endDate,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    return TradeModel(
      uuid: json['uuid'] ?? "",
      categoryName: json['category_name'] ?? "",
      description: json['description'] ?? "",
      minTradeAmount: json['min_trade_amount'] ?? "",
      image: json['image'],
      endDate: json['end_date'] ?? "",
    );
  }
}
```

**Conventions**:
- All fields `final`. `required` named constructor params (or default-nullable for optional fields like `image`).
- One factory: `factory ModelName.fromJson(Map<String, dynamic> json)`.
- Defensive defaults: `?? ""` for required-on-the-Dart-side strings; nullable types for genuinely optional fields.
- Snake-case JSON keys map to camelCase Dart fields.
- **No `toJson()`** — outbound payloads are built ad-hoc as `Map<String, dynamic>` literals where the request is sent.
- No code generation (no `freezed`, no `json_serializable`, no `build_runner`).

**Variant**: `lib/data/model/country_model.dart`'s `fromJson` does **not** use `?? ""` defaults and will throw on a missing field. New models should follow `TradeModel`'s defensive pattern.

### 2b. SharedPreferences: thin static-method wrapper

**Canonical example** — `lib/data/services/local_storage.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String themeKey = "theme_mode";
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future setToken(String token) async {
    await _prefs.setString("token", token);
  }
  static String? getToken() {
    return _prefs.getString("token");
  }
  static Future clearToken() async {
    await _prefs.remove("token");
  }

  static Future setOnboardingDone() async {
    await _prefs.setBool("onboardingDone", true);
  }
  static bool isOnboardingDone() {
    return _prefs.getBool("onboardingDone") ?? false;
  }
}
```

**Conventions**:
- Single class with `static` methods. Initialised once via `LocalStorage.init()` (called from `lib/main.dart:26` before `runApp`).
- Per key: a `set<X>` (async) and a `get<X>` (sync) method. Default values handled in the getter (`?? false`).
- Keys are inline string literals or `static const String` constants.

**Anti-pattern in the codebase**: `lib/presentation/screens/homeScreen/HomeScreen.dart:102` calls `prefs.setBool('isFirstTime', …)` directly, bypassing `LocalStorage`. New code should add a method to `LocalStorage` instead.

---

## 3. How error handling is done

The single, repeated pattern: **per-call `try/catch`**, log via `print` / `debugPrint`, return a sentinel value. There is no centralised error handler, no logger package, no Dio interceptor, no shared `Result<T>` / `Either` type.

**Canonical example** — `lib/data/services/profile_service.dart:85-165` (abbreviated):

```dart
static Future<ProfileModel?> getProfile() async {
  try {
    String? token = LocalStorage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse(ApiEndpoints.profile),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // ... parse model ...
      return ProfileModel.fromJson(data['data']);
    }
    else if (response.statusCode == 401) {
      await LocalStorage.clearToken();
      return null;
    }
    else if (response.statusCode == 404) {
      return null;
    }
    else {
      return null;
    }
  } catch (e) {
    print("EXCEPTION in getProfile: $e");
    return null;
  }
}
```

**Conventions**:
- `try` wraps the entire body.
- Specific status codes are branched explicitly (`200`, `401`, `404`).
- **`401` is the only case where state is mutated** in response: `LocalStorage.clearToken()`. This is the closest thing to centralised auth-error handling.
- Sentinel returns by signature:
  - `Future<List<T>>` → `return []`
  - `Future<T?>` → `return null`
  - `Future<bool>` → `return false`
  - `Future<Map<String, dynamic>>` → `return {"success": false, "message": "Server error"}` (used in `signIn_provider.dart`)
- Errors are logged via `print` (services) or `debugPrint` (UI / `main.dart`). Both ship in production.
- Top-level Flutter errors are caught in `lib/main.dart:21-24` (`FlutterError.onError`) and `:47-52` (`runZonedGuarded`) — both also `debugPrint` only.

**Note**: this codebase uses heavy emoji-prefixed log lines (e.g., `📌`, `✅`, `❌`) inside `print` strings. This is consistent across `profile_service.dart`, `auth_service.dart`, and several providers; it is the project's existing convention for status-tagged logs.

---

## 4. How authentication is applied to routes

This is a **Flutter client**, so "applying auth to a route" means injecting the bearer token into outbound HTTP headers. There is no middleware abstraction; auth is applied at the call site of each request.

There are **two parallel injection patterns**.

### 4a. Per-request injection (the dominant pattern)

Each `http`-based service method reads the token from `LocalStorage` and inlines the header.

**Canonical example** — `lib/data/services/trade_service.dart:49-65`:

```dart
String? token = LocalStorage.getToken();
final response = await http.get(
  Uri.parse(ApiEndpoints.tradeList(1)),
  headers: {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
  },
);
```

This is repeated verbatim in `trade_service.dart`, `category_service.dart`, `explorer_service.dart`, `profile_service.dart`, `trade_details_service.dart`, plus the inline calls in `verify_account.dart`. **Use this pattern for new `http` calls.**

### 4b. Singleton-mutating injection (used by Dio paths)

`DioClient` keeps a shared `Authorization` header on its singleton. The token is set once after `verifyOtp` succeeds; subsequent Dio calls inherit it.

**Canonical example** — `lib/core/network/dio_client.dart:24-43`:

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
}
```

Caller (in `lib/data/services/auth_service.dart` after a successful OTP verification):
```dart
DioClient.setToken(token);
```

**Caveat**: the Dio singleton's auth header is **not restored on app launch** from a saved token. If new code uses Dio after a relaunch, it must call `DioClient.setToken(LocalStorage.getToken()!)` itself, or the request will be unauthenticated.

### 4c. Token freshness

Two policies coexist:
- **One-shot at launch** — `lib/presentation/screens/splash/splash_screen.dart:51` calls `AuthService.verifyToken(token)`.
- **Polling** — `lib/presentation/screens/main_screen.dart:55-150` runs `Timer.periodic(Duration(seconds: 10), …)`. See §8.

There is **no route guard / middleware** abstraction. Flow control is imperative: if `verifyToken` returns `false`, the screen calls `LocalStorage.clearToken()` and `Navigator.pushAndRemoveUntil(...AuthScreen())`.

---

## 5. How environment variables and config are accessed

Single source of truth: `flutter_dotenv` loads `.env` at startup, and a single `EnvConfig` class is the **only** sanctioned reader.

### 5a. Loading

**Canonical example** — `lib/main.dart:31-40`:

```dart
try {
  await dotenv.load(fileName: ".env");
  if (dotenv.env['API_BASE_URL'] == null) {
    debugPrint("API_BASE_URL missing, using default");
  }
} catch (e) {
  debugPrint("ENV Load Error: $e");
}
```

`.env` is also listed under `flutter.assets` in `pubspec.yaml:39`, so the file is bundled into the release artifact. (See [`CODEBASE_AUDIT.md`](./CODEBASE_AUDIT.md) for why this matters.)

### 5b. Reading

**Canonical example** — `lib/core/config/env_config.dart`:

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

**Conventions**:
- One static getter per env key. Throws on missing/empty.
- App code **never** reads `dotenv.env[...]` directly.
- All endpoint URLs derive from `EnvConfig.baseUrl` via `ApiEndpoints` (`lib/core/config/api_endpoint..dart`):
  ```dart
  static String get profile => '${EnvConfig.baseUrl}/profile';
  static String tradeList(int page) =>
      '${EnvConfig.baseUrl}/trade/list?page=${Uri.encodeComponent(page.toString())}';
  ```

**Anti-patterns to avoid** (present in the codebase but not the convention to follow):
- `lib/core/network/dio_client.dart:27` reads `dotenv.env['BASE_URL']` directly (instead of `EnvConfig.baseUrl`). New code should not duplicate this.
- `lib/main.dart:33` references `API_BASE_URL`, which is never defined in `.env`. Dead branch.
- Several call sites hard-code full `https://api.buildacademy.io/...` URL literals. Don't.

There is **no `--dart-define` / compile-time configuration** anywhere — confirmed by zero matches for `String.fromEnvironment` / `bool.fromEnvironment` in `lib/`.

---

## 6. How a feature/module is organised

A feature spans **three folders** under `lib/`, plus a screen folder for the UI. The naming is consistent across features.

For a feature named `<feature>` (e.g., `trade`, `profile`, `explorer`):

```
lib/
├── data/
│   ├── model/<feature>_model.dart           DTO with manual fromJson
│   ├── provider/<feature>_provider.dart     ChangeNotifier (state, loading, error)
│   └── services/<feature>_service.dart      Static methods that hit the API
└── presentation/
    └── screens/<feature>/<feature>_page.dart   Screens that read the provider
```

### Example: the "explore" feature

| Layer | File | Responsibility |
| --- | --- | --- |
| Model | `lib/data/model/trade_model.dart` | `TradeModel` DTO — explore reuses the trade model. |
| Service | `lib/data/services/trade_service.dart` and `lib/data/services/explorer_service.dart` | `TradeService.getAllTrades()` → list; `ExploreService.searchTrades(query)` → list. |
| Provider | `lib/data/provider/explorer_provider.dart` | `ExploreProvider extends ChangeNotifier` — holds `exploreTrades`, `searchResults`, `isLoading`, `isSearching`, `error`. |
| Screen | `lib/presentation/screens/explore/explore_page.dart` | `ExplorePage` widget; reads the provider via `context.watch<ExploreProvider>()`. |

### Provider shape

**Canonical example** — `lib/data/provider/explorer_provider.dart:137-199`:

```dart
class ExploreProvider extends ChangeNotifier {
  List<TradeModel> exploreTrades = [];
  List<TradeModel> searchResults = [];
  bool isLoading = false;
  bool isSearching = false;
  String error = "";

  Future<void> fetchExploreTrades() async {
    try {
      isLoading = true;
      error = "";
      notifyListeners();
      exploreTrades = await TradeService.getAllTrades();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // searchTrades(...), clearSearch(), refreshSearch() ...
}
```

**Conventions**:
- One `ChangeNotifier` per feature concern.
- Public mutable fields (no getters/setters): `isLoading`, `error`, the data list. Touch state, then `notifyListeners()`.
- Each async action: set loading flag → `notifyListeners()` → call service → set data/error in `try/catch/finally` → reset loading → `notifyListeners()`.
- Provider registered once globally in `lib/main.dart:60-71` via `MultiProvider` + `ChangeNotifierProvider(create: (_) => XxxProvider())`.

### Wiring into UI

```dart
// In a screen's initState, kick off the load:
SchedulerBinding.instance.addPostFrameCallback((_) {
  context.read<ExploreProvider>().fetchExploreTrades();
});

// In build(), watch for state changes:
final provider = context.watch<ExploreProvider>();
if (provider.isLoading) return const CircularProgressIndicator();
if (provider.error.isNotEmpty) return Text(provider.error);
return ListView(children: provider.exploreTrades.map(_card).toList());
```

(Reference: `lib/presentation/screens/explore/explore_page.dart:38-43, 240-269`.)

---

## 7. How tests are written

The test framework is **`flutter_test`**. There is currently **one** test file, and it is the unmodified default scaffold from `flutter create` — it does **not** test the actual app and **will fail** on `main`.

**Existing test** — `test/widget_test.dart`:

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

This asserts on a counter widget that does not exist in `MyApp` (which renders `SplashScreen`). It is included here for accuracy, **not** as a pattern to imitate. There is no real test pattern established yet; new tests should follow the standard `flutter_test` `testWidgets` API.

**No integration tests exist** — there is no `integration_test/` directory and `integration_test` is not a dev_dependency.

**No mocking library is configured** — `mockito`, `mocktail`, `bloc_test`, `fake_async` are all absent from dev_dependencies (only `flutter_test`, `flutter_lints`, and `flutter_launcher_icons`).

**How to run**: `flutter test` (unit/widget) or `flutter test --coverage` (writes `coverage/lcov.info`, gitignored).

---

## 8. How background jobs / queues are structured

The codebase has **no background-job framework** (no Workmanager, no Isolate workers, no `flutter_background_service`, no scheduled local notifications). The closest existing pattern is **foreground UI-thread polling** via `Timer.periodic`, used only for token validity.

**Canonical example** — `lib/presentation/screens/main_screen.dart:55-150` (abbreviated):

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
    _tokenTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final token = LocalStorage.getToken();
        if (token == null || token.isEmpty) return;
        final isValid = await AuthService().verifyToken(token);
        if (!mounted) return;
        if (isValid == true) return;
        if (isValid == null) return; // network issue — skip
        if (isValid == false && !_isDialogShowing) {
          _isDialogShowing = true;
          _tokenTimer?.cancel();
          // ... show "Session Expired" dialog and route to AuthScreen ...
        }
      } catch (e) {
        debugPrint("Token checker error: $e");
      }
    });
  }

  @override
  void dispose() {
    _tokenTimer?.cancel();
    super.dispose();
  }
}
```

**Conventions** (such as they are):
- Timer is held as a nullable field (`Timer? _tokenTimer`) on the `State`.
- Started in `initState`; cancelled in `dispose`.
- Body is `try/catch` with `debugPrint`.
- Guard with `if (!mounted) return;` after every `await`.
- One-shot dialogs guarded by a `bool _isDialogShowing` flag plus an explicit `_tokenTimer?.cancel()`.

A second, simpler use of `Timer.periodic` lives in `lib/presentation/screens/profile/info_chart_screen.dart`, where it mutates a `List<FlSpot>` to simulate live chart movement (no backend involvement).

For real background work (push notifications, scheduled syncs, long-running uploads), no pattern exists — adding one would require introducing a new package and a new convention.

---

## 9. How frontend components (widgets) are structured

This is a Flutter app, so "frontend components" means **`Widget` subclasses**. The codebase splits widgets into two homes:

- `lib/presentation/widget/` — small, generic, reusable widgets (buttons, headers, indicators).
- `lib/presentation/screens/<feature>/` — full-screen widgets and feature-specific compositions.

### 9a. Reusable, presentational widget (StatelessWidget)

**Canonical example** — `lib/presentation/widget/primary_button.dart`:

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
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
      ),
    );
  }
}
```

**Conventions for reusable widgets**:
- `extends StatelessWidget` when there's no internal state.
- All inputs as `final` fields with a `const` constructor.
- `super.key` in the constructor signature.
- `flutter_screenutil` extensions for sizing: `.h` (height), `.w` (width), `.r` (radius), `.sp` (font).
- Colors and text styles via `app_colors.dart` / `app_text_style.dart` for production widgets (this `PrimaryButton` predates that convention — see "Variant" below).

### 9b. Stateful screen widget consuming a provider

**Canonical example** — `lib/presentation/screens/explore/explore_page.dart` (excerpt):

```dart
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Timer? _debounce;
  bool _isDisposed = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        context.read<ExploreProvider>().fetchExploreTrades();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExploreProvider>();
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.error.isNotEmpty) return Center(child: Text(provider.error));
    // ... build the list ...
  }
}
```

**Conventions for screens**:
- `StatefulWidget` when there's local state (`Timer`, `TextEditingController`, focus, scroll).
- Public widget class + private `_State` class.
- Kick off async work in `initState` via `SchedulerBinding.instance.addPostFrameCallback` (not `Future.microtask` and not directly in `initState`).
- Always `dispose` controllers, timers, focus nodes.
- A `bool _isDisposed` flag is sometimes used in addition to `mounted` for extra safety after long async operations (see `explore_page.dart:23, 47`).
- Read the provider with `context.watch<T>()` in `build` (rebuilds on changes); use `context.read<T>()` for one-off action calls outside `build`.

### Theme & sizing tokens

Always use:
- `AppColors.<name>` or `AppColors.<name>Dynamic(context)` — `lib/core/theme/app_colors.dart`.
- `AppTextStyle.<name>` — `lib/core/theme/app_text_style.dart`.
- `flutter_screenutil` extensions (`.h`, `.w`, `.r`, `.sp`) over hard-coded pixels.

**Variant**: `primary_button.dart` uses `Colors.purple` directly instead of `AppColors`. New widgets should pull from `AppColors`/`AppTextStyle`.

### Navigation

All navigation is imperative (`Navigator.push` / `pushReplacement` / `pushAndRemoveUntil`) wrapped around `MaterialPageRoute(builder: (_) => Screen())`. There is no central route table.

---

## 10. How API responses are formatted

The Betrade backend returns JSON with **a consistent envelope shape**. The app reads three top-level keys: `status` (bool), `message` (string), and `data` (object or list).

### 10a. Success envelope

```json
{
  "status": true,
  "message": "OK",
  "data": { /* or [] */ }
}
```

**Read pattern** (from `lib/data/services/trade_service.dart:70-77`):

```dart
final decoded = jsonDecode(response.body);
if (decoded['status'] == true) {
  final List list = decoded['data']['items'];
  return list.map((e) => TradeModel.fromJson(e)).toList();
}
```

### 10b. Error envelope (server-flagged)

```json
{
  "status": false,
  "message": "Some error message"
}
```

**Read pattern** (from `lib/data/provider/signIn_provider.dart:29-32`):

```dart
return {
  "success": data['status'] == true,
  "message": data['message'] ?? "Something went wrong",
};
```

### 10c. HTTP-level errors

The app branches on `response.statusCode` with explicit cases (`200`, `401`, `404`) and falls through to a generic failure return for everything else. Only `401` triggers state mutation (`LocalStorage.clearToken()`).

### 10d. Provider-level result shape (for sign-in / sign-up flows)

When a provider needs to return both a flag and a message to a screen, the shape is a `Map<String, dynamic>` with `success`, `message`, and optional `data`:

```dart
return {
  "success": data['status'] == true,
  "message": data['message'] ?? "Something went wrong",
  "data": data['user'],
};
```

(Reference: `signIn_provider.dart:74-78`.) The screen reads `result['success']` and `result['message']`. There is no typed `Result<T>` class.

### 10e. Multipart upload responses

For uploads (`/edit-profile`, `/kyc/submit`, `/complete-profile`), the response is read via `response.stream.bytesToString()` then `jsonDecode`. The status is judged purely on `response.statusCode == 200`, not on the body's `status` field — see `lib/data/services/profile_service.dart:218-232`.

### Implicit nesting

The wrapper shape has minor variants the app accommodates inline. `profile_service.dart:117-128` checks for the profile under three possible keys (`data['data']`, `data['user']`, then the root `data`) — this is defensive parsing, not a documented contract.

---

## 11. Naming conventions

The codebase has clear conventions that are **mostly** followed; exceptions are documented in [`CODEBASE_AUDIT.md`](./CODEBASE_AUDIT.md) §11.

### 11a. Files

- Dart source: `snake_case.dart` (e.g., `trade_service.dart`, `app_colors.dart`).
- One public class per file; the filename matches the class name in snake_case.
- Layer-suffixed names: `*_service.dart`, `*_provider.dart`, `*_model.dart`, `*_screen.dart` / `*_page.dart`, `*_button.dart`.

### 11b. Classes & types

- `PascalCase` for classes, mixins, enums, and typedefs (e.g., `TradeModel`, `ExploreProvider`, `LocalStorage`, `AppColors`).
- One class per `.dart` file (with rare exceptions for tightly-coupled helpers).

### 11c. Members

- `camelCase` for fields, getters, methods, parameters, locals (e.g., `isLoading`, `fetchExploreTrades`, `firstName`).
- Private members: `_camelCase` with leading underscore (e.g., `_dio`, `_isDisposed`, `_tokenTimer`).
- Public boolean state: `is*` / `has*` prefix (`isLoading`, `isSearching`, `isOnboardingDone`).

### 11d. Constants

- `static const String themeKey = "theme_mode";` — camelCase for the Dart-side identifier, the underlying string is the actual `SharedPreferences` key.
- Endpoint builders in `ApiEndpoints` are `static String get name => …` getters (or `static String name(args) => …` functions when parameterised).

### 11e. JSON keys (wire format)

- Backend uses `snake_case` (e.g., `first_name`, `phone_code`, `min_trade_amount`, `end_date`).
- App-side fields are `camelCase`. The mapping happens inside each `fromJson`.

### 11f. API paths

- `kebab-case` segments and slashes (e.g., `/verify-otp/login`, `/edit-profile`, `/trade/categories-list`, `/profile/preferences`).
- Plural collection nouns (`/countries`, `/languages`); singular for an action verb (`/login`, `/logout`, `/register`).
- Query string for pagination/search (`/trade/list?page=N`, `/trade/explore?search=Q`).
- Path parameters are interpolated via Dart string interpolation, not declared in `ApiEndpoints` for the few endpoints that use them (e.g., `/trade/view/$uuid` is hard-coded — adding it to `ApiEndpoints` is recommended).

### 11g. SharedPreferences keys

- `snake_case` strings: `"theme_mode"`, `"token"`, `"onboardingDone"` (this last one is mixedCase and inconsistent — `"onboarding_done"` would be better; it is preserved as-is here for accuracy).

### 11h. Database columns

**N/A** — no database. Backend column conventions are observed only through API responses (snake_case).

### 11i. Known inconsistencies

(For accuracy. Do not perpetuate these in new code.)

- **Filename casing/spelling slips**: `HomeScreen.dart`, `Common_header_withlogo.dart`, `Payment_method.dart`, `OTP_step.dart`, `Gender_step.dart`, `stepPhone.dart`, `newDeposit.dart`, `signIn_provider.dart`, `signUp_provider.dart`, `theam_provider.dart` (`theam` → `theme`), `step_indecator.dart` (`indecator` → `indicator`), `step_heder.dart` (`heder` → `header`), `achivement_Sheet.dart` (`achivement` → `achievement`).
- **Filename typo**: `lib/core/config/api_endpoint..dart` (double dot). Imported by 7 files.

---

## 12. Import / export patterns

Dart uses `import` only — there are no "default vs named exports" as in JavaScript. The two questions that matter here are: (a) absolute vs relative imports, and (b) whether barrel files are used.

### 12a. Two import styles, both in active use

**Absolute (package-qualified)** — used in many top-level files:

```dart
import 'package:betrade/data/provider/category_provider.dart';
import 'package:betrade/presentation/screens/splash/splash_screen.dart';
```

(Reference: `lib/main.dart:1-4`.)

**Relative (`../../`)** — used inside `lib/data/` and `lib/core/` heavily:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_endpoint.dart';
import '../model/trade_model.dart';
import 'local_storage.dart';
```

(Reference: `lib/data/services/trade_service.dart:1-5`.)

**Convention observed**: relative imports for siblings and same-package neighbours; absolute (`package:betrade/...`) for cross-feature jumps. Both work; consistency within a single file is more important than picking one globally.

### 12b. Import ordering (de facto)

When both kinds appear in the same file, the order is generally:
1. `dart:` SDK imports (`dart:convert`, `dart:async`, `dart:io`).
2. `package:` external packages (`flutter/material.dart`, `http/http.dart`, `dio/dio.dart`, `provider/provider.dart`).
3. Project absolute imports (`package:betrade/...`).
4. Project relative imports (`../../...`, `../...`, `./...`).

This is not enforced by `analysis_options.yaml` but is what most files do.

### 12c. Aliased imports

Used only for `package:http/http.dart`:

```dart
import 'package:http/http.dart' as http;
```

(Always aliased to `http`. Reference: any file under `lib/data/services/`.)

`package:dio/dio.dart` is imported unaliased (`import 'package:dio/dio.dart';`).

### 12d. No barrel files

There is no `index.dart` / `barrel.dart` that re-exports a folder's contents. Each consumer imports each file it needs directly. This means a screen using `TradeModel`, `TradeService`, and `ExploreProvider` writes three separate import lines.

### 12e. Path aliases

There are **no path aliases** configured. Everything resolves through Dart's package system (`package:betrade/<path>`) or relative paths.

### 12f. Exports

There are no `export` statements anywhere in `lib/`. Each file exposes its declarations through `import` only.

---

*End of patterns document. This is a snapshot of the codebase's actual conventions as of HEAD `6c546de`. When patterns conflict (HTTP client choice, env-var access, navigation, etc.), the variant called out as "canonical" above is the one to follow for new work; "Variants" sections document what exists today but should not be replicated.*
