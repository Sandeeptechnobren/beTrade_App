# lib/data/provider/

## Purpose
State holders. ~14 `ChangeNotifier` classes that wrap async service calls and expose `isLoading` / `error` / data fields to the UI. All registered globally in `lib/main.dart` via `MultiProvider`. Consumers read via `context.watch<T>()` / `Consumer<T>` (reactive) or `context.read<T>()` (one-off mutation).

## Key files
- `signIn_provider.dart` — `AuthProvider`. Sign-in: `sendOtp`, `verifyOtp`. **Legacy** — calls `http` directly with hard-coded URLs, bypassing `EnvConfig` and `AuthService`. Returns `Map<String, dynamic>`. Don't replicate.
- `signUp_provider.dart` — `SignupProvider`. Sign-up; routes through `AuthService` (Dio path).
- `profile_provider.dart` — `ProfileProvider`. Holds `ProfileModel?`; calls `ProfileService.getProfile` / `updateProfile`.
- `explorer_provider.dart` — `ExploreProvider`. Holds `exploreTrades`, `searchResults`, `_lastSearchQuery`. Rejects stale debounced results. **Active class starts at line 137** — earlier comment blocks are stale versions.
- `trade_provider.dart` — `TradeProvider`. Trade list + client-side pagination (`_applyPagination`).
- `trade_detail_provider.dart` — `TradeDetailProvider`. Drives the live quote + buy flow; calls `TradeQuoteService` and `TradeBuyService`.
- `country_provider.dart` — `CountryProvider`. Hits `/countries` via Dio. Uses `_safeNotifyListeners` with `_isDisposed` guard. Active class is the **last** one in the file (4 stale versions precede it).
- `category_provider.dart` — `CategoryProvider`. Same dispose-safety pattern.
- `wallet_provider.dart`, `positions_provider.dart`, `default_amount_provider.dart`, `bottom_nav_provider.dart`, `login_provider.dart` — feature-scoped state holders.
- `theam_provider.dart` — `ThemeProvider`. **Filename misspelling** (`theam` → `theme`). Persists `ThemeMode` via `LocalStorage.saveThemeMode`; drives `Consumer<ThemeProvider>` at the `MaterialApp` root.

## Data flow
Screen calls `provider.method(...)` → `isLoading = true` + `notifyListeners()` → `await Service.staticMethod()` → store result in public field → `isLoading = false` + `notifyListeners()` in `finally`. UI's `Consumer<T>` / `context.watch<T>()` rebuilds.

## Dependencies
- Outbound: `lib/data/services/*`, `lib/data/model/*`, sometimes `lib/core/network/dio_client.dart` (e.g., `country_provider`); package `provider`.
- Inbound: `lib/main.dart` (registration); `lib/presentation/*` (consumption).

## Conventions
- `extends ChangeNotifier`; never extends another provider.
- Public mutable fields (no getters): `isLoading`, `error` (or `errorMessage`), the data list/object.
- `notifyListeners()` after every state mutation. Wrap async work in `try/catch/finally`; reset `isLoading` in `finally`.
- `CategoryProvider` + `CountryProvider` use `_safeNotifyListeners` with `_isDisposed` — others may emit notify-after-dispose warnings. New providers should replicate the safety pattern.
- `bottom_nav_provider.dart` is the only provider with no `error` field — pure UI state.

## Common commands
None module-specific.
