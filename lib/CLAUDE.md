# lib/

## Purpose
Root of all Dart/Flutter source for the Betrade mobile app. Layered into `core/` (cross-cutting infrastructure), `data/` (model + provider + services), and `presentation/` (UI). Single entry point: `main.dart`.

## Key files
- `main.dart` — bootstraps `LocalStorage.init()`, `dotenv.load(".env")`, sets portrait orientation, wraps the app in `MultiProvider` (9 providers) + `ScreenUtilInit` + `Consumer<ThemeProvider>`. `MaterialApp.home` is `SplashScreen()`.
- `core/` — env config, Dio singleton, theme tokens (colours + text styles), validators, animations.
- `data/model/` — five DTOs: `TradeModel`, `ProfileModel`, `CountryModel`, `CategoryModel`, `ChartData`.
- `data/provider/` — nine `ChangeNotifier`s (auth/sign-in, sign-up, profile, country, category, trade, explore, bottom-nav, theme).
- `data/services/` — API + storage services (`auth_service`, `trade_service`, `profile_service`, `category_service`, `explorer_service`, `trade_details_service`, `local_storage`).
- `presentation/screens/` — feature screens (splash, signin, verification, home, explore, trade, portfolio, profile, camera) plus the IndexedStack host `main_screen.dart`.
- `presentation/widget/` — 14 reusable widgets (buttons, headers, dropdowns, indicators).

## Data flow
HTTP request: UI widget → provider (`context.read<T>()`) → service static method → `http.get`/`http.post` or `DioClient.instance` → backend. Response: backend → service decodes JSON → `Model.fromJson` → provider stores + `notifyListeners()` → `Consumer` / `context.watch` rebuilds UI. Auth token persisted in `SharedPreferences` via `LocalStorage`.

## Dependencies
- Outbound: Flutter SDK; `http`, `dio`, `provider`, `flutter_dotenv`, `shared_preferences`, `flutter_screenutil`, `fl_chart`, `iconsax`, `camera`, `image_picker`, `permission_handler`, `path_provider`, `flutter_image_compress`.
- Inbound: `android/` and `ios/` load this directory as the Flutter module.

## Conventions
See `docs/PATTERNS.md` for the full style guide. In short: services = static methods; providers = `ChangeNotifier` with public mutable `isLoading`/`error` fields; models = manual `fromJson` (no codegen); env reads via `EnvConfig.baseUrl`; URLs from `ApiEndpoints`. Two HTTP-client variants (`http` and `dio`) coexist; new code should prefer `http` + `EnvConfig` + `ApiEndpoints` (the dominant pattern).

## Common commands
- `flutter pub get` — resolve dependencies (run after `pubspec.yaml` changes).
- `flutter analyze` — static analysis using `analysis_options.yaml`.
- `flutter run` — run on connected device/emulator.
- `flutter test` — run tests (currently fails on `main` — see `test/CLAUDE.md`).
- `flutter build apk` / `flutter build appbundle` / `flutter build ios` — produce release artifacts.
