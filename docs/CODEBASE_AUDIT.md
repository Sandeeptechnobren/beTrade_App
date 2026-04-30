# Betrade — Codebase Audit

- **Source**: `github.com/Sandeeptechnobren/beTrade_App` — `main` branch (HEAD `6c546de`)
- **Date**: 2026-04-30
- **Scope**: Read-only audit. No code modified.
- **Method**: Parallel subagent investigation across structure, request flow, data layer, and build/test.

---

## Executive summary

Betrade is a **Flutter mobile app** (also configured for web/desktop, though those targets appear unmodified) for a "trade" / prediction-market style product. It targets a single backend at `api.buildacademy.io/projects/betrade/public/api` for auth, KYC, profile, trade listings, and reference data.

The project is in **early/MVP shape**: the architecture is straightforward (UI → Provider → Service → HTTP → backend), and the core flows (sign-in, sign-up + KYC, profile edit, trade browse) are wired end-to-end. However, several "outer-ring" features are UI-only stubs with no backend wiring (Buy Yes/No button, deposit/withdraw forms, social login buttons, live charts), and the project ships with material **production-readiness gaps**: release builds are signed with the debug keystore, `.env` is committed and bundled into release artifacts, no CI runs on `main`, and effective test coverage is 0%.

### Critical concerns (read these first)

1. **Release APKs are signed with the debug keystore** — `android/app/build.gradle.kts:30` (`signingConfig = signingConfigs.getByName("debug")`). Cannot be uploaded to Play Store under the developer's identity.
2. **`.env` committed and bundled as a Flutter asset** — tracked in git, missing from `.gitignore`, and listed in `pubspec.yaml` as an asset, so it ships inside the release APK/IPA. Currently only contains `BASE_URL` (low risk), but the pattern will leak any future secret added.
3. **`android:usesCleartextTraffic="true"`** in `AndroidManifest.xml:17` — globally disables cleartext-blocking. Production should remove this or use a Network Security Config.
4. **Auth token stored in plaintext `SharedPreferences`** — not iOS Keychain / Android Keystore. Below industry norm for bearer tokens.
5. **`flutter test` will fail** on `main`. The only test (`test/widget_test.dart`) is the unmodified `flutter create` scaffold and asserts on a counter widget that does not exist in this app. Effective `lib/` coverage is 0%.
6. **No CI/CD on `main`** — no `.github/`, no `codemagic.yaml`. CI work appears to live only on the `feature/codemagic-testflight` branch.
7. **Duplicate HTTP clients** — both `http` and `dio` are used; most services use `http`, the polished `DioClient` (with token + multipart instances) is used only by parts of the auth/signup flow. Standardise on one.
8. **Sign-in flow bypasses both `EnvConfig` and `AuthService`** — `lib/data/provider/signIn_provider.dart` calls hard-coded `https://api.buildacademy.io/...` URLs directly via `http`, even though a parallel `dio`-based pipeline exists in `auth_service.dart` (used only by sign-up).
9. **Massive commented-out code** — multiple files exceed 60% commented lines (`step_profile.dart` 72%, `country_provider.dart` 72% with four stale class versions, `trade_filter_bottom_sheet.dart` 72%, `custom_camera.dart` 52%). Largest single cleanup opportunity.
10. **Token-validity polled every 10 seconds** via `Timer.periodic` in `lib/presentation/screens/main_screen.dart` — wasteful and noisy; should be replaced with on-401 invalidation in an interceptor.
11. **Filename typo** propagated everywhere: `lib/core/config/api_endpoint..dart` (double dot), imported by 7 files.

---

## 1. Top-level directory structure

### Repo root

| Folder / file | Description |
| --- | --- |
| `lib/` | All Dart source — see breakdown below. |
| `assets/` | `images/`, `logo/`, `fonts/` (SFProRounded). No JSON/YAML config. |
| `test/` | One file: default `widget_test.dart` scaffold. |
| `android/` | **Customised**: `package com.build.betrade`, JDK 11, R8 enabled. AndroidManifest declares CAMERA, INTERNET, READ_EXTERNAL_STORAGE (≤SDK 32), READ_MEDIA_IMAGES; `usesCleartextTraffic="true"`. **Java `MainActivity.java` is under `com/example/betrade/` but declares `package com.build.betrade;`** — package/folder mismatch. |
| `ios/` | **Customised**: `Info.plist` carries Camera/Microphone/PhotoLibrary/Documents usage strings; portrait-only; display name `Betrade`. No `CFBundleURLTypes` (no deep links). |
| `web/` | Default Flutter scaffolding — unmodified. |
| `windows/`, `linux/`, `macos/` | Default Flutter scaffolding — unmodified. |
| `.env` | **Tracked** (not in `.gitignore`) and bundled as asset. Contains a single `BASE_URL` line. |
| `pubspec.yaml` / `pubspec.lock` | Manifest. |
| `analysis_options.yaml` | Includes only `flutter_lints/flutter.yaml` — no project rules added. |
| `README.md` | Default Flutter scaffold (16 lines). |

### `lib/` — one level deep

