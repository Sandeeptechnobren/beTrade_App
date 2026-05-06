# Betrade — Architecture

- **Source**: `github.com/Sandeeptechnobren/beTrade_App` — `main` branch (HEAD `6c546de`)
- **Date**: 2026-04-30
- **Companion docs**: see [`CODEBASE_AUDIT.md`](./CODEBASE_AUDIT.md) for findings/concerns and [`PATTERNS.md`](./PATTERNS.md) for the style guide.

This document describes how the system is wired today. It is purely descriptive — concerns and recommendations live in the audit.

---

## 1. System overview

Betrade is a **Flutter mobile client application** ("trade" / prediction-market UX) targeting Android and iOS, with default Flutter scaffolding present (but unused) for web, Windows, macOS, and Linux. It talks to a single REST backend hosted at `api.buildacademy.io/projects/betrade/public/api` for authentication (OTP-based), KYC/onboarding, profile management, and trade browsing. Local state is held by `provider`-based `ChangeNotifier`s; the bearer token, theme preference, and onboarding-completed flag are persisted in `SharedPreferences`. There is no Betrade-owned server code, no database, and no real-time channel in this repository — it is a client-only codebase.

---

## 2. High-level architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Flutter App (lib/)                          │
│                                                                     │
│  ┌─────────────────────┐   ┌──────────────────┐   ┌──────────────┐  │
│  │ presentation/       │   │ data/provider/   │   │ data/        │  │
│  │  - screens/         │──▶│  9 ChangeNotifier│──▶│ services/    │  │
│  │  - widget/          │◀──│  (auth, signup,  │◀──│  static-     │  │
│  │  - onboarding/      │   │  profile, trade, │   │  method      │  │
│  │  - auth/            │   │  explore, theme, │   │  classes     │  │
│  │  - bottom_navigation│   │  category, etc.) │   │              │  │
│  └─────────┬───────────┘   └────────┬─────────┘   └──────┬───────┘  │
│            │                        │                    │          │
│            │                        ▼                    ▼          │
│            │             ┌────────────────────┐   ┌─────────────┐   │
│            │             │ data/services/     │   │ core/       │   │
│            │             │  local_storage.dart│   │  network/   │   │
│            │             │  (SharedPrefs:     │   │  dio_client │   │
│            │             │  token, theme,     │   │             │   │
│            │             │  onboardingDone)   │   │ + raw http  │   │
│            │             └────────────────────┘   │   client    │   │
│            │                                      └──────┬──────┘   │
│            │             ┌────────────────────┐          │          │
│            └────────────▶│ core/config/       │          │          │
│                          │  EnvConfig         │          │          │
│                          │  ApiEndpoints      │          │          │
│                          └────────────────────┘          │          │
│                                       ▲                  │          │
│                                       │                  │          │
│                                  ┌────┴────────┐         │          │
│                                  │  .env       │         │          │
│                                  │  BASE_URL   │         │          │
│                                  └─────────────┘         │          │
└──────────────────────────────────────────────────────────┼──────────┘
                                                           │
                                                           ▼ HTTPS
                                  ┌────────────────────────────────────┐
                                  │  api.buildacademy.io/projects/     │
                                  │  betrade/public/api  (single env)  │
                                  │   - auth/OTP, KYC, profile         │
                                  │   - countries, languages           │
                                  │   - trade list / explore / view    │
                                  └────────────────────────────────────┘
