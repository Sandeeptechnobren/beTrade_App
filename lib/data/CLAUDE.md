# lib/data/

## Purpose
Data layer of the app. Three sibling folders: `model/` (DTOs decoded from API JSON), `provider/` (ChangeNotifiers holding UI-relevant state), and `services/` (static-method API + storage clients). No UI code lives here.

## Key files
- `model/trade_model.dart` — `TradeModel`, the canonical DTO pattern (manual `fromJson`, defensive `?? ""` defaults).
- `model/profile_model.dart` — `ProfileModel` with `_fixAvatar` helper that strips a duplicated `https://` prefix bug from the backend.
- `provider/explorer_provider.dart` — `ExploreProvider`, the canonical provider pattern (lines 137+ — earlier comment blocks are stale).
- `provider/signIn_provider.dart` — `AuthProvider`, the legacy sign-in pipeline that bypasses `EnvConfig` and `AuthService` (uses inline `http` calls with hard-coded URLs).
- `services/local_storage.dart` — `LocalStorage` SharedPreferences wrapper. Initialised once in `lib/main.dart` before `runApp`. Stores `token`, `theme_mode`, `onboardingDone`.
- `services/auth_service.dart` — `AuthService` (Dio-based) for sign-up, KYC submission, logout, token verification. Mixes instance methods with one static.
- `services/trade_service.dart` — `TradeService.getAllTrades()`, the canonical service pattern (`http` + `EnvConfig` + `ApiEndpoints`).

## Data flow
- Inbound: provider methods invoked from `lib/presentation/*` via `context.read<T>()` / `context.watch<T>()` / `Consumer<T>`.
- Outbound: services call the backend via `http` or `lib/core/network/DioClient`; models populate from JSON; providers expose the result and call `notifyListeners()` so consumers in `lib/presentation/*` rebuild.

## Dependencies
- Outbound: `lib/core/config/*`, `lib/core/network/dio_client.dart`; packages `http`, `dio`, `provider`, `shared_preferences`.
- Inbound: `lib/main.dart` (registers all providers in `MultiProvider`); `lib/presentation/*` (consumes providers and, for a few screens, calls services directly — e.g., `verify_account.dart` for KYC submit, `trade_page.dart` `initState` for trade detail).

## Conventions
See sub-folder `CLAUDE.md` files for specifics:
- `data/model/CLAUDE.md` — DTO conventions.
- `data/provider/CLAUDE.md` — ChangeNotifier conventions.
- `data/services/CLAUDE.md` — service / HTTP / storage conventions.

Cross-cutting: most public state on providers is mutable fields (not getters); services use try/catch + sentinel returns (`[]`, `null`, `false`); error logging is `print` / `debugPrint`.

## Common commands
None module-specific.