```
lib/
├── main.dart                 entry point: LocalStorage.init, dotenv, MultiProvider, ScreenUtilInit
├── core/
│   ├── animations/           success_animation.dart (signup success FX)
│   ├── config/               env_config.dart, api_endpoint..dart  (sic — double dot)
│   ├── network/              dio_client.dart (singleton + multipart instance)
│   ├── theme/                app_colors.dart, app_text_style.dart (light/dark "Dynamic" variants)
│   └── utils/validators/     phone_number_validator.dart
├── data/
│   ├── model/                category, country, graph, profile, trade  (5 DTOs, manual fromJson)
│   ├── provider/             9 ChangeNotifiers (auth, signup, profile, country, category,
│   │                          trade, explore, bottomNav, theme)
│   └── services/             auth_service, category_service, explorer_service,
│                              profile_service, trade_details_service, trade_service,
│                              local_storage
└── presentation/
    ├── auth/                 auth_screen, auth_bottom_sheet
    ├── bottom_navigation/    bottom_nav (custom bar)
    ├── onboarding/           onboarding_screen, onboarding_page
    ├── screens/              splash/, signin/, verification/ (KYC), homeScreen/,
    │                          explore/, trade/, portfolio/{deposit,withdraw}/,
    │                          profile/, camera/, main_screen.dart
    └── widget/               14 reusable widgets
```

---

## 2. Tech stack

### Frameworks & SDK
- **Flutter / Dart** — SDK constraint `>=3.3.0 <4.0.0`. Material 3.
- App name `betrade`, version `1.0.0+10`, `publish_to: 'none'`.

### State management — `provider`
- Wired via **`MultiProvider` at `lib/main.dart:60-71`** with 9 `ChangeNotifier`s: `AuthProvider`, `CountryProvider`, `BottomNavProvider`, `SignupProvider`, `ProfileProvider`, `CategoryProvider`, `TradeProvider`, `ExploreProvider`, `ThemeProvider`.
- `MaterialApp` is wrapped in `Consumer<ThemeProvider>` so theme switches rebuild the whole tree.
- Pattern: each provider exposes `isLoading`, `error`/`errorMessage`, calls `notifyListeners()` around async ops. `CategoryProvider` and `CountryProvider` add `_isDisposed` guards via `_safeNotifyListeners` — others do not, which can produce notify-after-dispose warnings.
- No Riverpod, BLoC, or `ChangeNotifierProxyProvider`.

### Networking — split between two clients
- **`dio: ^5.4.0`** via `lib/core/network/dio_client.dart` (singleton with `BaseOptions.baseUrl = dotenv.env['BASE_URL']`, 15s timeouts, separate `multipartInstance` for FormData with 30s timeouts, plus `setToken`/`removeToken` helpers that mutate the shared `Authorization` header).
  - Used by: `AuthService` (sendOtp/verifyOtp/completeSignup/fetchChartData/logout/verifyToken) and `CountryProvider.fetchCountries`.
- **`http: ^1.2.0`** used directly in `TradeService`, `CategoryService`, `ExploreService`, `ProfileService`, `TradeDetailService`, and `AuthProvider` (login + verify-otp/login).
- **No interceptors** anywhere on the Dio client — no automatic auth header restoration, no centralised 401 handling, no retry, no logging.
- Several `http`-based call sites bypass `EnvConfig` and **hard-code** `https://api.buildacademy.io/...` URLs (login, verify-otp/login, verify-token, trade/explore, trade/view).

### Local persistence — `shared_preferences` only
- Single wrapper at `lib/data/services/local_storage.dart`, initialised in `main.dart` before `runApp`.
- Three keys via the wrapper: `theme_mode` (string), `token` (string), `onboardingDone` (bool).
- One direct `prefs.setBool('isFirstTime', …)` at `lib/presentation/screens/homeScreen/HomeScreen.dart:102` bypasses the wrapper.
- No SQLite, Hive, Drift, or secure storage.

### Auth mechanism
- **Bearer token**, obtained from `POST /verify-otp/login` (sign-in) or `POST /verify-otp/register` (sign-up).
- Persisted via `LocalStorage.setToken` (plaintext SharedPreferences).
- Two parallel injection paths exist:
  1. **Dio path**: `DioClient.setToken(token)` mutates the shared `Authorization` header. Only set after successful `verifyOtp` in `AuthService`; **never restored on app restart from saved token** — meaning Dio calls after relaunch run unauthenticated until/unless the token is set again.
  2. **`http` path**: each service reads `LocalStorage.getToken()` per request and builds `'Authorization': 'Bearer $token'` inline.
- Token freshness is checked in two places: `SplashScreen._navigateUser` (one-shot at launch, `splash_screen.dart:51` → `AuthService.verifyToken`), and `MainScreen._startTokenChecker` (`main_screen.dart:55-150`) **polling every 10 seconds via `Timer.periodic`**, showing a glassmorphic "Session Expired" dialog on `false`. `ProfileService.getProfile` also calls `LocalStorage.clearToken()` on 401.