```

**Layers (in `lib/`)**

| Layer | Folder | Responsibility |
| --- | --- | --- |
| Presentation | `presentation/` | Screens, widgets, navigation. No HTTP, no JSON. Reads providers via `Provider.of` / `context.watch` / `Consumer`. |
| State | `data/provider/` | 9 `ChangeNotifier` classes. Hold UI-relevant state (loading, error, lists, current values). Call into services. |
| Services | `data/services/` | Network calls + persistence. Mostly abstract classes with `static` methods. Returns parsed models or raw maps. |
| Models | `data/model/` | 5 DTOs with manual `fromJson` constructors. No `toJson`. |
| Core | `core/` | Cross-cutting helpers: env config, endpoint constants, Dio singleton, theme tokens, validators, animations. |
| Entry | `lib/main.dart` | Initialises `LocalStorage`, loads `.env`, locks portrait, wraps app in `MultiProvider` + `ScreenUtilInit` + `Consumer<ThemeProvider>`. |

**Key wiring quirks** (behaviour, not concerns):

- The sign-in flow (`AuthProvider`) and the sign-up flow (`SignupProvider` → `AuthService`) use **different HTTP clients** (`http` vs `dio`) and **different URL sources** (hard-coded literals vs `EnvConfig` + `ApiEndpoints`).
- `DioClient` keeps the bearer in its shared `Authorization` header via `setToken`/`removeToken`; the rest of the app reads the token from `LocalStorage` and adds the header per request.
- Theme is the only provider that drives a `Consumer` at the `MaterialApp` root; all other providers are scoped per screen.

---

## 3. Directory map

### Repo root

| Folder / file | Purpose |
| --- | --- |
| `lib/` | All Dart application code. |
| `assets/` | `images/`, `logo/`, `fonts/` (SFProRounded). Also contains the bundled `.env` reference. |
| `test/` | Test files. Currently only `widget_test.dart` (default scaffold). |
| `android/` | Android platform project (Kotlin/Gradle). Customised manifest, package `com.build.betrade`. |
| `ios/` | iOS platform project (Xcode). Customised `Info.plist` (camera/mic/photo perms, portrait-lock). |
| `web/` | Default Flutter web scaffold (unmodified). |
| `windows/` | Default Flutter Windows scaffold (unmodified). |
| `macos/` | Default Flutter macOS scaffold (unmodified). |
| `linux/` | Default Flutter Linux scaffold (unmodified). |
| `.env` | Runtime config (only `BASE_URL`). Tracked in git, bundled as Flutter asset. |
| `.gitignore` | Standard Flutter ignores; does **not** include `.env`. |
| `analysis_options.yaml` | Lints — only `package:flutter_lints/flutter.yaml`, no overrides. |
| `pubspec.yaml` / `pubspec.lock` | Dart/Flutter package manifest and lockfile. |
| `README.md` | Default Flutter scaffold (16 lines). |
| `docs/` | This folder. Audit, architecture, patterns. |

### `lib/` second level

| Folder | Purpose |
| --- | --- |
| `lib/main.dart` | App entry point — bootstraps storage, dotenv, providers, theme. |
| `lib/core/animations/` | Standalone visual effects (currently `success_animation.dart`). |
| `lib/core/config/` | `env_config.dart` (BASE_URL accessor), `api_endpoint..dart` (sic — endpoint URL builders). |
| `lib/core/network/` | `dio_client.dart` — singleton `Dio` + a `multipartInstance` for FormData uploads. |
| `lib/core/theme/` | `app_colors.dart` and `app_text_style.dart` — design tokens with light/dark `*Dynamic` helpers. |
| `lib/core/utils/validators/` | Field validators (currently phone numbers per country). |
| `lib/data/model/` | DTOs: `category_model`, `country_model`, `graph_model`, `profile_model`, `trade_model`. |
| `lib/data/provider/` | 9 `ChangeNotifier`s: `signIn_provider`, `signUp_provider`, `profile_provider`, `country_provider`, `category_provider`, `trade_provider`, `explorer_provider`, `bottom_nav_provider`, `theam_provider` (sic). |
| `lib/data/services/` | API + storage services: `auth_service`, `category_service`, `explorer_service`, `profile_service`, `trade_details_service`, `trade_service`, `local_storage`. |
| `lib/presentation/auth/` | Auth landing screen (`auth_screen`, `auth_bottom_sheet`). |
| `lib/presentation/bottom_navigation/` | Custom bottom-nav widget. |
| `lib/presentation/onboarding/` | First-run onboarding pager. |
| `lib/presentation/screens/` | All feature screens. Subfolders: `splash/`, `signin/`, `verification/` (KYC), `homeScreen/`, `explore/`, `trade/`, `portfolio/{deposit,withdraw}/`, `profile/`, `camera/`, plus `main_screen.dart`. |
| `lib/presentation/widget/` | 14 reusable widgets (buttons, headers, dropdowns, indicators, cameras, etc.). |

---

## 4. Database schema

There is **no database** in this codebase — no SQL, SQLite, Hive, Drift, Firestore, Realm, or Isar. The two persistence surfaces are: (a) **API DTO classes** that decode backend responses, and (b) **`SharedPreferences` keys** for a small amount of local app state.

### 4.1 API model classes (`lib/data/model/`)

All five classes have manual `fromJson` factory constructors (no `toJson`, no codegen). **No model references any other model**: relations on the wire are flattened into denormalised string fields (e.g., `TradeModel.categoryName` instead of a `Category` reference).

| Class | File | Source endpoint(s) | Key fields | Relationships |
| --- | --- | --- | --- | --- |
| `ProfileModel` | `lib/data/model/profile_model.dart` | `GET /profile`, `PUT /edit-profile` | `firstName`, `lastName`, `avatar`, `phone?`, `gender?`, `country?`, `currency?`, `language?` | None. `country`/`currency` are plain strings, not refs. |
| `CountryModel` | `lib/data/model/country_model.dart` | `GET /countries` | `id`, `name`, `phoneCode`, `flag`, `currency` | None. |
| `CategoryModel` | `lib/data/model/category_model.dart` | `GET /trade/categories-list` | `uuid`, `name` | None. |
| `TradeModel` | `lib/data/model/trade_model.dart` | `GET /trade/list`, `GET /trade/explore` | `uuid`, `categoryName`, `description`, `minTradeAmount` (kept as String), `image?`, `endDate` (kept as String) | None. Category denormalised. |
| `ChartData` | `lib/data/model/graph_model.dart` | `GET /chart` (defined; never invoked from UI) | `x` (← `time`), `y` (← `value`) | None. |

### 4.2 Local persistence (`SharedPreferences`)

Centralised wrapper at `lib/data/services/local_storage.dart`, initialised in `lib/main.dart` before `runApp` via `LocalStorage.init()`.

| Key | Type | Set | Get | Cleared |
| --- | --- | --- | --- | --- |
| `theme_mode` | `String` (`"dark"` / `"light"`) | `local_storage.dart:5` | `:8` | — |
| `token` | `String` (bearer) | `:15` | `:18` | `:21` (`clearToken`) |
| `onboardingDone` | `bool` | `:24` | `:27` | — |

Direct access (bypasses the wrapper):

| Key | Type | Set | Get |
| --- | --- | --- | --- |
| `isFirstTime` | `bool` | `lib/presentation/screens/homeScreen/HomeScreen.dart:102` | `:63` |

### 4.3 Implicit "schema" inferred from API responses

Several endpoints are parsed inline as `Map<String, dynamic>` without dedicated model classes. The implicit shape used by the app:

- `/login` and `/verify-otp/login` responses: `{status: bool, message: String, token?: String}`.
- `/verify-token`: `{status: bool, ...}`.
- `/trade/list?page=N`: `{status: bool, data: {items: List, ...}}`.
- `/trade/view/{uuid}`: `{status: bool, data: { ..., current_price_per_share, ... }}`.
- `/kyc/submit`: multipart upload of `id_front`, `id_back`, `selfie`.

These are not modelled as Dart classes; the audit flags this as a future-modelling opportunity but it is **not** in scope for this architecture document.

---

## 5. API surface

**Base URL (single environment)**: `https://api.buildacademy.io/projects/betrade/public/api`, defined in `.env` as `BASE_URL` and exposed via `EnvConfig.baseUrl` (`lib/core/config/env_config.dart`). Endpoint URL builders live in `lib/core/config/api_endpoint..dart` (sic — double-dot in filename, propagated to 7 importers).

