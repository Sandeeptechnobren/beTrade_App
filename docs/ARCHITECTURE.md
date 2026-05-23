# BeTrade — Architecture

**Repository:** `github.com/Sandeeptechnobren/beTrade_App`
**Local path:** `D:\claude\betrade`
**Date:** 2026-05-23
**Companion docs:** [`CODEBASE_AUDIT.md`](./CODEBASE_AUDIT.md) (findings/concerns), [`PATTERNS.md`](./PATTERNS.md) (style guide), [`ACCESS.md`](./ACCESS.md) (credentials), [`SSH_CONFIG.md`](./SSH_CONFIG.md) (server access).

> Purely descriptive. Documents only what exists in the code today. Concerns and recommendations live in the audit.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [High-Level Architecture](#2-high-level-architecture)
3. [Directory Map](#3-directory-map)
4. [Database Schema](#4-database-schema)
5. [API Surface](#5-api-surface)
6. [Authentication & Authorization](#6-authentication--authorization)
7. [Background Jobs / Queues](#7-background-jobs--queues)
8. [Third-Party Integrations](#8-third-party-integrations)
9. [Deployment Architecture](#9-deployment-architecture)
10. [Key Environment Variables](#10-key-environment-variables)
11. [Real-Time / Event Flows](#11-real-time--event-flows)
12. [Server Access](#12-server-access)

---

## 1. System Overview

BeTrade is a Flutter mobile client (Android + iOS) for a **prediction-market / "trade"** product. Users browse markets, fetch live LMSR quotes, place buy orders, track positions, and manage a wallet — all via REST calls to a backend operated **outside this repository**. State is managed with `provider` `ChangeNotifier`s; the bearer token, theme preference, and onboarding flag persist in `SharedPreferences`. There is **no application database, no real-time channel, and no server-side code in this repo** — the client talks to a single Laravel REST API at `api.buildacademy.io`, plus Firebase Cloud Messaging for push notifications.

---

## 2. High-Level Architecture

```
+-------------------------------------------------------------+
|                  Flutter Mobile App                         |
|                                                             |
|  +-----------------------------------------------------+    |
|  |  Presentation (lib/presentation/)                   |    |
|  |  splash | signin | KYC | home | explore | trade    |    |
|  |  portfolio | profile | onboarding | bottom_nav     |    |
|  +------------------------|----------------------------+    |
|     context.read<T>() / context.watch<T>()                  |
|                           v                                 |
|  +-----------------------------------------------------+    |
|  |  Data Layer (lib/data/)                             |    |
|  |  +-------------+  +-------------+  +-------------+  |    |
|  |  | provider/   |  | services/   |  | model/      |  |    |
|  |  | ~14 CNs     |  | ~16 static  |  | ~13 DTOs    |  |    |
|  |  | (state)     |  | service cls |  | (manual     |  |    |
|  |  |             |  |             |  |  fromJson)  |  |    |
|  |  +------|------+  +------|------+  +-------------+  |    |
|  +---------|-----------------|--------------------------+   |
|            v                 v                              |
|  +-----------------------------------------------------+    |
|  |  Core (lib/core/)                                   |    |
|  |  config/     network/      theme/      utils/       |    |
|  |  EnvConfig   DioClient     AppColors   Validators   |    |
|  |  ApiEndpts   (singleton)   AppText                  |    |
|  +-----------------------------------------------------+    |
|            |                                                |
+------------|------------------------------------------------+
             | HTTPS (Bearer token in Authorization header)
             v
+-------------------------------------------------------------+
|        Backend REST API (operated outside this repo)        |
|        https://api.buildacademy.io/projects/                |
|                  betrade/public/api                         |
|        - OTP auth, profile, KYC                             |
|        - markets / quotes / orders                          |
|        - positions, wallet                                  |
+-------------------------------------------------------------+

                  +------------------------+
                  |  Firebase Cloud        |
                  |  Messaging (FCM)       |
                  |  - betrade-new (mob)   |
                  |  - betrade-4efd1 (web) |
                  +-----------|------------+
                              | push (background + foreground)
                              v
                      Flutter app handler
                      (lib/main.dart +
                       notification_services.dart)
```

### Major components

| Component | Owner | Role |
|-----------|-------|------|
| **Flutter Mobile App** | This repo | UI + business logic. Three layers: `presentation/` (screens & widgets), `data/` (providers, services, models), `core/` (config, network, theme, utils). |
| **Backend REST API** | Operated externally (not in this repo) | Source of truth for users, markets, prices (LMSR), orders, positions, wallet. Laravel app at `api.buildacademy.io` per `CLAUDE.md`. |
| **Firebase project `betrade-new`** | Mobile FCM credentials | Push notifications to Android + iOS. |
| **Firebase project `betrade-4efd1`** | Web/desktop FCM credentials | Configured in `firebase_options.dart` for Web/Windows/macOS targets (those platforms are unused in product). |
| **`.env` (bundled asset)** | Local repo | Single key: `BASE_URL` pointing at the backend API. |

### Request lifecycle (typical)

1. Screen calls `context.read<SomeProvider>().method()`.
2. Provider sets `isLoading = true`, calls a static `SomeService.method()`.
3. Service reads token via `LocalStorage.getToken()`, builds URL with `ApiEndpoints.x()`, dispatches via `DioClient.instance` (or `http` for the legacy paths).
4. `DioClient` injects `Authorization: Bearer <token>` and times out at 15s (30s for multipart).
5. Response JSON is parsed via a manual `Model.fromJson(...)` constructor.
6. Provider stores the result, calls `notifyListeners()`.
7. `Consumer<T>` rebuilds the affected widgets.

---

## 3. Directory Map

### Top-level

| Folder | Purpose |
|--------|---------|
| `lib/` | All Dart source (~88 files). |
| `assets/` | Images, logo, fonts (SFProRounded TTF). Also bundles `.env` as a Flutter asset. |
| `test/` | Flutter tests. Currently only the broken default scaffold (`widget_test.dart`). |
| `android/` | Android platform project (Kotlin/Gradle). Package `com.build.betrade`. |
| `ios/` | iOS platform project (Xcode). Bundle ID `com.build.betrade`. |
| `web/` | Default Flutter web scaffold — unused in product. |
| `windows/` | Default Flutter Windows scaffold — unused. |
| `macos/` | Default Flutter macOS scaffold — unused. |
| `linux/` | Default Flutter Linux scaffold — unused. |
| `docs/` | Project docs — `ARCHITECTURE.md` (this), `CODEBASE_AUDIT.md`, `PATTERNS.md`, `ACCESS.md`, `SSH_CONFIG.md`, `DEPLOY_LOG.md`. |
| `tasks/` | Workstream tracking — `todo.md`, `lessons.md`, plans, findings. |
| `.claude/` | Claude Code configuration (commands, agents, skills, settings). |

### `lib/` second-level

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry. Boots Firebase, dotenv, LocalStorage; registers `MultiProvider` + `ScreenUtilInit`; renders `SplashScreen`. |
| `lib/firebase_options.dart` | Auto-generated Firebase platform credentials. |
| `lib/core/animations/` | `success_animation.dart` — post-signup particle effect. |
| `lib/core/config/` | `env_config.dart` (BASE_URL accessor), `api_endpoint..dart` (URL builders — note **double-dot typo in filename**). |
| `lib/core/network/` | `dio_client.dart` — Dio singleton + multipart variant; manages shared Authorization header. |
| `lib/core/theme/` | `app_colors.dart`, `app_text_style.dart` — design tokens with dark-mode variants. |
| `lib/core/utils/` | Helpers + validators (e.g. `phone_number_validator.dart`). |
| `lib/data/model/` | ~13 DTOs (Trade, TradeDetail, Profile, Country, Category, Position, MarketPositions, Quote, Order, BuyResponse, ChartData, DefaultSettings, ProfileNotificationPreferences). Manual `fromJson()`, no code generation. |
| `lib/data/provider/` | ~14 `ChangeNotifier`s (auth, signup, login, profile, country, category, trade, trade detail, explore, wallet, positions, theme, bottom nav, default amount). |
| `lib/data/services/` | ~16 static service classes — auth, profile, trade, trade_quote, trade_buy, positions, wallet, explorer, category, notification, local_storage, etc. |
| `lib/presentation/auth/` | Auth landing screen + bottom sheet (post-onboarding). |
| `lib/presentation/onboarding/` | First-run onboarding pager. |
| `lib/presentation/screens/` | ~20 feature screens — `splash/`, `signin/`, `verification/` (KYC), `homeScreen/`, `explore/`, `trade/`, `portfolio/` (deposit + withdraw), `profile/`, `camera/`, plus `main_screen.dart` (IndexedStack tab host). |
| `lib/presentation/widget/` | 14 reusable widgets — buttons, headers, dropdowns, indicators, camera, snackbar helper. |
| `lib/presentation/bottom_navigation/` | Custom bottom-nav widget driven by `BottomNavProvider`. |

---

## 4. Database Schema

> **No application database exists.** The app does not connect to any DBMS (SQL or NoSQL), no local cache layer (Hive, sqflite, Isar, Drift, Realm), and Firestore is configured in `firebase_options.dart` but never read or written. All persistent data is HTTP-mediated via the backend at `api.buildacademy.io`, which is opaque to this client.

### Local persistence (`SharedPreferences` via `LocalStorage` service)

Three keys, all device-local:

| Key | Type | Set by | Read by |
|-----|------|--------|---------|
| `token` | `String?` | After successful `/verify-otp/login` (`AuthService.verifyLoginOtp`) | Every authenticated service call via `LocalStorage.getToken()` |
| `theme_mode` | `String?` | `ThemeProvider` on toggle | `ThemeProvider` at startup |
| `onboardingDone` | `bool?` | First-run flow on completion | `SplashScreen` route logic |

### Client-side data models (closest analog to "schema")

These are read-only DTOs that mirror backend response shapes. Relationships are **denormalized** (no foreign-key pattern) — when a model references another entity, it embeds the entity's data as fields/nested dicts rather than holding an ID.

| Model | File | Backend source | Key fields |
|-------|------|----------------|------------|
| `TradeModel` | `lib/data/model/trade_model.dart` | `GET /trade/list`, `/trade/explore` | uuid, categoryName, description, minTradeAmount, image, endDate |
| `TradeDetailModel` | `trade_detail_model.dart` | `GET /trade/view/{uuid}` | uuid, title, description, categoryName, currentPricePerShare |
| `ProfileModel` | `profile_model.dart` | `GET /profile`, `/verify-otp/login` | firstName, lastName, avatar, phone, gender, country, currency, language, email |
| `CountryModel` | `country_model.dart` | `GET /countries` | id, name, phoneCode, flag, currency |
| `CategoryModel` | `category_model.dart` | `GET /trade/categories-list` | uuid, name |
| `PositionModel` | `position_model.dart` | `GET /positions`, `/positions/{uuid}` | shares, avgCostGhs, currentPrice, costBasisGhs, marketValueGhs, unrealisedPnlGhs, realizedPnlGhs, maxPayoutGhs; embeds `market{}` and `outcome{}` nested dicts |
| `MarketPositionsModel` | `position_model.dart` | `GET /positions/{market_uuid}` | marketUuid, description, sides[] (List of PositionModel) |
| `QuoteModel` | `quote_model.dart` | `POST /trade/{uuid}/quote` | outcomeSlug, costGhs, shares, avgPricePerShare, newPriceAfterFill, maxPayoutGhs, potentialProfitGhs, feeGhs |
| `OrderModel` | `order_model.dart` | `POST /trade/{uuid}/buy` (`data.order`) | shares, avgFillPrice, totalCostGhs, feeGhs |
| `BuyResponse` | `buy_response.dart` | `POST /trade/{uuid}/buy` (envelope) | success, message, code, `OrderModel?`, `QuoteModel?`, walletBalance |
| `ChartData` | `graph_model.dart` | `GET /chart` (defined, never called) | x (time), y (value) |
| `DefaultSettingsModel` | `default_settings_model.dart` | `GET /userDefaultSettings/index` | defaultAmount |
| `ProfileNotificationPreferencesModel` | `profile_notification_preferences_model.dart` | `POST /profile/preferences` | (unused in UI) |

**Relationships (containment, not references):**

- `TradeModel.categoryName` is a denormalized **string**, not a reference to `CategoryModel`.
- `PositionModel` embeds `market { uuid, description, image, category_name, closing_date_time, status }` and `outcome { slug, label, is_winner }` as nested dicts.
- `BuyResponse` contains nested `OrderModel?` and `QuoteModel?` plus a scalar `walletBalance` — one transactional response.

> The backend's actual schema (PostgreSQL / MySQL tables, FK constraints, LMSR pricing tables, wallet ledger, etc.) is **not visible** from this repository.

---

## 5. API Surface

All calls route through `ApiEndpoints` static builders and (primarily) `DioClient.instance`. Base URL: `https://api.buildacademy.io/projects/betrade/public/api`.

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
| POST | `/kyc/submit` *(multipart)* | Called directly from `lib/presentation/screens/verification/verify_account.dart` |
| POST | `/profile/preferences` | Same screen |

### Settings & Misc (6)

| Method | Path | Consumer |
|--------|------|----------|
| POST | `/fcm/save-token` | `AuthService.saveFcmToken()` |
| GET | `/countries` | `CountryProvider` |
| GET | `/languages` | Defined in `ApiEndpoints.languages` — no consumer |
| GET | `/notificationPreferences` | Defined — no consumer |
| GET | `/userDefaultSettings/index` | `DefaultAmountProvider` |
| POST | `/userDefaultSettings/update` | `DefaultAmountProvider` |

**Total: ~30 endpoints; ~3 defined but never called.**

---

## 6. Authentication & Authorization

### Mechanism

- **OTP via phone** — stateless bearer tokens issued by the backend.
- No OAuth, no social login, no biometric, no MFA beyond OTP.
- The login screen contains UI stubs for social-login buttons but they are **not wired to any provider** (confirmed in `docs/ACCESS.md`).

### Token lifecycle

| Stage | Where |
|-------|-------|
| **Issue** | `AuthService.verifyLoginOtp()` and `AuthService.verifyOtp()` (registration) receive a token in the response. |
| **Persist** | `LocalStorage.setToken(token)` writes to `SharedPreferences` under key `token` (plaintext). |
| **Inject** | `DioClient.setToken(token)` mutates the shared `Authorization: Bearer <token>` header on the Dio singleton. Each service call also reads `LocalStorage.getToken()` defensively. |
| **Validate** | `MainScreen` runs `Timer.periodic(Duration(seconds: 300), …)` (`lib/presentation/screens/main_screen.dart:58`) which calls `AuthService.verifyToken()` every 5 minutes. On failure, a glassmorphic "Session Expired" dialog is shown and the user is bounced to login. |
| **Refresh** | None. Tokens are not refreshed — once they expire backend-side, the user re-authenticates via OTP. |
| **Revoke** | `AuthService.logout()` POSTs to `/logout` then `LocalStorage.removeToken()` + `DioClient.removeToken()`. |

> The audit's "every 10s" claim for token polling is stale — the actual interval in `main_screen.dart:58` is **300 seconds (5 minutes)**. Some `CLAUDE.md` subdir docs still say 10s.

### Authorization (per-route)

Authorization is enforced **server-side** by the backend. From the client's perspective:

- All endpoints except `/register`, `/verify-otp/register`, `/login`, `/verify-otp/login`, and `/countries` are called with the bearer header.
- KYC-gated actions (`/trade/{uuid}/buy`, wallet deposit/withdraw) return typed error codes like `KYC_REQUIRED`, `INSUFFICIENT_FUNDS`, `MARKET_CLOSED` via `BuyResponse.code` — surfaced in UI as targeted error messages.
- No role-based UI gating; there is one user role.

### FCM token registration

Separate from auth tokens. `NotificationService.init()` fetches the FCM device token and POSTs it to `/fcm/save-token` along with the bearer token, so the backend can address pushes to this device.

---

## 7. Background Jobs / Queues

### Server-side

**Not visible from this repo.** Any queue workers, scheduled jobs, settlement engines, etc. live in the external backend at `api.buildacademy.io` and are out of scope.

### Client-side async work

There are **no Dart isolates, no `WorkManager`, no `BGTaskScheduler`, no `flutter_background_service`**. All async work runs on the main isolate. The only persistent background-style work is:

| Pattern | File | Purpose | Cadence |
|---------|------|---------|---------|
| `Timer.periodic` | `lib/presentation/screens/main_screen.dart:58` | Token-validity polling (`/verify-token`) | 300s |
| `Timer.periodic` | `lib/presentation/screens/signin/otp_screen.dart:50` | OTP resend countdown | 1s |
| `Timer.periodic` | `lib/presentation/screens/splash/signup_steps_pages/OTP_step.dart:67` | OTP resend countdown (signup variant) | 1s |
| `Timer.periodic` | `lib/presentation/screens/profile/info_chart_screen.dart:59` | **Simulated** live chart price ticks — random walk, not a real stream | 700ms |
| `Timer.periodic` | `lib/core/animations/success_animation.dart:244` | Post-signup particle animation tick | 16ms |
| `Timer(...)` (one-shot) | `lib/presentation/screens/trade/trade_page.dart:167` | Debounce — fires `getQuote` after typing settles | 200ms |
| `Timer(...)` (one-shot) | `lib/presentation/screens/explore/explore_page.dart:130` | Debounce — search input | configurable |
| `Timer(...)` (one-shot) | `lib/presentation/widget/custom_camera.dart:179` | Camera autofocus delay | 500ms |

### FCM background handler

`_firebaseBackgroundHandler` is registered via `FirebaseMessaging.onBackgroundMessage(...)` in `lib/main.dart`. This top-level function runs in a separate isolate when an FCM message arrives while the app is terminated. It is the only true OS-level background processing in this client.

---

## 8. Third-Party Integrations

| Service | Module(s) | Used by | Credentials needed | Where credentials live |
|---------|-----------|---------|---------------------|------------------------|
| **Backend REST API** (proprietary, Laravel) | All `lib/data/services/*` | All authenticated flows | None client-side; users authenticate via OTP. Base URL is the only config. | `.env` → `BASE_URL` |
| **Firebase Cloud Messaging (FCM)** | `firebase_core ^3.6.0`, `firebase_messaging ^15.0.0` | `lib/data/services/notification_services.dart`, `lib/main.dart` (background handler) | Firebase project config (API key, project ID, sender ID, app ID) per platform | `lib/firebase_options.dart` (auto-gen), `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` — **all committed to git** |
| **Flutter local notifications** | `flutter_local_notifications ^17.0.0` | `lib/data/services/notification_services.dart` | None | n/a |
| **Camera + image stack** | `camera ^0.12.0+1`, `image_picker ^1.0.7`, `flutter_image_compress ^2.4.0`, `path_provider ^2.1.5` | `lib/presentation/screens/camera/*`, KYC flow, profile avatar upload | None client-side; OS permissions at runtime via `permission_handler ^12.0.1` | iOS `Info.plist` keys (Camera, Microphone, Photo Library, Documents Folder); Android `AndroidManifest.xml` permissions |
| **Charts** | `fl_chart ^1.2.0` | `lib/presentation/screens/profile/info_chart_screen.dart`, `lib/presentation/screens/trade/trade_details_page.dart` | None | n/a |
| **OTP input UI** | `pinput ^5.0.0` | OTP screens (signin + signup) | None | n/a |
| **Icon sets** | `iconsax ^0.0.8`, `lucide_icons ^0.257.0`, `cupertino_icons ^1.0.8` | UI-wide | None | n/a |

### NOT integrated (confirmed by audit)

- **No payment gateways** — Razorpay / Stripe / PayPal / in-app purchases. Wallet deposit/withdraw is fully backend-driven; no client-side payment SDK.
- **No analytics** — Mixpanel / Amplitude / Segment / Firebase Analytics.
- **No crash reporting** — Crashlytics / Sentry.
- **No external trading data APIs** — Zerodha Kite / Upstox / Alpha Vantage / Finnhub / Polygon / Binance / CoinGecko / TradingView / Yahoo Finance. Prices come from the proprietary backend only.
- **No social auth** — Google Sign-In / Apple Sign-In / Facebook (login screen has UI stubs only).
- **No maps, no SMS provider, no email provider, no CDN, no KYC vendor** integrated client-side.

---

## 9. Deployment Architecture

### What ships

This is a mobile app — "deployment" means producing signed binaries:

- **Android:** APK (`flutter build apk`) or AAB (`flutter build appbundle`) → uploaded to Google Play Console.
- **iOS:** Archive (`flutter build ios` / `flutter build ipa`) → uploaded to App Store Connect → TestFlight → AppStore.

### Where it runs

| Tier | Hosting |
|------|---------|
| **Mobile client** | End-user devices (Android 5.0+ via `minSdk 21`; iOS 13.0+ via Podfile) |
| **Backend API** | External infra at `api.buildacademy.io` — **not in this repo and not visible from here** |
| **FCM** | Google Firebase managed service |

### Build / CI status

- `.github/workflows/` — **none on `main`.**
- `codemagic.yaml` — **none on `main`.** Two feature branches contain prototypes:
  - `feature/codemagic-testflight`
  - `feature/testflight-prep`
  Both are **unmerged**.
- `fastlane/`, `bitrise.yml` — none.
- **All current builds are manual / local.** Every release upload should be logged in [`docs/DEPLOY_LOG.md`](./DEPLOY_LOG.md).

### Signing

| Platform | Status |
|----------|--------|
| Android | ⚠ Release builds currently use the **debug** keystore (`android/app/build.gradle.kts:30`). No `key.properties` file. Must be replaced before Play Store. |
| iOS | ⚠ No `DEVELOPMENT_TEAM` or `PROVISIONING_PROFILE` configured. Must be set (Xcode Automatic per-dev, or manual provisioning in CI). |

### Firebase deploy

`firebase.json` configures Android (`betrade-new`) and iOS (`betrade-new`) for credential generation only. **No** Firestore deploy, **no** Cloud Functions deploy, **no** Hosting deploy is configured.

---

## 10. Key Environment Variables

### Runtime config (`.env`)

| Variable | Purpose | Required | Used by | Default |
|----------|---------|----------|---------|---------|
| `BASE_URL` | Backend REST API root | **Yes** | `EnvConfig.baseUrl` → `ApiEndpoints` → `DioClient` | `https://api.buildacademy.io/projects/betrade/public/api` |

- File: `.env` at repo root.
- ⚠ **Currently committed to git**; also bundled as a Flutter asset (declared in `pubspec.yaml`).
- Loader: `await dotenv.load(fileName: ".env")` in `lib/main.dart` before `runApp`.
- Validation: `EnvConfig.baseUrl` throws if the key is empty or missing.

### Firebase credentials (not env vars, but required)

| File | Platform | Used at |
|------|----------|---------|
| `lib/firebase_options.dart` | All (auto-gen by FlutterFire CLI) | Runtime — `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` |
| `android/app/google-services.json` | Android | Build time (Gradle plugin) |
| `ios/Runner/GoogleService-Info.plist` | iOS | Build time (Xcode) |

⚠ All three files are committed to git and contain API keys (project `betrade-new` for mobile, `betrade-4efd1` for web/desktop targets). Firebase API keys are technically public identifiers but rely on Firebase Security Rules being properly configured server-side.

### What is NOT present

- No staging/dev/prod env split.
- No payment-gateway keys, no analytics keys, no crash-reporting DSN, no third-party API keys.
- No `.env.example` (one is mentioned in `ACCESS.md` but does not exist in the repo).

---

## 11. Real-Time / Event Flows

### Push notifications (the only true real-time channel)

| Direction | Mechanism | Implementation |
|-----------|-----------|----------------|
| **Backend → Device** | Firebase Cloud Messaging (FCM) | Backend uses the per-device FCM token (POSTed to `/fcm/save-token`) to send pushes via Firebase. |
| **Foreground delivery** | `FirebaseMessaging.onMessage.listen(...)` in `lib/data/services/notification_services.dart` | Converts each message into a local notification via `flutter_local_notifications`. |
| **Background delivery** | `_firebaseBackgroundHandler` (top-level function) registered via `FirebaseMessaging.onBackgroundMessage(...)` in `lib/main.dart` | Runs in a dedicated isolate when the app is terminated; displays the system notification. |
| **Token refresh** | `FirebaseMessaging.onTokenRefresh.listen(...)` in `notification_services.dart` | Re-registers the new token with the backend. |

### What is NOT used (despite being available)

- **No WebSocket** — no `web_socket_channel`, no `socket.io` client.
- **No Server-Sent Events** — no `EventSource` / SSE client.
- **No Firestore real-time listeners** — Firestore is configured in `firebase_options.dart` but never read or written.
- **No Firebase Realtime Database listeners** — same.
- **No GraphQL subscriptions.**

### "Live" chart price is simulated

`lib/presentation/screens/profile/info_chart_screen.dart:59` runs a `Timer.periodic(700ms)` that mutates the displayed price with a random walk — purely client-side cosmetic motion, **not** a real backend stream. The user sees the price moving; no data leaves the device.

---

## 12. Server Access

### Status

> **There is no Betrade-owned server in this repository today.** This is a client-only Flutter app. The deployable artefacts are mobile binaries (APK/AAB/IPA), not server images. The backend at `api.buildacademy.io` is operated outside this repo and outside this team's direct infra.

This section documents the **prepared but unprovisioned** server-access scaffolding in case the team adds a build server, deployment server, or backend host. See [`docs/ACCESS.md`](./ACCESS.md) and [`docs/SSH_CONFIG.md`](./SSH_CONFIG.md) for the canonical sources.

### Documented (placeholder) server entry

From `docs/ACCESS.md`:

| Server | Host/IP | SSH User | Purpose | Who Can Access |
|--------|---------|----------|---------|----------------|
| `betrade-server` | `[FILL IN — none provisioned yet]` | `claude-server` | TBD | TBD |

### Planned SSH config (from `docs/SSH_CONFIG.md`)

```
Host betrade-server
    HostName [FILL IN server IP]
    User claude-server
    IdentityFile ~/.ssh/claude-server
```

### Planned server-user setup (from `docs/SSH_CONFIG.md`)

```bash
# Run once as root on the (eventual) server
adduser claude-server --disabled-password
usermod -aG docker claude-server
usermod -aG www-data claude-server
```

### Planned key generation (per developer)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/claude-server -C "claude-code-access"
ssh-copy-id -i ~/.ssh/claude-server.pub claude-server@[server-ip]
ssh betrade-server "echo connected"
```

### Documented security rules (from `docs/SSH_CONFIG.md`)

- Each developer uses their **own** SSH key — keys are never shared.
- `claude-server` is a dedicated unprivileged user — **no sudo, no root**.
- Rotate keys immediately if suspected compromised.
- Revoke keys (`~claude-server/.ssh/authorized_keys`) when a team member leaves.
- Server firewall: SSH allowed only from known IPs / VPN.

### Effect on Claude Code slash commands

The slash commands `/deploy`, `/test-live`, `/monitor`, `/logs`, `/db` are wired up but will fail their SSH pre-check until `betrade-server` is provisioned and the host entry is filled in. Failure messages point operators at `docs/SSH_CONFIG.md`.

### Database access

Per `docs/ACCESS.md`: **none**. The app does not connect to a database directly. The backend at `api.buildacademy.io` owns its own DB; access to it is **not granted via this repo**.

### Repo / API ownership (per `docs/ACCESS.md`)

- **GitHub repo:** access via tech lead — `[FILL IN]`.
- **Backend API operational owner:** `[FILL IN backend team / contact]`.
- **DevOps / Server owner:** `[FILL IN]` (none yet, since no server exists).

---

**End of architecture document.** All twelve sections describe only state observed in the repo at `D:\claude\betrade` on 2026-05-23. Any item marked `[FILL IN]` is a placeholder copied from existing project docs and indicates information not yet recorded in this repo.
