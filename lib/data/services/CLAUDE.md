# lib/data/services/

## Purpose
API and persistence layer. Seven classes that handle outbound HTTP calls and local storage. Most services are abstract classes with `static` methods; each method owns URL construction, auth-token injection, JSON decoding, and error handling. There is no shared API client wrapper.

## Key files
- `local_storage.dart` — `LocalStorage` SharedPreferences wrapper. Initialised in `lib/main.dart` via `LocalStorage.init()`. Methods: `setToken`/`getToken`/`clearToken`, `saveThemeMode`/`getThemeMode`, `setOnboardingDone`/`isOnboardingDone`. Single source of truth for the auth token.
- `auth_service.dart` — `AuthService`. **Dio-based**. Sign-up + KYC pipeline: `sendOtp`/`verifyOtp` (register), `completeSignup` (multipart, via `DioClient.multipartInstance`), `logout`, `verifyToken`, `fetchChartData` (defined but never called). Mixes instance + static.
- `profile_service.dart` — `ProfileService`. **`http`-based**. `getProfile` (GET `/profile`) and `updateProfile` (multipart PUT `/edit-profile`). Branches explicitly on 200/401/404; clears token on 401.
- `trade_service.dart` — `TradeService`. **`http`-based**. `getTrades`/`getAllTrades` calling `/trade/list?page=N` via `ApiEndpoints.tradeList`. Canonical example for new services.
- `explorer_service.dart` — `ExploreService`. `searchTrades(query)` calling `/trade/explore?search=Q`. **Hard-codes the URL** instead of using `ApiEndpoints.searchTrades(query)` — don't replicate.
- `trade_details_service.dart` — `TradeDetailService`. `getTradeDetail(uuid)` calling `/trade/view/{uuid}` via **hard-coded URL**.
- `category_service.dart` — `CategoryService`. `getCategories` calling `/trade/categories-list` via `ApiEndpoints.categories`.

## Data flow
Provider calls `Service.method()` → service reads token via `LocalStorage.getToken()` → builds URL via `ApiEndpoints` (or hard-coded literal) → `http.get/post` or `DioClient.instance` call → `jsonDecode(response.body)` → parse via `Model.fromJson` → return model or sentinel.

## Dependencies
- Outbound: `http`, `dio`, `shared_preferences` (via `local_storage`); `lib/core/config/{env_config, api_endpoint..}`, `lib/core/network/dio_client`, `lib/data/model/*`.
- Inbound: `lib/data/provider/*` (most callers), plus a few presentation screens that bypass providers (`lib/presentation/screens/verification/verify_account.dart`, `lib/presentation/screens/trade/trade_page.dart`).

## Conventions
- Abstract class with `static` methods is the dominant shape (`AuthService` is the exception with one static + several instance methods).
- Per-call try/catch with `print`/`debugPrint` and emoji-prefixed status logs (e.g., `📌`, `✅`, `❌`).
- Sentinel returns: `[]` for `Future<List<T>>`, `null` for `Future<T?>`, `false` for `Future<bool>`.
- Token injection per request: `String? token = LocalStorage.getToken();` then `headers: {"Authorization": "Bearer $token", "Accept": "application/json"}`.
- Multipart uploads: `http.MultipartRequest` (in profile/KYC paths) or `DioClient.multipartInstance` (in `auth_service`).
- For new code, prefer `http` + `EnvConfig` + `ApiEndpoints` (the dominant pattern); avoid hard-coded URLs.

## Common commands
None module-specific.