There is **no second environment** (no dev / staging / prod split).

### 5.1 Auth & onboarding

| Method | Path | Caller | Client |
| --- | --- | --- | --- |
| POST | `/login` *(hard-coded URL — bypasses `EnvConfig`)* | `lib/data/provider/signIn_provider.dart:18` | `http` |
| POST | `/verify-otp/login` *(hard-coded URL)* | `lib/data/provider/signIn_provider.dart:54` | `http` |
| POST | `/register` | `lib/data/services/auth_service.dart:35` | `dio` |
| POST | `/verify-otp/register` | `lib/data/services/auth_service.dart:58` | `dio` |
| POST | `/complete-profile` (multipart) | `lib/data/services/auth_service.dart:145` | `dio.multipartInstance` |
| POST | `/logout` | `lib/data/services/auth_service.dart:190` | `dio` |
| GET | `/verify-token` *(hard-coded URL)* | `lib/data/services/auth_service.dart:213` | `dio` |
| POST | `/kyc/submit` (multipart) | `lib/presentation/screens/verification/verify_account.dart:212` | `http` |
| POST | `/profile/preferences` | `lib/presentation/screens/verification/verify_account.dart:267` | `http` |

### 5.2 Profile

| Method | Path | Caller | Client |
| --- | --- | --- | --- |
| GET | `/profile` | `lib/data/services/profile_service.dart:99` | `http` |
| PUT (multipart) | `/edit-profile` | `lib/data/services/profile_service.dart:188` | `http` |
| GET | `/languages` | `lib/presentation/screens/verification/verify_account.dart:110`, `lib/presentation/screens/profile/edit_profile.dart:79` | `http` |