### Routing / navigation
- **Imperative `Navigator` only**. No `routes:` map, no `onGenerateRoute`, no `initialRoute`, no `go_router`. `MaterialApp.home` is `SplashScreen()`.
- 135 `Navigator.push` / `pushReplacement` / `pushAndRemoveUntil` call sites across 28 files, all using `MaterialPageRoute(builder: (_) => Screen())`.
- Splash branches to `OnboardingScreen` / `AuthScreen` / `MainScreen` based on `LocalStorage` flags.

### Theme / i18n
- **Theme**: `lib/data/provider/theam_provider.dart` (filename misspelling — should be `theme_provider.dart`). Holds `ThemeMode`, persisted via `LocalStorage.saveThemeMode`. `MaterialApp` provides both `theme` and `darkTheme` plus `themeMode: themeProvider.themeMode`.
- Centralised colours in `lib/core/theme/app_colors.dart` with paired static + `*Dynamic(BuildContext)` helpers for dark mode. Same pattern in `app_text_style.dart` (with `flutter_screenutil` `.sp`).
- **i18n: none.** No `flutter_localizations`, no `intl`, no `AppLocalizations`. UI strings hardcoded in English. (The `/languages` endpoint is wired into the verification screen but only populates a dropdown — there is no client-side localisation.)

### Charting — `fl_chart`
- Used in **one** screen: `lib/presentation/screens/profile/info_chart_screen.dart`. Renders a live-updating `LineChart` over a hardcoded `List<FlSpot>` mutated by `Timer.periodic` to simulate movement.
- The data layer has a `ChartData` model and `AuthService.fetchChartData()` calling `/chart`, but the chart screen never consumes that service.

### Other plugins wired
`flutter_screenutil` (`designSize: Size(393, 852)`), `permission_handler`, `camera`, `image_picker`, `path_provider`, `flutter_image_compress`, `http_parser` (KYC/selfie/document capture flow).

---

## 3. Data flow

### Flow A — Sign-in (sendOtp → verifyOtp → store token)

This flow uses `package:http` **directly inside the provider**, hard-codes URLs, and **does not** go through `AuthService` or `DioClient`.

1. **UI** — `lib/presentation/screens/signin/login_screen.dart`. User taps "Continue" (`_handleContinue`, line 121); validates phone + country; calls `context.read<AuthProvider>().sendOtp(fullPhone)` at line 140; navigates to `OTPScreen(phone: fullPhone)` on success. In `otp_screen.dart:511`, `_verifyOtp()` calls `AuthProvider.verifyOtp(widget.phone, otp)`.
2. **Provider** — `lib/data/provider/signIn_provider.dart`. `sendOtp(phone)` (line 10) and `verifyOtp(phone, otp)` (line 45) flip `isLoading`, run the HTTP call inline, and `notifyListeners()`.
3. **HTTP** — `http.post(Uri.parse("https://api.buildacademy.io/.../api/login"), ...)` at `signIn_provider.dart:18`; same hard-coded literal for `/verify-otp/login` at line 54.
4. **Parsing** — `jsonDecode(response.body)` into a raw `Map<String, dynamic>`. No model class. `data['token']` → `LocalStorage.setToken(...)`.
5. **UI update** — provider returns `{success, message}` map; LoginScreen reads it and navigates or shows a SnackBar.

There is a parallel, env-aware, dio-based pipeline in `lib/data/services/auth_service.dart:33-118` (`sendOtp`/`verifyOtp`/`completeSignup`) that is used **only by sign-up** via `SignupProvider` (`signUp_provider.dart:117-132`). Sign-in does not go through it.

### Flow B — Fetching trades for the Explore page

1. **UI** — `lib/presentation/screens/explore/explore_page.dart:40` calls `context.read<ExploreProvider>().fetchExploreTrades()` in a post-frame callback inside `initState`.
2. **Provider** — `lib/data/provider/explorer_provider.dart:147` `fetchExploreTrades()` → `await TradeService.getAllTrades()`.
3. **Service** — `lib/data/services/trade_service.dart:47` `TradeService.getAllTrades()`. Reads token via `LocalStorage.getToken()`, builds URL via `ApiEndpoints.tradeList(1)` — page-1 only; pagination is purely client-side in `TradeProvider._applyPagination`.
4. **HTTP** — `http.get(Uri.parse(ApiEndpoints.tradeList(1)), headers: {Authorization: 'Bearer $token'})` at `trade_service.dart:59`.
5. **Parsing** — `jsonDecode(response.body)`; on `decoded['status'] == true`, maps `decoded['data']['items']` → `TradeModel.fromJson(e)` (`lib/data/model/trade_model.dart:19`).
6. **UI update** — `ExploreProvider.exploreTrades` set; `Consumer<ExploreProvider>` rebuilds the list. Tapping a trade navigates to `trade_page.dart`, whose `initState` calls `TradeDetailService.getTradeDetail(uuid)` against a **hard-coded** `https://api.buildacademy.io/.../trade/view/$uuid` URL.

---

## 4. Data models & local persistence

### Models — location and shape

All DTOs live in **`lib/data/model/`** (singular `model`). There are **5 model classes**, all with manual `fromJson` constructors only (no `toJson`, no codegen — confirmed by absence of `json_serializable`, `freezed`, or `build_runner` in `pubspec.yaml`). Outbound payloads are built ad-hoc as `Map<String, dynamic>` literals inside services.

