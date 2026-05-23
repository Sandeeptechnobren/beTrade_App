# BeTrade — Codebase Audit

**Repository:** `github.com/Sandeeptechnobren/beTrade_App`
**Local path:** `D:\claude\betrade`
**Audit date:** 2026-05-23
**Scope:** Read-only investigation across 11 dimensions. No code modified.

> Consolidated output of three parallel investigation agents covering directory structure, tech
> stack, data flow, models, endpoints, utilities, tests, build/deploy, environment, integrations,
> and dead code. Basis for upcoming setup work.

---

## Table of Contents

1. [Top-Level Directory Structure](#1-top-level-directory-structure)
2. [Tech Stack](#2-tech-stack)
3. [Data Flow](#3-data-flow)
4. [Data Models & Relationships](#4-data-models--relationships)
5. [API Endpoints (Grouped by Module)](#5-api-endpoints-grouped-by-module)
6. [Shared Utilities & Common Patterns](#6-shared-utilities--common-patterns)
7. [Test Setup](#7-test-setup)
8. [Build, Deploy & CI/CD](#8-build-deploy--cicd)
9. [Environment Variables & Config Files](#9-environment-variables--config-files)
10. [Third-Party Integrations](#10-third-party-integrations)
11. [Dead Code, Unused Dependencies & Technical Debt](#11-dead-code-unused-dependencies--technical-debt)
12. [Critical Issues Summary](#12-critical-issues-summary)

---

## 1. Top-Level Directory Structure

### Root directories

| Directory | Purpose |
|-----------|---------|
| `lib/` | All Dart source code (~88 files). Three-layer architecture: `core/` + `data/` + `presentation/`. |
| `assets/` | UI assets — `images/`, `logo/`, `fonts/` (SFProRounded TTF). Bundles the `.env` file as a Flutter asset. |
| `test/` | Flutter tests. Single default-scaffold file `widget_test.dart` (currently broken). |
| `android/` | Android platform project (Kotlin/Gradle). Manifest, `build.gradle.kts`, Google Services JSON. Package: `com.build.betrade`. |
| `ios/` | iOS platform project (Xcode). Podfile, Info.plist, GoogleService-Info.plist. Bundle ID: `com.build.betrade`. |
| `web/` | Flutter web scaffold — unmodified default; not used in product. |
| `windows/` | Flutter Windows scaffold — unmodified default; not used. |
| `macos/` | Flutter macOS scaffold — unmodified default; not used. |
| `linux/` | Flutter Linux scaffold — unmodified default; not used. |
| `docs/` | Project documentation: `ARCHITECTURE.md`, `PATTERNS.md`, `CODEBASE_AUDIT.md` (this file), `DEPLOY_LOG.md`, `ACCESS.md`, `SSH_CONFIG.md`. |
| `tasks/` | Workstream tracking — `todo.md`, `lessons.md`, audit findings, roadmaps. |
| `.claude/` | Claude Code configuration — commands/, agents/, skills/, settings.json. |

### Key `lib/` subdirectories

| Path | Contents |
|------|----------|
| `lib/main.dart` | App entry. Bootstraps Firebase, dotenv, LocalStorage, ~14 ChangeNotifier providers, locks portrait orientation. |
| `lib/core/animations/` | `success_animation.dart` — post-signup particle effect. |
| `lib/core/config/` | `env_config.dart` (BASE_URL accessor), `api_endpoint..dart` (URL builders — note **double-dot typo in filename**). |
| `lib/core/network/` | `dio_client.dart` — singleton Dio client + multipart variant. |
| `lib/core/theme/` | `app_colors.dart`, `app_text_style.dart` — design tokens with dark-mode variants. |
| `lib/core/utils/` | Helpers and validators (e.g. `phone_number_validator.dart`). |
| `lib/data/model/` | ~13 DTOs (Trade, Profile, Country, Category, Position, Order, Quote, ChartData, BuyResponse, etc.). Manual `fromJson()`, **no code generation**. |
| `lib/data/provider/` | ~14 `ChangeNotifier` classes (auth, signup, profile, country, category, trade, explore, wallet, positions, theme, bottom nav, default amount, login, trade detail). |
| `lib/data/services/` | ~16 services. API calls + persistence: auth, profile, trade, trade_quote, trade_buy, positions, wallet, explorer, category, notification, local_storage. |
| `lib/presentation/auth/` | Auth landing screen + bottom sheet. |
| `lib/presentation/onboarding/` | First-run onboarding pager. |
| `lib/presentation/screens/` | ~20 feature screens — splash, signin, KYC, home, explore, trade, portfolio, profile, camera, main_screen. |
| `lib/presentation/widget/` | 14 reusable widgets — buttons, headers, dropdowns, indicators, camera widget. |
| `lib/presentation/bottom_navigation/` | Custom bottom-nav widget. |

---

## 2. Tech Stack

### Framework & language

- **Flutter** — SDK constraint `>=3.3.0 <4.0.0` (`pubspec.yaml:7`)
- **Dart** — 3.3+ (implied)
- **UI** — Material Design 3 (`useMaterial3: true`)

### State management

- **Provider** (`^6.1.5+1`) — ~14 `ChangeNotifier` instances registered globally in `lib/main.dart` via `MultiProvider`.
- **No** Riverpod, BLoC, GetX, MobX.

### Routing

- **Navigator 1.0** (imperative `Navigator.push` / `Navigator.pop`).
- **No** `go_router`, `auto_route`, or Navigator 2.0.
- Global `navigatorKey` defined in `lib/main.dart` for FCM background messaging.

### Local storage

- **SharedPreferences** (`^2.2.2`) — stores `token` (plaintext bearer), `theme_mode`, `onboardingDone`. Wrapped by `LocalStorage` service.
- **No** Hive, sqflite, Isar, Realm, Drift, or local Firestore cache.

### Networking

- **`dio`** (`^5.4.0`) — primary, via `DioClient` singleton (15s timeout, auth header injection, multipart variant for uploads).
- **`http`** (`^1.2.0`) — secondary, used directly in some services and the legacy sign-in provider. **Two HTTP clients coexist inconsistently.**
- **Base URL** — single environment, `https://api.buildacademy.io/projects/betrade/public/api`, read from `.env` via `EnvConfig.baseUrl`.

### Auth

- **OTP-based** (phone) — stateless bearer tokens issued by backend, persisted plaintext in SharedPreferences (security concern — see §12).

### Firebase modules used

- `firebase_core` (`^3.6.0`) — init only
- `firebase_messaging` (`^15.0.0`) — FCM push notifications
- **Not used:** Firestore, Firebase Auth, Storage, Functions, Analytics, Crashlytics

### UI libraries

- `flutter_screenutil` (`^5.9.0`) — responsive sizing, design base 393×852 (Pixel 6)
- `fl_chart` (`^1.2.0`) — chart widget for trade detail
- `iconsax` (`^0.0.8`), `lucide_icons` (`^0.257.0`), `cupertino_icons` (`^1.0.8`) — icon sets
- `pinput` (`^5.0.0`) — OTP entry (per CHANGELOG.md, migrated 2026-05-05)

### Image / camera

- `camera` (`^0.12.0+1`), `image_picker` (`^1.0.7`), `flutter_image_compress` (`^2.4.0`), `path_provider` (`^2.1.5`)

### Utilities

- `flutter_dotenv` (`^6.0.0`) — `.env` loader (single key: `BASE_URL`)
- `permission_handler` (`^12.0.1`) — runtime perms
- `flutter_local_notifications` (`^17.0.0`) — local notification display

### Code generation

- **None.** No `build_runner`, `freezed`, `json_serializable`, or `equatable`. All models are hand-written with manual `fromJson`.

### Linting

- `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`. No custom overrides.

---

## 3. Data Flow

### Boot sequence (`lib/main.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()` + error zone setup
2. `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` — FCM init
3. `await LocalStorage.init()` — load `SharedPreferences`
4. `await dotenv.load(fileName: ".env")` — load `BASE_URL`
5. Register FCM background handler; set foreground notification options
6. Lock portrait orientation via `SystemChrome.setPreferredOrientations`
7. Wrap app in `MultiProvider` (~14 ChangeNotifiers)
8. Wrap in `ScreenUtilInit` (393×852)
9. `home: SplashScreen()` — initial route
10. Post-frame: `NotificationService.init()` runs (perm request, FCM token fetch, listener setup)

### Layered architecture

```
Presentation (lib/presentation/)
    ↓ context.watch<T>() / context.read<T>()
Data Layer
├── Providers (lib/data/provider/)   — ~14 ChangeNotifiers holding mutable state
├── Services  (lib/data/services/)    — static methods, HTTP clients + LocalStorage
└── Models    (lib/data/model/)       — read-only DTOs with manual fromJson()
    ↓ http.get/post OR DioClient.instance
Core (lib/core/)
├── config/  — EnvConfig, ApiEndpoints
├── network/ — DioClient singleton
├── theme/   — AppColors, AppTextStyle
└── utils/   — Validators, animations
    ↓
Backend REST API @ api.buildacademy.io
```

### Representative flow — "Place a Buy trade"

1. **UI** — User enters cost in `lib/presentation/screens/trade/trade_page.dart`; `onChanged` calls `context.read<TradeDetailProvider>().getQuote(marketUuid, 'yes', cost)`.
2. **Provider** — `TradeDetailProvider.getQuote()` sets `isLoading = true`, calls `TradeQuoteService.quote(...)`.
3. **Service** — `lib/data/services/trade_quote_service.dart` reads token via `LocalStorage.getToken()`, builds URL via `ApiEndpoints.tradeQuote(uuid)`, dispatches via `DioClient.instance.post(...)`.
4. **Network** — `DioClient` adds `Authorization: Bearer <token>`; POST to `/trade/{uuid}/quote`.
5. **Parse** — `QuoteModel.fromJson(response.data['data'])` returns typed quote.
6. **State update** — Provider stores `quoteModel`, sets `isLoading = false`, `notifyListeners()`.
7. **UI rebuild** — `Consumer<TradeDetailProvider>` rebuilds, shows "You'll receive X shares, max payout Y GHS".
8. **Buy tap** — `TradeBuyService.generateIdempotencyKey()` produces a v4 UUID; `TradeBuyService.buy(uuid, side, cost, key)` POSTs to `/trade/{uuid}/buy`.
9. **Response** — `BuyResponse.fromJson(...)` parses nested `order`, `quote`, `wallet_balance`.
10. **UI** — Success dialog + optional `PositionsProvider.getAll()` refresh.

### Global state

- `MultiProvider` in `lib/main.dart` exposes all providers app-wide.
- Token persists across restarts via `LocalStorage` → `SharedPreferences`.
- Theme + onboarding flag persist the same way.
- Token is re-validated on launch and every 10s in `MainScreen` (polling pattern).
- **No** central state machine — each provider owns its own lifecycle.

---

## 4. Data Models & Relationships

All models live in `lib/data/model/`. No code generation — every class has a hand-written `factory fromJson(Map<String, dynamic>)` constructor. **No `toJson()`** — outbound payloads are built as inline `Map<String, dynamic>` literals in services. Defensive parsing uses `?? ""` / `?? 0.0` defaults (except `CountryModel` and `ChartData`, which lack defaults and can throw on missing fields).

| Model | File | Represents | Backend source |
|-------|------|-----------|----------------|
| `TradeModel` | `trade_model.dart` | Market listing — uuid, categoryName, description, minTradeAmount, image, endDate | `GET /trade/list`, `/trade/explore` |
| `TradeDetailModel` | `trade_detail_model.dart` | Market detail — uuid, title, description, categoryName, currentPricePerShare | `GET /trade/view/{uuid}` |
| `ProfileModel` | `profile_model.dart` | User profile — firstName, lastName, avatar, phone, gender, country, currency, language, email. Has `_fixAvatar()` to strip duplicate `https://` prefixes. | `GET /profile`, `/verify-otp/login` |
| `CountryModel` | `country_model.dart` | Country meta — id, name, phoneCode, flag, currency | `GET /countries` |
| `CategoryModel` | `category_model.dart` | Trade category — uuid, name | `GET /trade/categories-list` |
| `PositionModel` | `position_model.dart` | Open position — shares, avgCostGhs, currentPrice, costBasisGhs, marketValueGhs, unrealisedPnlGhs, realizedPnlGhs, maxPayoutGhs. Computed `unrealisedPnlPct`, `isYes`. | `GET /positions`, `/positions/{uuid}` |
| `MarketPositionsModel` | `position_model.dart` | Both sides of one market — marketUuid, description, sides[] | `GET /positions/{market_uuid}` |
| `QuoteModel` | `quote_model.dart` | LMSR quote — outcomeSlug, costGhs, shares, avgPricePerShare, newPriceAfterFill, maxPayoutGhs, potentialProfitGhs, feeGhs | `POST /trade/{uuid}/quote` |
| `OrderModel` | `order_model.dart` | Filled order — shares, avgFillPrice, totalCostGhs, feeGhs | `POST /trade/{uuid}/buy` (`data.order`) |
| `BuyResponse` | `buy_response.dart` | Buy envelope — success, message, code, order, quote, walletBalance | `POST /trade/{uuid}/buy` (full) |
| `ChartData` | `graph_model.dart` | Chart point — x (time), y (value) | `GET /chart` (currently unused) |
| `DefaultSettingsModel` | `default_settings_model.dart` | User's default trade amount | `GET /userDefaultSettings/index` |
| `ProfileNotificationPreferencesModel` | `profile_notification_preferences_model.dart` | Notification opt-ins (model exists, mostly unused) | `POST /profile/preferences` |

### Relationships

Models are **denormalized DTOs** with no foreign-key pattern. Example:

- `TradeModel.categoryName` is a denormalized string — NOT a reference to `CategoryModel`.
- `PositionModel` embeds `market { uuid, description, image, category_name, ... }` and `outcome { slug, label, is_winner }` as nested dicts, not via referenced models.
- `BuyResponse` contains nested `OrderModel?` + `QuoteModel?` + `walletBalance` for a single transactional response.

---

## 5. API Endpoints (Grouped by Module)

All endpoints route through `ApiEndpoints` static builders + `DioClient` singleton. Base URL: `https://api.buildacademy.io/projects/betrade/public/api`.

### Auth (7)

| Method | Path | Service method |
|--------|------|----------------|
| POST | `/register` | `AuthService.sendOtp()` |
| POST | `/verify-otp/register` | `AuthService.verifyOtp()` |
| POST | `/complete-profile` *(multipart)* | `AuthService.completeSignup()` |
| POST | `/login` | `AuthService.sendLoginOtp()` |
| POST | `/verify-otp/login` | `AuthService.verifyLoginOtp()` |
| GET | `/verify-token` | `AuthService.verifyToken()` |
| POST | `/logout` | `AuthService.logout()` |

### Profile (2)

| Method | Path | Service method |
|--------|------|----------------|
| GET | `/profile` | `ProfileService.getProfile()` |
| PUT | `/edit-profile` *(multipart)* | `ProfileService.updateProfile()` |

### Trading & Quotes (7)

| Method | Path | Service method |
|--------|------|----------------|
| GET | `/trade/list?page=N` | `TradeService.getTrades()` |
| GET | `/trade/explore?search=Q` | `ExploreService.searchTrades()` |
| GET | `/trade/categories-list` | `CategoryService.getCategories()` |
| GET | `/trade/view/{uuid}` | `TradeDetailService.getTradeDetail()` |
| POST | `/trade/{uuid}/quote` | `TradeQuoteService.quote()` |
| GET | `/trade/{uuid}/chart` | `AuthService.fetchChartData()` *(defined, never called)* |
| POST | `/trade/{uuid}/buy` | `TradeBuyService.buy()` |

### Positions (2)

| Method | Path | Service method |
|--------|------|----------------|
| GET | `/positions` | `PositionsService.getAll()` |
| GET | `/positions/{market_uuid}` | `PositionsService.getForMarket()` |

### Wallet (4)

| Method | Path | Service method |
|--------|------|----------------|
| GET | `/wallet` | `WalletService.getBalance()` |
| GET | `/wallet/transactions?type=&page=` | `WalletService.getTransactions()` |
| POST | `/wallet/deposit` | `WalletService.requestDeposit()` |
| POST | `/wallet/withdraw` | `WalletService.requestWithdraw()` |

### KYC (2)

| Method | Path | Caller |
|--------|------|--------|
| POST | `/kyc/submit` *(multipart)* | Called directly from `lib/presentation/screens/verification/verify_account.dart` (no dedicated service) |
| POST | `/profile/preferences` | Called directly from same screen |

### Settings & Misc (5)

| Method | Path | Consumer |
|--------|------|----------|
| POST | `/fcm/save-token` | `AuthService.saveFcmToken()` |
| GET | `/countries` | `CountryProvider` (direct `DioClient.get`) |
| GET | `/languages` | Defined in `ApiEndpoints.languages` — no consumer found |
| GET | `/notificationPreferences` | Defined — no consumer found |
| GET | `/userDefaultSettings/index` | `DefaultAmountProvider` |
| POST | `/userDefaultSettings/update` | `DefaultAmountProvider` |

**Total surface area: ~29 endpoints.**

---

## 6. Shared Utilities & Common Patterns

### Core utilities (`lib/core/`)

- `core/theme/app_colors.dart` — static color tokens, with `*Dynamic(BuildContext)` variants for dark mode
- `core/theme/app_text_style.dart` — `TextStyle` presets using `SFProRounded` + `flutter_screenutil` for responsive sizing
- `core/config/env_config.dart` — single source of truth for `BASE_URL`; throws if missing
- `core/config/api_endpoint..dart` — **double-dot typo in filename** propagated to 7 importers; defines 26 static endpoint builders
- `core/network/dio_client.dart` — Dio singleton (15s timeout) + multipart variant (30s, copies auth header); `setToken()` / `removeToken()` mutate the shared header
- `core/utils/validators/phone_number_validator.dart` — country-aware phone validation (+91, +1, +44, with fallback)
- `core/animations/success_animation.dart` — `SuccessScreen` particle/scale effect

### Reusable widgets (`lib/presentation/widget/`, 14 total)

| Widget | Purpose |
|--------|---------|
| `primary_button.dart` | Canonical purple gradient button |
| `purple_button.dart` | Alternate purple button variant |
| `common_header.dart` | Header with back arrow + title |
| `Common_header_withlogo.dart` | Header with logo (**PascalCase filename — convention break**) |
| `common_bottom_sheet.dart` | `CommonBottomSheet.open(...)` utility |
| `common_share_button.dart` | Share button (the only `CupertinoIcons` consumer) |
| `country_picker.dart` | Country dropdown |
| `custom_camera.dart` | Embedded camera widget (~52% commented-out code) |
| `customSnackBar.dart` | Snackbar helper |
| `dark_mode_toggle.dart` | Dark-mode switcher |
| `step_indecator.dart` | Step indicator (**misspelling: indecator → indicator**) |
| `buy_bottom_sheet.dart` | Trade buy flow sheet |
| `deposit_success.dart` | Post-deposit success modal |
| `icon_container.dart`, `leading_icon.dart`, `rounded_tab_indicator.dart` | Small wrappers |

### Service / call conventions

- Services are abstract classes with `static` methods.
- Each call reads token via `LocalStorage.getToken()` and injects `Authorization: Bearer <token>`.
- Error handling: per-call `try/catch` with `print` / `debugPrint` (**~202 print statements** across services) and sentinel returns (`[]`, `null`, `false`).
- Outbound payloads built ad-hoc as `Map<String, dynamic>` literals or `MultipartRequest` form fields — no `toJson()` anywhere.
- Inbound payloads parsed via manual `Model.fromJson()` with defensive defaults.

---

## 7. Test Setup

- **Framework:** `flutter_test` only (bundled with Flutter SDK)
- **Location:** `test/widget_test.dart` — single file, **the default Flutter scaffold, unmodified**
- **Status:** **BROKEN.** `flutter test` fails on `main` — the scaffold test expects a counter UI (`find.text('0')`, `find.byIcon(Icons.add)`) that does not exist in `MyApp` (which renders `SplashScreen`).
- **Coverage:** Effectively **0%** across ~87 source files.
- **Mocking:** None configured — no `mockito`, `mocktail`, `bloc_test`, `golden_toolkit`, `fake_async`.
- **Integration tests:** `integration_test/` folder does not exist.
- **Fixtures / helpers:** None.

### Commands

```bash
flutter test                       # Currently fails
flutter test --coverage            # → coverage/lcov.info (gitignored)
```

### Recommended path forward

1. Delete or rewrite `test/widget_test.dart`.
2. Add `mocktail` + `integration_test` to `dev_dependencies`.
3. First real test: mock providers → pump `MyApp` → assert `SplashScreen` renders.
4. Unit tests for services using mocked `http`/`Dio`.
5. Widget tests for high-reuse widgets (`PrimaryButton`, `CommonHeader`).

---

## 8. Build, Deploy & CI/CD

### Local commands

```bash
# Setup
flutter pub get
flutter pub upgrade
flutter pub outdated

# Dev
flutter run
flutter analyze

# Test
flutter test
flutter test --coverage

# Release
flutter build apk                    # Release APK
flutter build apk --split-per-abi    # Per-ABI APKs
flutter build appbundle              # AAB for Play Store
flutter build ios                    # iOS app
flutter build ipa                    # IPA archive for TestFlight

# Utility
flutter clean
flutter doctor
dart format lib/
dart fix --apply
```

### Android build (`android/app/build.gradle.kts`)

- `applicationId` / `namespace`: `com.build.betrade`
- `compileSdk` / `targetSdk`: 34 — `minSdk`: 21 — JDK 11
- `isMinifyEnabled = true`, `isShrinkResources = true`
- **⚠ Release builds use the DEBUG keystore** (line 30): `signingConfig = signingConfigs.getByName("debug")`. No `key.properties` file; no release signing config. **Must be fixed before Play Store distribution.**

### iOS build (`ios/Runner.xcodeproj`)

- Bundle ID: `com.build.betrade`, Display: `Betrade`
- Version dynamic via `$(FLUTTER_BUILD_NAME)+$(FLUTTER_BUILD_NUMBER)` from `pubspec.yaml` (`1.0.0+10`)
- iOS 13.0+ (`Podfile:1`)
- **⚠ No `DEVELOPMENT_TEAM` configured, no provisioning profile.** TestFlight/AppStore distribution blocked until team is set.
- Permissions in `Info.plist`: Camera, Microphone, Photo Library (read + add), Documents Folder

### CI / CD

- `.github/workflows/` — **none on `main`.**
- `codemagic.yaml` — **none on `main`.** Feature branches `feature/codemagic-testflight` and `feature/testflight-prep` exist with prototyped pipelines but are **unmerged**.
- `fastlane/`, `bitrise.yml` — none.
- **All current deployments are manual / local builds.**

### Firebase deploy

`firebase.json` configures Android (`betrade-new`) and iOS (`betrade-new`) for credential generation. **No Firestore deploy, no Functions, no Hosting deploy** configured.

---

## 9. Environment Variables & Config Files

### Environment variables (single source: `.env`)

| Variable | Purpose | Required | Used by |
|----------|---------|----------|---------|
| `BASE_URL` | API root URL → `https://api.buildacademy.io/projects/betrade/public/api` | **Yes** | `EnvConfig.baseUrl` → `ApiEndpoints` |

- File: `.env` at repo root (committed to git ⚠; bundled as Flutter asset)
- Load: `dotenv.load(fileName: ".env")` in `lib/main.dart` before `runApp`
- Access: `EnvConfig.baseUrl` (throws if empty)

### Configuration files

| File | Purpose | Tracked |
|------|---------|---------|
| `.env` | Runtime API config | **Yes (in git ⚠)** |
| `pubspec.yaml` | Package manifest | Yes |
| `pubspec.lock` | Dependency lockfile | Yes |
| `analysis_options.yaml` | Lint rules | Yes |
| `firebase.json` | Firebase CLI config | Yes |
| `lib/firebase_options.dart` | Firebase credentials (auto-gen, all platforms) | Yes ⚠ |
| `android/app/google-services.json` | Android Firebase credentials | Yes ⚠ |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase credentials | Yes ⚠ |
| `ios/Podfile` | CocoaPods deps | Yes |
| `android/app/build.gradle.kts` | Android Gradle config | Yes |
| `ios/Runner/Info.plist` | iOS app metadata + permissions | Yes |

### ⚠ Secrets exposure

The following committed files contain API keys (Firebase) and are present on `main`:

- `android/app/google-services.json` (Android Firebase API key — project `betrade-new`)
- `ios/Runner/GoogleService-Info.plist` (iOS Firebase API key)
- `lib/firebase_options.dart` (cross-platform Firebase keys)
- `.env` (BASE_URL — not a secret, but still exposes infrastructure)

Note: Firebase API keys are technically "public" identifiers, but they must be guarded by Firebase Security Rules. Verify rules are properly locked down. `.gitignore` does **not** currently exclude `.env` or the Firebase JSON files.

### Lint rules

`analysis_options.yaml` includes the default `package:flutter_lints/flutter.yaml`. No custom overrides.

### Load-bearing documentation

`CLAUDE.md` (root, ~131 lines) flags:

- **DO NOT** store auth tokens plaintext in `SharedPreferences` for production (currently the case)
- Release Android builds use the debug keystore — must be fixed
- No CI on `main`; Codemagic config exists on a feature branch
- Backend is a separate Laravel API at `api.buildacademy.io` — not in this repo

---

## 10. Third-Party Integrations

### Firebase

| Package | Use |
|---------|-----|
| `firebase_core ^3.6.0` | Init |
| `firebase_messaging ^15.0.0` | FCM push notifications |
| `flutter_local_notifications ^17.0.0` | Local notification display |

Two Firebase projects appear in `firebase_options.dart`:

- Web/Windows/macOS: `betrade-4efd1`
- Android/iOS: `betrade-new`

FCM token is fetched in `NotificationService.init()` and POSTed to `/fcm/save-token`. Background handler registered in `lib/main.dart`. Foreground messages routed to `flutter_local_notifications`. **Firebase Realtime DB and Storage are configured but NOT used in code.**

### Camera / image

`camera` + `image_picker` + `flutter_image_compress` + `path_provider` — used in KYC selfie / document capture and profile avatar upload flows; uploaded via `DioClient.multipartInstance`.

### Charts

`fl_chart` — used in `info_chart_screen.dart` and `trade_details_page.dart` for trade price history. Note: live price refresh is simulated client-side (no backend stream).

### UI / icons

`flutter_screenutil`, `iconsax`, `lucide_icons` (minor — trash + dollar-sign only), `cupertino_icons` (one usage), `pinput` (OTP entry).

### Networking

`dio` + `http` (two clients coexist), `http_parser` (no direct usage — transitive only).

### Storage

`shared_preferences` (token, theme, onboarding flag). **No SQL or NoSQL local DB.**

### Env

`flutter_dotenv` (single key: `BASE_URL`).

### NOT present

- Payment gateways (Razorpay, Stripe, PayPal, in-app purchases) — wallet deposit/withdraw is backend-driven, no client-side payment SDK
- Analytics (Mixpanel, Amplitude, Segment, Firebase Analytics)
- Crash reporting (Crashlytics, Sentry)
- Trading data APIs (Zerodha Kite, Upstox, Alpha Vantage, Finnhub, Polygon, Binance, CoinGecko, TradingView, Yahoo Finance) — the app talks **only** to the proprietary backend at `api.buildacademy.io`
- News APIs
- Social auth (Google Sign-In, Apple Sign-In, Facebook) — OTP-only
- Maps / location
- Social sharing (just a UI button, no share intent integration confirmed)

---

## 11. Dead Code, Unused Dependencies & Technical Debt

### Unused / mostly unused dependencies

| Package | Status |
|---------|--------|
| `http_parser ^4.1.2` | **Unused** — transitive only, zero direct imports in `lib/` |
| `cupertino_icons ^1.0.8` | **Mostly unused** — single icon (`arrowshape_turn_up_right`) in `common_share_button.dart` |
| `flutter_launcher_icons ^0.14.4` | Build-time tool only (`dev_dependencies`) |

### High-volume commented-out code

| File | Lines of dead comments | Notes |
|------|-----------------------|-------|
| `lib/data/provider/country_provider.dart` | ~457 | Four stale earlier versions of the provider before the active one |
| `lib/data/services/auth_service.dart` | ~87 | Two earlier `sendOtp` implementations |
| `lib/data/services/profile_service.dart` | ~76 | Full older `http`-based implementation before Dio migration |
| `lib/presentation/widget/custom_camera.dart` | ~280 (~52% of file) | Older camera implementations |
| `lib/core/network/dio_client.dart` | ~20 | Older singleton definition at top of file |
| `lib/data/services/trade_service.dart` | inline (lines 11–18, 55–62) | Old `http.get` calls superseded by `DioClient` |

### Naming / filename inconsistencies (pre-existing)

| File | Issue |
|------|-------|
| `lib/core/config/api_endpoint..dart` | **Double-dot typo** in filename — propagated to 7 importers |
| `lib/presentation/widget/Common_header_withlogo.dart` | PascalCase (should be snake_case) |
| `lib/presentation/widget/step_indecator.dart` | Misspelling: `indecator` → `indicator` |
| `lib/presentation/widget/customSnackBar.dart` | camelCase (should be snake_case) |

### Orphaned / underused models

No true orphans — all model files are imported. But these have limited or no live use:

- `buy_response.dart` — used only in `trade_buy_service.dart`
- `quote_model.dart`, `quote_response.dart` — used only in `trade_quote_service.dart`
- `order_model.dart` — imported but not exercised in any visible UI flow
- `graph_model.dart` — used only by `fetchChartData()` in `auth_service.dart`, which is **never called**
- `profile_notification_preferences_model.dart` — model exists, no consumer found

### Endpoints defined but never consumed

- `ApiEndpoints.languages` (`GET /languages`)
- `ApiEndpoints.notificationPreferences` (`GET /notificationPreferences`)
- `GET /trade/{uuid}/chart` — fetcher exists, never called

### Inconsistencies to consolidate

| Pattern | Where | Action |
|---------|-------|--------|
| Two HTTP clients (`http` + `dio`) | Across services; legacy in `signin_provider.dart` | Standardize on `dio` via `DioClient` |
| Direct `dotenv.env['BASE_URL']` reads | `dio_client.dart:27` | Replace with `EnvConfig.baseUrl` |
| Hard-coded URLs in some services | `explorer_service.dart`, `trade_details_service.dart` | Move to `ApiEndpoints` |
| `print` / `debugPrint` everywhere | ~202 statements in services | Introduce a structured logger; route errors to Crashlytics/Sentry |

### Dependency version health

- Dart SDK constraint `>=3.3.0 <4.0.0` — reasonable.
- No git or local-path dependencies detected in `pubspec.yaml`.
- Firebase packages on recent stable versions (`firebase_core 3.6.0`, `firebase_messaging 15.0.0`).
- No obvious major-version-behind packages — but `flutter pub outdated` should be run before any production cut.

### Refactor blast-radius warnings

- **High:** Renaming `api_endpoint..dart` to `api_endpoint.dart` — 7 importers need updating in lockstep.
- **Medium:** Merging the two HTTP clients — many services touched.
- **Low:** Renaming individual widgets or files with the `step_indecator`/PascalCase issues — internal-only.

---

## 12. Critical Issues Summary

Issues to address **before any production release**, ranked by severity:

### Security

1. **🔴 Auth tokens stored plaintext in `SharedPreferences`** — migrate to `flutter_secure_storage`. (Flagged in `CLAUDE.md`.)
2. **🔴 Release Android builds signed with the debug keystore** (`android/app/build.gradle.kts:30`) — create a release keystore and `key.properties` file before Play Store upload.
3. **🟡 `.env` and Firebase service files committed to git** — add to `.gitignore`, verify Firebase Security Rules are locked, consider regenerating keys if repo is/was public.
4. **🟡 Check `android:usesCleartextTraffic`** — if `true` in `AndroidManifest.xml`, should be `false` for production.
5. **🟡 iOS team / provisioning profile not configured** — blocks TestFlight / AppStore distribution.

### Reliability

6. **🔴 Tests are broken** — `flutter test` fails on `main`; coverage ~0%. Default scaffold test references widgets that don't exist.
7. **🟡 No CI on `main`** — Codemagic config exists only on unmerged feature branches.
8. **🟡 Two HTTP clients coexist** (`http` + `dio`) — inconsistent error handling and timeout configuration.
9. **🟡 `print`-based logging only** — no structured logs, no crash reporting (no Crashlytics or Sentry).

### Maintainability

10. **🟢 Filename typo: `api_endpoint..dart`** — propagated to 7 importers; fix in one coordinated change.
11. **🟢 Heavy commented-out code** — ~900+ lines across 6 files; safe to delete after git history capture.
12. **🟢 Unused endpoints / models** — `/languages`, `/notificationPreferences`, `/chart`, plus several models with no callers.
13. **🟢 Filename style inconsistencies** — `Common_header_withlogo.dart` (PascalCase), `step_indecator.dart` (misspelling), `customSnackBar.dart` (camelCase).

### Missing (by design or oversight — confirm with product)

- No analytics
- No crash reporting
- No deep linking / URI scheme handling
- No WebSocket / real-time price stream (chart price is simulated client-side)
- No background task scheduling beyond UI `Timer.periodic`
- No payment gateway client SDK (wallet relies entirely on backend)

---

**End of audit.** Stack is a fairly conventional Flutter + Provider + REST mobile client; the main backend lives separately at `api.buildacademy.io` (Laravel, per `CLAUDE.md`). Architecture is reasonable for current scope; the test, signing, and secrets-management gaps are the biggest blockers before a production cut.