### 5.3 Trades / Explore / Categories

| Method | Path | Caller | Client |
| --- | --- | --- | --- |
| GET | `/trade/list?page=N` | `lib/data/services/trade_service.dart:20`, `:59` | `http` |
| GET | `/trade/explore?search=Q` *(hard-coded URL)* | `lib/data/services/explorer_service.dart:50` | `http` |
| GET | `/trade/view/{uuid}` *(hard-coded URL)* | `lib/data/services/trade_details_service.dart:12` | `http` |
| GET | `/trade/categories-list` | `lib/data/services/category_service.dart:11` | `http` |
| GET | `/chart` | `lib/data/services/auth_service.dart:165` (defined, never called from UI) | `dio` |

### 5.4 Reference data

| Method | Path | Caller | Client |
| --- | --- | --- | --- |
| GET | `/countries` | `lib/data/provider/country_provider.dart:488` | `dio` |
| GET | `/countries` *(alternate hard-coded URL)* | `lib/presentation/screens/verification/country_services_step_one.dart:42` | `http` |

### 5.5 Endpoints absent from the codebase

The following are **not present** in `lib/`: place-order, deposit, withdraw, wallet/balance, transactions, search history, push-token registration, watchlist. The "Buy Yes / Buy No" button in `trade_page.dart:89` uses `onPressed: isEnabled ? () {} : null` — a no-op. The deposit/withdraw screens collect form data but never POST.

---

## 6. Authentication & authorization

### 6.1 Mechanism

Stateless **bearer-token** authentication. The token is a string returned by the backend after successful OTP verification.

### 6.2 Acquisition

Two paths exist (one per direction of onboarding):

- **Sign-in** — `AuthProvider.verifyOtp` (`lib/data/provider/signIn_provider.dart:45`) `POST`s to a hard-coded `https://api.buildacademy.io/.../verify-otp/login`. On `data['status'] == true`, the response's `data['token']` is persisted via `LocalStorage.setToken(...)` (`signIn_provider.dart:68` → `local_storage.dart:14`).
- **Sign-up** — `AuthService.verifyOtp` (`lib/data/services/auth_service.dart:58`) goes through Dio and `ApiEndpoints.verifyOtp`, called by `SignupProvider`.

### 6.3 Storage

Plaintext `SharedPreferences` under the key `token`, via `LocalStorage` (`lib/data/services/local_storage.dart:14-21`). No iOS Keychain, no Android Keystore, no `flutter_secure_storage`.

### 6.4 Injection into requests

Two parallel patterns coexist:

1. **Dio path** — `DioClient.setToken(token)` (`lib/core/network/dio_client.dart`) mutates the singleton's shared `options.headers['Authorization'] = 'Bearer $token'`. Set after a successful `verifyOtp` in `AuthService`. **Not restored on app launch** — Dio calls after a relaunch run unauthenticated until/unless `setToken` is called again.
2. **`http` path** — every service method reads `LocalStorage.getToken()` per request and inlines `'Authorization': 'Bearer $token'` into a `Map<String, String>` headers literal. Used by `TradeService`, `CategoryService`, `ExploreService`, `ProfileService`, `TradeDetailService`, and `AuthProvider`.