**No model references another model.** No `User`, no `Wallet/Deposit/Withdrawal`, no `KYC` model — those endpoint responses are parsed inline as raw maps.

| Class | File | Backed by | Key fields | Notes |
| --- | --- | --- | --- | --- |
| `ProfileModel` | `lib/data/model/profile_model.dart:28-71` | `/profile`, `/edit-profile` | `firstName`, `lastName`, `avatar` (passed through `_fixAvatar` to strip a duplicate `https://` prefix bug from the backend), `phone?`, `gender?`, `country?`, `currency?`, `language?` | Older version commented at lines 1-26. `country` and `currency` are plain strings, not references to `CountryModel`. |
| `CountryModel` | `lib/data/model/country_model.dart` | `/countries` | `id`, `name`, `phoneCode`, `flag`, `currency` | `fromJson` has **no `??` defaults** — a missing field will throw. |
| `CategoryModel` | `lib/data/model/category_model.dart` | `/trade/categories-list` | `uuid`, `name` | Defensive `?? ""` defaults. |
| `TradeModel` | `lib/data/model/trade_model.dart` | `/trade/list`, `/trade/explore` | `uuid`, `categoryName`, `description`, `minTradeAmount` (kept as **String**, not numeric), `image?`, `endDate` (kept as String, not `DateTime`) | Category is denormalised to a string. |
| `ChartData` | `lib/data/model/graph_model.dart` | `/chart` | `x` (← `time`), `y` (← `value`) | Class-name mismatch with filename. `.toDouble()` will throw on missing/non-numeric input. |

### Local persistence (`shared_preferences`)

Centralised wrapper at `lib/data/services/local_storage.dart`, initialised in `main.dart`:

| Key | Type | Set | Get | Cleared |
| --- | --- | --- | --- | --- |
| `theme_mode` | String (`"dark"`/`"light"`) | `local_storage.dart:5` | `:8` | — |
| `token` | String | `:15` | `:18` | `:21` (`clearToken`) |
| `onboardingDone` | bool | `:24` | `:27` | — |

Direct, un-wrapped use:

| Key | Type | Set | Get |
| --- | --- | --- | --- |
| `isFirstTime` | bool | `lib/presentation/screens/homeScreen/HomeScreen.dart:102` | `:63` |

**Concerns**:
- `token` stored in plaintext SharedPreferences (Android: app-private XML; iOS: NSUserDefaults). Neither Keychain nor Keystore.
- `clearToken()` exists but appears never invoked — confirm before relying on it.
- `onboardingDone` and `theme_mode` are not cleared on logout.
- `isFirstTime` overlaps semantically with `onboardingDone` (different concerns: home-hint tooltip vs. onboarding screen).

---

## 5. API endpoints

**Base URL** (single environment, no dev/staging vs prod): `https://api.buildacademy.io/projects/betrade/public/api` — defined in `.env`, read via `EnvConfig.baseUrl` (`lib/core/config/env_config.dart`), composed into URLs in `lib/core/config/api_endpoint..dart` (sic — filename has a double dot).

`main.dart:33` references `dotenv.env['API_BASE_URL']` for a debug warning, but **no code reads `API_BASE_URL`** — only `BASE_URL` is used. Dead check.

A legacy host `https://api.easycoders.in/...` appears only in commented-out code.

### Auth (sign-in / sign-up / KYC)

| Method | Path | Caller | Client |
| --- | --- | --- | --- |
| POST | `/login` *(hard-coded URL)* | `lib/data/provider/signIn_provider.dart:18` | `http` |
| POST | `/verify-otp/login` *(hard-coded URL)* | `lib/data/provider/signIn_provider.dart:54` | `http` |
| POST | `/register` | `lib/data/services/auth_service.dart:35` | `dio` |
| POST | `/verify-otp/register` | `lib/data/services/auth_service.dart:58` | `dio` |
| POST | `/complete-profile` (multipart) | `lib/data/services/auth_service.dart:145` | `dio` (multipartInstance) |
| POST | `/logout` | `lib/data/services/auth_service.dart:190` | `dio` |
| GET | `/verify-token` *(hard-coded URL)* | `lib/data/services/auth_service.dart:213` | `dio` |
| POST | `/kyc/submit` (multipart) | `lib/presentation/screens/verification/verify_account.dart:212` | `http` |
| POST | `/profile/preferences` | `lib/presentation/screens/verification/verify_account.dart:267` | `http` |

### Profile

| Method | Path | Caller | Client |
| --- | --- | --- | --- |
| GET | `/profile` | `lib/data/services/profile_service.dart:99` | `http` |
| PUT (multipart) | `/edit-profile` | `lib/data/services/profile_service.dart:188` | `http` |
| GET | `/languages` | `lib/presentation/screens/verification/verify_account.dart:110`, `lib/presentation/screens/profile/edit_profile.dart:79` | `http` |

### Trades / Explore / Categories

