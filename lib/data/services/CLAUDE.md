# lib/data/services/

## Purpose
API and persistence layer. ~16 classes handling outbound HTTP and local storage. Each service is an abstract class with `static` methods; each method owns URL construction, auth-token injection, JSON decoding, and error handling. There is **no shared API client wrapper** beyond `DioClient`.

## Key files
- `local_storage.dart` — `LocalStorage` SharedPreferences wrapper. Initialised in `lib/main.dart` via `LocalStorage.init()`. Stores `token`, `theme_mode`, `onboardingDone`, `doc_upload_status`. Single source of truth for the auth token.
- `auth_service.dart` — Sign-up + KYC pipeline (Dio-based): `sendOtp`, `verifyOtp`, `completeSignup` (multipart via `DioClient.multipartInstance`), `logout`, `verifyToken`, `sendLoginOtp`, `verifyLoginOtp`, `saveFcmToken`. `fetchChartData` exists but is never called. Mixes static + instance methods.
- `profile_service.dart` — `getProfile` (GET `/profile`), `updateProfile` (multipart PUT). **`http`-based** legacy. Branches on 200/401/404; clears token on 401.
- `trade_service.dart` — `getTrades` / `getAllTrades` calling `/trade/list?page=N` via `ApiEndpoints.tradeList`.
- `trade_quote_service.dart` — canonical read-only service example. Returns `QuoteModel?` (`null` sentinel).
- `trade_buy_service.dart` — canonical mutating-endpoint example. Returns typed `BuyResponse` (with `code` for `INSUFFICIENT_FUNDS`, `KYC_REQUIRED`, `MARKET_CLOSED`, `BELOW_MIN_COST`, `ABOVE_MAX_COST`, `UNKNOWN_OUTCOME`). Includes `generateIdempotencyKey()` (UUID v4).
- `positions_service.dart`, `wallet_service.dart` — portfolio + wallet API calls.
- `explorer_service.dart`, `trade_details_service.dart` — **hard-code URLs** instead of using `ApiEndpoints`. Don't replicate.
- `category_service.dart` — `/trade/categories-list`.
- `notification_services.dart` — FCM token init + foreground/background message wiring (uses `flutter_local_notifications`).

## Data flow
Provider calls `Service.method()` → service reads token via `LocalStorage.getToken()` → builds URL via `ApiEndpoints` (or hard-coded literal) → `DioClient.instance` / `multipartInstance` → response decoded → `Model.fromJson` or typed envelope → return model or sentinel.

## Dependencies
- Outbound: `http`, `dio`, `shared_preferences` (via `local_storage`); `lib/core/config/*`, `lib/core/network/dio_client.dart`, `lib/data/model/*`.
- Inbound: `lib/data/provider/*` (most callers); `lib/presentation/screens/verification/verify_account.dart` (calls KYC + preferences directly); `lib/presentation/screens/trade/trade_page.dart` (calls trade detail directly).

## Conventions
- Abstract class with `static` methods is the dominant shape (`AuthService` is the lone exception).
- Per-call `try/catch` with `print` / `debugPrint` + emoji-prefixed logs (`📌`, `✅`, `❌`).
- Sentinel returns: `[]` for `Future<List<T>>`, `null` for `Future<T?>`, `false` for `Future<bool>`. Use typed envelopes (`BuyResponse`) for mutating calls with business errors.
- Token injection per-call: `headers: {'Authorization': 'Bearer $token'}` even though `DioClient` already sets it globally.
- Multipart uploads: `DioClient.multipartInstance` (preferred) or `http.MultipartRequest` (legacy in profile/KYC paths).
- New code: prefer `dio` + `EnvConfig` + `ApiEndpoints`. Avoid hard-coded URLs.

## Common commands
None module-specific.