### 6.5 Validation / freshness

- **One-shot at launch** — `SplashScreen._navigateUser` (`lib/presentation/screens/splash/splash_screen.dart:51`) calls `AuthService.verifyToken(token)` (Dio, `GET /verify-token` hard-coded URL). If `false`, `LocalStorage.clearToken()` and route to `AuthScreen`.
- **Polling on the home shell** — `MainScreen._startTokenChecker` (`lib/presentation/screens/main_screen.dart:55-150`) runs a `Timer.periodic(Duration(seconds: 10))` calling `AuthService.verifyToken`. On `false`, shows a "Session Expired" dialog and pushes `AuthScreen`. (See §7.)
- **Reactive 401** — `ProfileService.getProfile` clears the token on a 401 response.

### 6.6 Authorization model

There is **no role/permission model** in the client. Every signed-in user has identical access. KYC status (returned by `/profile/preferences` and `/kyc/submit`) gates UI access to certain screens (the verification flow), but this is purely client-side branching, not enforced by the bearer.

### 6.7 Session lifecycle

| Event | What happens |
| --- | --- |
| App start, no token | Splash → `OnboardingScreen` (if first run) → `AuthScreen`. |
| App start, valid token | Splash → `verifyToken` → `MainScreen` → 10-second polling begins. |
| App start, expired token | Splash → `verifyToken` returns false → `clearToken` → `AuthScreen`. |
| Logout | `AuthService.logout()` (`POST /logout` via Dio) → `DioClient.removeToken()` → `LocalStorage.clearToken()`. |
| 401 mid-session | `ProfileService.getProfile` clears token; `MainScreen` polling raises the Session Expired dialog. |

---

## 7. Background jobs / queues

The codebase has **no background-job framework** (no WorkManager, no Isolate-based job runner, no `flutter_background_service`, no platform-specific background fetch hooks beyond Flutter defaults).

The closest mechanism is foreground UI-thread polling via `Timer.periodic`, present in two places:

| Location | Cadence | Purpose |
| --- | --- | --- |
| `lib/presentation/screens/main_screen.dart:55-150` (`_startTokenChecker`) | Every 10 seconds while `MainScreen` is mounted | Calls `AuthService.verifyToken`; on `false`, triggers the Session Expired dialog. Cancelled in `dispose`. |
| `lib/presentation/screens/profile/info_chart_screen.dart` (`Timer.periodic` in chart screen) | Sub-second cadence while the chart screen is mounted | Mutates the in-memory `List<FlSpot>` to *simulate* live price movement. No backend interaction. |

There are **no async queues**, **no Workmanager tasks**, **no Isolate workers**, and **no scheduled local notifications**.

---

## 8. Third-party integrations

The app integrates with exactly **one** external service in production paths: the Betrade backend at `api.buildacademy.io`. Every other "integration"-style package in `pubspec.yaml` is either a Flutter plugin used for on-device capability (camera, image picker, permissions) or a UI library (charts, icons).

| Category | Status | Module / file | Credentials needed |
| --- | --- | --- | --- |
| Backend REST API | **In use** end-to-end | All `data/services/*` + several providers | None at build time. The base URL comes from `.env` (`BASE_URL`). The bearer token is acquired at runtime via OTP. |
| Payment gateway (Razorpay/Stripe/etc.) | **Not present** | — | — |
| Push notifications (FCM/OneSignal) | **Not present** | — (no `firebase_messaging`, no `firebase_core`, no APNs config) | — |
| Analytics / Crash reporting | **Not present** | — (no Firebase Analytics, Mixpanel, Sentry, Crashlytics) | — |
| File / media CDN | **Not present** | Avatar + KYC media POSTed directly to backend as multipart | — |
| Social login (Google / Apple / Facebook) | **UI-only stub** — buttons exist with empty `onPressed: () {}` callbacks | `lib/presentation/screens/signin/login_screen.dart:356,394` | — (no SDKs in pubspec) |
| WebSocket / realtime | **Not present** | — | — |
| Maps | **Not present** | — | — |
| Third-party KYC vendor | **Not present** | KYC done in-house via `lib/presentation/screens/verification/` and `lib/presentation/screens/camera/` | — |