| Method | Path | Caller | Client |
| --- | --- | --- | --- |
| GET | `/trade/list?page=N` | `lib/data/services/trade_service.dart:20`, `:59` | `http` |
| GET | `/trade/explore?search=Q` *(hard-coded URL)* | `lib/data/services/explorer_service.dart:50` | `http` |
| GET | `/trade/view/{uuid}` *(hard-coded URL)* | `lib/data/services/trade_details_service.dart:12` | `http` |
| GET | `/trade/categories-list` | `lib/data/services/category_service.dart:11` | `http` |
| GET | `/chart` | `lib/data/services/auth_service.dart:165` (`fetchChartData`) — **defined but never called from UI** | `dio` |

### Reference data

| Method | Path | Caller | Client |
| --- | --- | --- | --- |
| GET | `/countries` | `lib/data/provider/country_provider.dart:488` | `dio` |
| GET | `/countries` *(alternate, hard-coded)* | `lib/presentation/screens/verification/country_services_step_one.dart:42` (`CountryService.fetchCountries`) | `http` |

### Endpoints declared in `ApiEndpoints` but never invoked
- `ApiEndpoints.searchTrades(query)` — replaced by hard-coded URL in `explorer_service.dart`.

### Endpoints invoked but not declared in `ApiEndpoints`
- `/login`, `/verify-otp/login`, `/verify-token`, `/trade/explore`, `/trade/view/{uuid}` — all hit via hard-coded literals.

### Notable gap
- **No place-order, deposit, withdraw, wallet, or balance endpoint exists anywhere in `lib/`.**
- `lib/presentation/screens/trade/trade_page.dart:89` "Buy Yes" / "Buy No" button has `onPressed: isEnabled ? () {} : null` — a no-op.
- `lib/presentation/screens/portfolio/deposit/newDeposit.dart` and `.../withdraw/withdrawal.dart` collect card / MoMo fields locally with no network call.

---

## 6. Shared utilities & common patterns

### `lib/core/` helpers

| File | Purpose |
| --- | --- |
| `lib/core/config/env_config.dart` | `EnvConfig.baseUrl` getter; throws if `.env` key missing. |
| `lib/core/config/api_endpoint..dart` | `ApiEndpoints` static class — 14 endpoint URL builders. **Filename has a double-dot typo** (`api_endpoint..dart`). |
| `lib/core/network/dio_client.dart` | Singleton Dio + `multipartInstance` (fresh Dio per multipart upload, copying auth header). Lines 1-20 are a dead, fully-commented earlier `DioClient` class; live one starts at line 24. |
| `lib/core/theme/app_colors.dart` | `AppColors` with static colour constants and `*Dynamic(BuildContext)` helpers branching on `Theme.of(context).brightness`. |
| `lib/core/theme/app_text_style.dart` | Static `TextStyle` instances using SFProRounded + `screenutil` `.sp`; `custom({size,weight,color})` factory; dark-mode `*Dynamic` variants. |
| `lib/core/utils/validators/phone_number_validator.dart` | `Validators.validatePhone(phone, {countryCode})` with rules for `+91`, `+1`, `+44`, plus default. |
| `lib/core/animations/success_animation.dart` | `SuccessScreen` particle/scale animation used after signup. |

### Reusable widgets in `lib/presentation/widget/`

`primary_button.dart`, `purple_button.dart`, `common_header.dart`, `Common_header_withlogo.dart`, `common_bottom_sheet.dart`, `common_share_button.dart`, `country_picker.dart`, `custom_camera.dart`, `dark_mode_toggle.dart`, `deposit_success.dart`, `icon_container.dart`, `leading_icon.dart`, `rounded_tab_indicator.dart`, `step_indecator.dart` (sic).

### Patterns observed

- **Service layer**: most services are abstract classes with `static` methods (`TradeService`, `CategoryService`, `ProfileService`, `TradeDetailService`, `ExploreService`); `AuthService` mixes instance methods with one static (`logout`).
- **Provider pattern**: each provider exposes `isLoading`, `error`/`errorMessage`; calls `notifyListeners()` around async ops. `CategoryProvider` and `CountryProvider` add `_isDisposed` guards via `_safeNotifyListeners`; others omit this.
- **Error handling**: per-call `try/catch` with `print` / `debugPrint` — no centralised handler, no logger package, no Dio interceptor. Print statements ship in production.
- **No common API client wrapper** — each `http`-based service repeats token retrieval, header construction, and `jsonDecode(response.body)` inline.
- **No base `ChangeNotifier` class**, no shared error/result type, no DI container beyond `MultiProvider`.
- **Heavy commented-out historical code** in many service and provider files (see §11).

---

## 7. Test setup

- **Framework**: `flutter_test` (Dart SDK `>=3.3.0 <4.0.0`).
- **Files**: `test/widget_test.dart` only — single 30-line file.
- **What it tests**: Nothing meaningful. **Default `flutter create` scaffold** asserting on `find.text('0')` and `find.byIcon(Icons.add)`. The actual `MyApp` renders `SplashScreen` — those widgets do not exist.
  - **`flutter test` will fail** on `main`.
