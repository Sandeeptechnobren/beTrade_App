# lib/data/

## Purpose
Data layer of the app. Three sibling folders: `model/` (DTOs decoded from API JSON), `provider/` (`ChangeNotifier`s holding UI-relevant state), and `services/` (static-method API + storage clients). No UI code here.

## Key files
- `model/trade_model.dart` — `TradeModel`. Canonical DTO pattern (manual `fromJson`, defensive `?? ""` defaults).
- `model/buy_response.dart` — `BuyResponse`. Canonical typed-error-envelope pattern (`success` / `message` / `code` / nested `OrderModel?` + `QuoteModel?` + `walletBalance?`). Models how the trade-buy flow surfaces typed backend codes (`INSUFFICIENT_FUNDS`, `KYC_REQUIRED`, …).
- `model/quote_model.dart` — `QuoteModel`. LMSR quote DTO with defensive `_double()` helper for numeric fields.
- `provider/trade_detail_provider.dart` — canonical provider for the buy flow (calls `TradeQuoteService` + `TradeBuyService`).
- `provider/signIn_provider.dart` — `AuthProvider`. **Legacy** sign-in pipeline that bypasses `EnvConfig` and `AuthService` (inline `http` + hard-coded URLs). Don't replicate.
- `services/local_storage.dart` — `LocalStorage` SharedPreferences wrapper. Initialised once in `lib/main.dart` before `runApp`. Stores `token`, `theme_mode`, `onboardingDone`, `doc_upload_status`.
- `services/trade_quote_service.dart` — canonical service for read-only LMSR pricing (returns `QuoteModel?` with `null` sentinel on failure).
- `services/trade_buy_service.dart` — canonical service for mutating endpoints with typed error envelopes; also defines `generateIdempotencyKey()` (UUID v4) used per "Buy" tap.

## Data flow
- Inbound: provider methods invoked from `lib/presentation/*` via `context.read<T>()` / `context.watch<T>()` / `Consumer<T>`.
- Outbound: services call the backend at `api.buildacademy.io` via `DioClient` (or legacy `http`); models decode JSON; providers expose results and `notifyListeners()`.

## Dependencies
- Outbound: `lib/core/config/*`, `lib/core/network/dio_client.dart`; packages `http`, `dio`, `provider`, `shared_preferences`.
- Inbound: `lib/main.dart` (registers all providers in `MultiProvider`); `lib/presentation/*` (consumes providers; two screens bypass providers and call services directly — `verify_account.dart` for KYC, `trade_page.dart` for live quoting).

## Conventions
See sub-folder `CLAUDE.md`s for specifics (`model/`, `provider/`, `services/`). Cross-cutting:
- Providers expose **public mutable fields** (not getters) for `isLoading`, `error`, data.
- Services use `try/catch` + sentinel returns (`[]`, `null`, `false`) **or** typed envelopes (`BuyResponse`) for mutating endpoints with business errors.
- Logging is `print` / `debugPrint` only — ~202 calls across services. No structured logger yet.

## Common commands
None module-specific.