**On-device Flutter plugins that talk to native APIs (not external services)**: `camera`, `image_picker`, `permission_handler`, `path_provider`, `flutter_image_compress`, `shared_preferences`, `flutter_screenutil`, `iconsax`, `cupertino_icons`, `fl_chart`, `flutter_dotenv`. None require third-party credentials.

---

## 9. Deployment architecture

This is a **client-only mobile app** — there is no deployable server, container, Kubernetes config, Terraform, or CDN inside this repository. Deployment means producing signed mobile binaries from the Flutter source.

### 9.1 Build artifacts

| Target | Command | Output |
| --- | --- | --- |
| Android APK | `flutter build apk` (or `--split-per-abi`) | `build/app/outputs/flutter-apk/*.apk` |
| Android App Bundle | `flutter build appbundle` | `build/app/outputs/bundle/release/*.aab` |
| iOS | `flutter build ios` / `flutter build ipa` | Xcode archive / `*.ipa` |
| Web | `flutter build web` | `build/web/` (web target is the unmodified scaffold — not a real product target) |
| Desktop (Windows/macOS/Linux) | `flutter build {windows,macos,linux}` | OS-specific bundles (scaffolds only) |

### 9.2 Android packaging

`android/app/build.gradle.kts` (key values):

- `applicationId` / `namespace`: `com.build.betrade`
- `compileSdk` / `minSdk` / `targetSdk` — provided by Flutter defaults
- JDK 11
- Release build signing: **`signingConfig = signingConfigs.getByName("debug")`** (line 30) — release uses the debug keystore. There is no `key.properties`, no env-driven keystore, and no `signingConfigs { create("release") {…} }` block.
- R8 enabled: `isMinifyEnabled = true`, `isShrinkResources = true`. There is **no `proguard-rules.pro`** in the repo, so the default Flutter Proguard rules apply.

### 9.3 iOS packaging

`ios/Runner.xcodeproj/project.pbxproj` and `ios/Runner/Info.plist`:

- Bundle ID: `com.build.betrade` (Runner), `com.build.betrade.RunnerTests` (test target).
- Display name `Betrade`, `CFBundleName betrade`.
- Versioning: dynamic via `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` ← `pubspec.yaml` `version: 1.0.0+10`.
- Code signing: `CODE_SIGN_STYLE = Automatic` (test target); `CODE_SIGN_IDENTITY[sdk=iphoneos*] = "iPhone Developer"`.
- **No `DEVELOPMENT_TEAM` / `PROVISIONING_PROFILE`** set anywhere — non-interactive CI signing is unconfigured on the merged branch.
- Portrait-only orientation; usage strings present for camera/mic/photo/documents.

### 9.4 CI / CD

- **No `.github/`** at repo root → no GitHub Actions.
- **No `codemagic.yaml`** at root or `.codemagic/` on `main`.
- The remote branches `feature/codemagic-testflight` and `feature/testflight-prep` exist (not merged), suggesting a Codemagic-driven TestFlight pipeline was prototyped on a feature branch.
- No Fastlane (`Fastfile` / `fastlane/`).
- No `Dockerfile`, `Makefile`, or `scripts/` directory.
- No CI runs on `main`; all builds are local/manual today.

### 9.5 Distribution

Distribution channels are not codified in the repo. Based on configuration:

- **iOS**: TestFlight is the implied target (per the feature branches), but the merged `main` lacks the provisioning team and CI required to drive it.
- **Android**: With debug-keystore signing, builds cannot be uploaded under the developer's Play Store identity. Manual sideloading of debug-signed APKs is the only currently viable path.

### 9.6 Backend infrastructure (not in this repo)

The server at `api.buildacademy.io` is **out of scope** for this codebase. No deployment scripts, no infrastructure-as-code, no migrations, no operational runbooks for the server are stored here.

---

## 10. Key environment variables

There is exactly **one** runtime environment variable consumed by the app: `BASE_URL`.

### 10.1 Effective env vars