- **Integration tests**: None. No `integration_test/` directory; no `integration_test` dev-dep.
- **Mocking**: None. dev_dependencies are only `flutter_test`, `flutter_lints ^6.0.0`, `flutter_launcher_icons ^0.14.4`. No `mockito`, `mocktail`, `bloc_test`, or `fake_async`.
- **How to run**: `flutter test` (currently broken); `flutter test --coverage` writes to `coverage/lcov.info` (gitignored).
- **Effective `lib/` coverage**: ~0%. None of the 87+ Dart files in `lib/` are exercised.

---

## 8. Build & deploy

### Build commands

- Android: `flutter build apk` (or `--split-per-abi`), `flutter build appbundle`
- iOS: `flutter build ios`, `flutter build ipa`
- Web: `flutter build web` (`web/` folder exists, unmodified)
- Desktop: `flutter build windows` / `macos` / `linux`

### CI / CD

- **No `.github/`**, **no `codemagic.yaml`** at root or `.codemagic/`. The `feature/codemagic-testflight` and `feature/testflight-prep` remote branches imply CI work was done — but it has **not been merged into `main`**.
- No Fastlane (`Fastfile`, `fastlane/`).
- No Dockerfile, Makefile, or `scripts/`.

### Android signing

`android/app/build.gradle.kts:30`: `signingConfig = signingConfigs.getByName("debug")`. **Release builds are signed with the debug keystore.** No `key.properties`, no env-var-driven keystore, no `signingConfigs { create("release") {…} }`. R8 / shrinkResources are enabled (`isMinifyEnabled = true`, `isShrinkResources = true`) without a `proguard-rules.pro` file in the repo.

`applicationId` / `namespace` = `com.build.betrade`. JDK 11.

### iOS configuration

