# lib/data/provider/

## Purpose
State holders. Nine `ChangeNotifier` classes that wrap async service calls and expose `isLoading` / `error` / data fields to the UI. All registered globally in `lib/main.dart` (`MultiProvider`, lines 60–71). Consumers read via `context.watch<T>()` / `Consumer<T>` (rebuild) or `context.read<T>()` (action).

## Key files
- `signIn_provider.dart` — `AuthProvider`. Sign-in: `sendOtp`, `verifyOtp`. **Legacy pattern** — calls `http` directly with hard-coded URLs, bypassing `EnvConfig` and `AuthService`. Returns `Map<String, dynamic>` with `success`/`message`/`data` keys.
- `signUp_provider.dart` — `SignupProvider`. Sign-up: routes through `AuthService` (Dio path) — the env-aware sibling of `AuthProvider`.
- `profile_provider.dart` — `ProfileProvider`. Holds `ProfileModel?`; calls `ProfileService.getProfile`/`updateProfile`.
- `explorer_provider.dart` — `ExploreProvider`. Holds `exploreTrades`, `searchResults`, `_lastSearchQuery`; debounce-aware (rejects stale results). **Active class starts at line 137** — earlier comment blocks are stale versions.
- `trade_provider.dart` — `TradeProvider`. Trade list + client-side pagination via `_applyPagination` (server only returns page 1).
- `country_provider.dart` — `CountryProvider`. Calls `/countries` via Dio; uses `_safeNotifyListeners` with `_isDisposed` guard. Active class is the *last* one in the file (4 stale versions precede it).
- `category_provider.dart` — `CategoryProvider`. Same dispose-safety pattern as `CountryProvider`.
- `bottom_nav_provider.dart` — `BottomNavProvider`. Just the current tab index.
- `theam_provider.dart` — `ThemeProvider`. **Filename misspelling** (`theam` → `theme`). Persists `ThemeMode` via `LocalStorage.saveThemeMode`. Drives `Consumer<ThemeProvider>` at the `MaterialApp` root in `main.dart`.

## Data flow
Screen calls `provider.method(...)` → set `isLoading = true` + `notifyListeners()` → `await Service.staticMethod()` → store result in public field → reset `isLoading` + `notifyListeners()` (in `finally`). UI's `Consumer<T>` / `context.watch<T>()` rebuilds.

## Dependencies
- Outbound: `lib/data/services/*`, `lib/data/model/*`, sometimes `lib/core/network/dio_client.dart` (e.g., `country_provider`), `provider` package.
- Inbound: `lib/main.dart` (registration); `lib/presentation/*` (consumption).

## Conventions
- `extends ChangeNotifier` (or `with ChangeNotifier`); never extends another provider.
- Public mutable fields (no getters): `isLoading`, `error` (or `errorMessage`), the data list/object.
- `notifyListeners()` after every state mutation. Wrap async work in `try/catch/finally`; reset `isLoading` in `finally`.
- `CategoryProvider` and `CountryProvider` use `_safeNotifyListeners` with `_isDisposed` — others may emit notify-after-dispose warnings. Consider replicating the safety pattern for new providers.
- `bottom_nav_provider.dart` is the only provider with no `error` field — pure UI state.

## Common commands
None module-specific.