| Variable | Purpose | Defined in | Read by | Required |
| --- | --- | --- | --- | --- |
| `BASE_URL` | API root, e.g. `https://api.buildacademy.io/projects/betrade/public/api` | `.env` (committed) | `EnvConfig.baseUrl` (`lib/core/config/env_config.dart`) → `ApiEndpoints` (`lib/core/config/api_endpoint..dart`) | **Yes.** `EnvConfig.baseUrl` throws if missing/empty. |

### 10.2 Env vars referenced in code but never set

| Variable | Reference | Status |
| --- | --- | --- |
| `API_BASE_URL` | `lib/main.dart:33` (`dotenv.env['API_BASE_URL']` debug warning) | Never defined in `.env`. Dead branch. |

### 10.3 Compile-time configuration

Search of `lib/` for `String.fromEnvironment` / `bool.fromEnvironment` / `int.fromEnvironment` returns **zero matches**. No `--dart-define` configuration — all config is runtime via `flutter_dotenv`.

### 10.4 Loading mechanism

`lib/main.dart` calls `await dotenv.load(fileName: '.env')` before `runApp` (`flutter_dotenv: ^6.0.0`). The `.env` file is also listed under `flutter.assets` in `pubspec.yaml:39`, so it is bundled into the release APK/IPA. This means the file is read at runtime from the bundle, not from any device-side environment.

### 10.5 Where secrets would go (if they existed)

There are **no API keys, OAuth client secrets, signing secrets, or third-party credentials** in the codebase, `.env`, `AndroidManifest.xml`, or `Info.plist` — confirmed by audit. Should any be added in the future, the existing `.env` mechanism would ship them in the release bundle (extractable with `apktool`), so a different mechanism would need to be introduced.

---

## 11. Real-time / event flows

There is **no real-time channel** in the codebase: no `web_socket_channel`, `socket_io_client`, `pusher_*`, `signalr_*`, `sse_*`, `EventSource`, or platform-specific streaming SDKs. There is no client-side pub/sub bus beyond `ChangeNotifier` notifications (which are in-process, not network-aware).

Despite this being a "trade"/prediction-market UI:

- Trade prices are **static REST snapshots**: `TradeModel` carries `min_trade_amount` and `end_date`; `tradeData['current_price_per_share']` (`trade_page.dart:60`) is read once from `/trade/view/{uuid}` and never refreshed.
- The chart on `info_chart_screen.dart` is a **client-side simulation** — `Timer.periodic` mutates a hardcoded `List<FlSpot>` to fake movement. No backend subscription.
- There are no push-driven updates either — no FCM / APNs receivers, no `flutter_local_notifications`.

In short: every dynamic value the user sees is the result of a one-shot REST call when a screen is mounted (or a manually triggered refresh). There is no broadcast layer, no event queue, and no server-pushed state.

---

## 12. Server access

This repository contains **no server-side code**. Betrade's backend lives at `api.buildacademy.io/projects/betrade/public/api` and is not part of this codebase.

What the repo *does* document about server access:

| Item | Status in this repo |
| --- | --- |
| SSH config / authorized_keys | None — no server is provisioned or deployed from here. |
| Deployment user / host | None — there is no deploy target. |
| Server IP / hostname | Only the backend's public DNS hostname appears: `api.buildacademy.io` (in `.env` as `BASE_URL`, and hard-coded in the URL literals listed in §5). No IPs, no admin endpoints, no SSH endpoints. |
| Firewall / security-group rules | None. |
| Access control lists | None. |
| Bastion / VPN | None. |
| Environment-by-environment hostnames | Single environment only (`api.buildacademy.io`). No dev/staging/prod split exists in the codebase. |
| Database access | None — the app does not connect to a database directly. All persistence is HTTP-mediated via the backend. |
| Logging / observability infra | None — server logs are not in this repo. The client emits `print` / `debugPrint` only, with no remote sink. |

Operational access to the backend (provisioning, SSH, deploys, monitoring, database admin) is **owned by whoever runs `api.buildacademy.io`** and must be documented in their infrastructure repo or runbooks.

---

*End of architecture document. Companion docs: [`CODEBASE_AUDIT.md`](./CODEBASE_AUDIT.md), [`PATTERNS.md`](./PATTERNS.md).*