- Bundle ID: `com.build.betrade` (Runner), `com.build.betrade.RunnerTests` (test target — note formatting bug in `project.pbxproj` line 404: `PRODUCT_BUNDLE_IDENTIFIER =com.build.betrade.RunnerTests`).
- Display name `Betrade`, `CFBundleName betrade`.
- Versioning is dynamic (`$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` ← `pubspec.yaml` `1.0.0+10`).
- Code signing: `CODE_SIGN_STYLE = Automatic` (test target), `CODE_SIGN_IDENTITY[sdk=iphoneos*] = "iPhone Developer"`. **No `DEVELOPMENT_TEAM` / `PROVISIONING_PROFILE`** — provisioning is unconfigured for non-interactive CI.
- Permissions usage strings (Camera, Microphone, PhotoLibrary, PhotoLibraryAdd, DocumentsFolder) are present and well-formed.
- No `CFBundleURLTypes` — no deep links.
- No `NSAppTransportSecurity` entry (defaults to HTTPS-only — fine, but inconsistent with Android's `usesCleartextTraffic="true"`).

### App icons

`flutter_launcher_icons` configured in `pubspec.yaml` (lines 47-52): android+ios true, source `assets/logo/app_icon.png`, adaptive icon background `#ffffff`. Regenerate with `dart run flutter_launcher_icons`.

---

## 9. Environment variables & config

### `.env` (committed at repo root, single line)

Contains exactly **one key**:

```
BASE_URL=https://api.buildacademy.io/projects/betrade/public/api
```

This URL is non-secret (it's the production API base; any user's traffic exposes it). However:

- **`.env` is NOT in `.gitignore`** — confirmed; the file was tracked through the initial clone. The 85-line `.gitignore` covers OS, IDE, Flutter, Android, iOS, macOS, Windows, Linux, web, and obfuscation patterns, but no `.env` entry.
- **`.env` is bundled as a Flutter asset** (`pubspec.yaml:39`: `- .env`), so its contents ship in the release APK/IPA in plaintext (extractable with `apktool`). For a public BASE_URL this is low-risk; **the same mechanism would leak any future secret**.

### Loading mechanism

- `flutter_dotenv: ^6.0.0` loads at startup (`main.dart:32` → `await dotenv.load(fileName: '.env')`).
- `EnvConfig.baseUrl` (`lib/core/config/env_config.dart`) throws if missing/empty.
- `ApiEndpoints` (`lib/core/config/api_endpoint..dart`) builds 14 endpoint URLs from `EnvConfig.baseUrl`.

### Compile-time configuration
Search for `String.fromEnvironment` / `bool.fromEnvironment` / `int.fromEnvironment` in `lib/` returns **zero matches**. No `--dart-define` config; everything is runtime via dotenv.

### Committed config in `assets/`
Only `fonts/`, `images/`, `logo/`. **No JSON/YAML config**, no Firebase `google-services.json` / `GoogleService-Info.plist`.

### Android (`android/app/src/main/AndroidManifest.xml`)

- `applicationId` / `namespace`: `com.build.betrade` (build.gradle.kts).
- Permissions: `INTERNET`, `CAMERA` (with `<uses-feature android.hardware.camera required="false">`), `READ_EXTERNAL_STORAGE` (`maxSdkVersion="32"`), `READ_MEDIA_IMAGES`. **No `POST_NOTIFICATIONS`**.
- Only intent-filter is `MAIN`/`LAUNCHER` — **no deep-link / custom URL scheme**.
- **`android:usesCleartextTraffic="true"`** at line 17 — globally permits HTTP. Should be removed for production.
- No hardcoded API keys.

### iOS (`ios/Runner/Info.plist`)

- Bundle ID templated, display name `Betrade`, portrait-only.
- Camera/Microphone/PhotoLibrary/PhotoLibraryAdd/DocumentsFolder usage strings present.
- No `CFBundleURLTypes`, no `NSAppTransportSecurity`. No hardcoded API keys.

---

## 10. Third-party integrations

| Category | Status |
| --- | --- |
| **Backend API** | `api.buildacademy.io` — single environment, used end-to-end for auth, profile, KYC, countries, languages, trades, categories, trade detail. |
| **Payment gateways** | **None.** No `razorpay_flutter`, `flutter_stripe`, `paytm_*`. The Deposit screen is a UI-only stub (no network call). |
| **Push notifications** | **None.** No `firebase_messaging`, `firebase_core`, `onesignal_flutter`, `flutter_local_notifications`. AndroidManifest has no FCM service registration and no `POST_NOTIFICATIONS` permission. The "Notification" screen is a *preferences toggle*, not delivery. |
| **Analytics / crash reporting** | **None.** No Firebase Analytics, Mixpanel, Amplitude, Sentry, Crashlytics. Errors go to `debugPrint` only (`main.dart:23` `FlutterError.onError`, `main.dart:50` `runZonedGuarded`). |
| **File / media CDN** | **None.** Avatar / KYC uploads go directly to the BetTrade backend as multipart form-data; the backend returns avatar URLs that the app loads via `Image.network`. |
| **Social login (Google/Apple/Facebook)** | **UI-only placeholder.** `login_screen.dart:356,394` has "Continue with Google" and "Continue with Apple" `OutlinedButton`s with empty `onPressed: () {}`. No `google_sign_in`, `sign_in_with_apple`, or `flutter_facebook_auth` package. |
| **WebSocket / real-time** | **None.** No `web_socket_channel`, `socket_io_client`, `pusher_*`, `signalr_*`, `EventSource`. **No live price feed despite this being a trading app** — trades are static REST snapshots. `tradeData['current_price_per_share']` is read once and never refreshed. |
| **Maps** | **None.** No `google_maps_flutter`, `mapbox_*`, location packages. |
| **Third-party KYC** | **None.** No Sumsub / Onfido / Jumio / IDfy / HyperVerge. KYC is built in-house via `verify_account.dart` + the in-app camera screens, posting multipart photos to `/kyc/submit`. |

### Configured but unused
- `ApiEndpoints.chart` + `AuthService.fetchChartData()` — no UI caller.
- `ApiEndpoints.searchTrades(query)` — replaced by hard-coded URL in `explorer_service.dart`.
- Social-login buttons (no SDK, empty callbacks).
- Deposit / withdraw forms (no API wiring).
- `dotenv.env['API_BASE_URL']` reference in `main.dart:33` — never set in `.env`; only `BASE_URL` exists.

---

## 11. Dead code, unused dependencies, deprecated packages

### Dependency usage scan (`pubspec.yaml` → `lib/` import grep)

| Package | Direct imports in `lib/` | Status |
| --- | --- | --- |
| `cupertino_icons: ^1.0.8` | 0 imports of `cupertino_icons` itself; one usage (`CupertinoIcons.arrowshape_turn_up_right` in `common_share_button.dart:81` via `flutter/cupertino.dart`) | Effectively used by one icon. Could be removed if that icon is swapped for Material. |
| `http_parser: ^4.1.2` | **0** | Likely transitive-only (used by `http`/`dio` internally). **Candidate for removal from direct deps.** |
| `iconsax: ^0.0.8` | 2 files (`bottom_nav.dart`, `portfolio_page.dart`) | **Pre-1.0 (`^0.0.8` resolves to `>=0.0.8 <0.0.9`)** — risky pin, very limited use. Replaceable with Material icons. |
| `fl_chart: ^1.2.0` | 1 file (`info_chart_screen.dart`) | Used (with hardcoded data). |
| `path_provider: ^2.1.5` | 1 file (`step_profile.dart`) | Used. |
| `flutter_image_compress: ^2.4.0` | 1 file (`step_profile.dart`) | Used. |
| `http: ^1.2.0` | 11 files | Used. |
| `dio: ^5.4.0` | 3 files (`auth_service.dart`, `dio_client.dart`, `country_provider.dart`) | Used. **But** the polished `DioClient` is bypassed by most services that use raw `http` — see duplication note below. |

**Duplicate functionality — `http` and `dio`**: real overlap. `auth_service.dart` even imports both (lines 3-4). The polished `DioClient` (singleton + multipart + token helpers) is used only by parts of the auth/signup flow and `CountryProvider`; everything else uses raw `http`. Recommend standardising on `dio` and removing `http`/`http_parser`.

### TODO / FIXME / XXX / HACK
**Zero matches** for `// TODO`, `// FIXME`, `// XXX`, `// HACK` (case-insensitive) anywhere in `lib/`. The codebase is unannotated.

### Filename typos / oddities

- **`lib/core/config/api_endpoint..dart`** — double dot in filename. Imported by 7 files using the same broken path. Compiles, but it's a typo that has propagated.
- Inconsistent file naming (mixes snake_case, camelCase, PascalCase): `HomeScreen.dart`, `Common_header_withlogo.dart`, `Payment_method.dart`, `achivement_Sheet.dart` (also misspelled — should be `achievement`), `OTP_step.dart`, `Gender_step.dart`, `stepPhone.dart`, `newDeposit.dart`, `theam_provider.dart` (`theam` → `theme`), `step_indecator.dart` (`indecator` → `indicator`), `step_heder.dart` (`heder` → `header`), `signIn_provider.dart`, `signUp_provider.dart`. Violates Dart's `file_names` lint, which `flutter_lints` includes.

### Orphan files in `lib/`

After grepping every file's snake_case name AND its main exported class name across `lib/`, **no fully orphaned files were found** — every Dart file is imported somewhere.

### Massive commented-out code blocks

Worst offenders by share of `//`-prefixed lines (full-line comments, not doc):

| File | Commented `//` lines / total |
| --- | --- |
| `lib/presentation/screens/splash/signup_steps_pages/step_profile.dart` | **1346 / 1866 (72%)** |
| `lib/presentation/screens/homeScreen/trade_filter_bottom_sheet.dart` | 666 / 921 (72%) |
| `lib/presentation/screens/signin/country_picker_sheet.dart` | 551 / 820 (67%) |
| `lib/presentation/widget/custom_camera.dart` | 546 / 1056 (52%) |
| `lib/data/provider/country_provider.dart` | 457 / 634 (72%) — contains 4 separate stale class versions; only the last is active |
| `lib/presentation/screens/signin/otp_screen.dart` | 399 / 793 (50%) |
| `lib/presentation/screens/splash/signup_steps_pages/Gender_step.dart` | 248 / 379 (65%) |
| `lib/presentation/screens/splash/signup_steps_pages/step_name.dart` | 240 / 384 (63%) |
| `lib/presentation/onboarding/onboarding_screen.dart` | 192 / 322 (60%) |
| `lib/data/provider/explorer_provider.dart` | 130 / 198 (66%) — three commented-out class versions before the live one at line 137 |
| `lib/core/animations/success_animation.dart` | 159 / 393 (40%) |
| `lib/core/network/dio_client.dart` | Lines 1-20 are a dead, fully-commented earlier `DioClient`; live one starts at line 24 |

These are not doc comments — they're full prior implementations left in place rather than removed via VCS. Single largest cleanup target in the codebase.

### Configuration smells
- `analysis_options.yaml` only includes `package:flutter_lints/flutter.yaml` with no project rules. Enabling `file_names` (and a stricter ruleset) would catch most of the naming issues automatically.
- README is the unmodified Flutter scaffold (16 lines).

---

## Recommendations (prioritised)

### Must-fix before public/Play Store release
1. Add a real Android release signing config (env-var-driven keystore via `key.properties`); stop signing release with debug.
2. Add `.env` to `.gitignore`; commit a `.env.example`; treat `.env` as build input only — do **not** bundle it as a Flutter asset.
3. Remove `android:usesCleartextTraffic="true"`; configure a Network Security Config if any cleartext is genuinely needed.
4. Move auth tokens out of `SharedPreferences` into `flutter_secure_storage` (Keychain / Keystore-backed).
5. Resolve the Java package/folder mismatch in `android/app/src/main/java/com/example/betrade/MainActivity.java` (folder `com/example/betrade/`, declared `package com.build.betrade;`).
6. Remove or guard production `print` / `debugPrint` calls; consider `logger` with an off-in-release flag.

### High-value cleanups
7. Delete the four-version stale class history in `country_provider.dart` and the worst-offender commented files (§11) — git history is the right place for that.
8. Standardise on a single HTTP client (recommend `dio`); remove `http` and `http_parser` from direct deps. Add a Dio interceptor for auth header + 401 handling, replacing the 10-second `Timer.periodic` token poll in `MainScreen`.
9. Route every endpoint through `ApiEndpoints` (no hard-coded URLs in providers/services). Rename `api_endpoint..dart` → `api_endpoint.dart` and update the 7 import sites.
10. Restore the Dio auth header on app launch — currently it's only set after `verifyOtp` succeeds, leaving Dio unauthenticated after relaunch with a saved token.
11. Replace the broken `widget_test.dart` scaffold with at least one real smoke test that pumps `MyApp` with mocked providers.

### Medium / hygiene
12. Add `flutter_lints` rule overrides (`file_names`, `prefer_const_constructors`, etc.) and run `dart fix --apply`.
13. Wire the CI work from `feature/codemagic-testflight` into `main` (or add a minimal GitHub Actions workflow running `flutter analyze` + `flutter test`).
14. Decide whether unused features (social login, deposit/withdraw, live charts, "Buy Yes/No") are roadmap items or stubs to delete; either implement or remove.
15. Consider a `User` / `KYC` model class — current code parses these as raw `Map<String, dynamic>` inline.
16. Fix filename and identifier misspellings (`theam` → `theme`, `indecator` → `indicator`, `achivement` → `achievement`, `heder` → `header`).

---

*End of audit. This document is the result of read-only exploration; no source files were modified.*
