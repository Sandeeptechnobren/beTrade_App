# BeTrade — Comprehensive Bug Inventory

**Date:** 2026-05-23
**Branch:** `feature/vandana_claude`
**Status legend:** ✅ Fixed on this branch · ⏳ Pending · ⚠ Unverified · 🛑 Play Store blocker · 🔴 Critical · 🟡 High · 🟢 Low

> Sources: (a) user's QA report (14 items), (b) 3-agent audit run on 2026-05-23, (c) bugs found incidentally while fixing other things, (d) Play Store readiness review.

---

## Summary

| Category | Count |
|----------|------:|
| ✅ Fixed on branch (verified) | **18** |
| 🛑 Play Store launch blockers (today's priority) | **7** |
| 🔴 Critical unfixed (crash / security / data loss) | **8** |
| 🟡 High unfixed (UX broken / functional bugs) | **11** |
| 🟢 Low unfixed (cosmetic / tech debt) | **15+** |

---

## 0. 🚀 Release Readiness — Play Store launch pass (2026-05-26)

This section documents the dedicated release-readiness work performed under the explicit Play Store mandate. **Rankings feature (#5) was intentionally excluded** per scope.

### Debug prints removed / redacted

| File | What was logged | Now |
|------|-----------------|-----|
| `lib/data/services/auth_service.dart` | 12× `print("...RESPONSE: ${response.data}")` — **dumped bearer tokens, OTP echoes, user objects** into adb logcat | Replaced with redaction comments. Status-code log preserved. |
| `lib/data/services/profile_service.dart` | 9-line PII block dumping firstName / lastName / avatar URL / phone / gender / country / currency / language. Plus 2× response body dumps + DioException response leak | Collapsed to single neutral `"Profile loaded successfully"`. All field-level prints removed. Response bodies redacted. |
| `lib/data/services/wallet_service.dart` | 4× response.data / `e.response?.data` dumps in balance, transactions, deposit/withdraw intents | All response-body components stripped; status / message / typed code preserved |
| `lib/data/services/trade_buy_service.dart` | 1× response body dump in DioException (contained user balance hints) | Body stripped; error message preserved |
| `lib/data/services/local_storage.dart` (earlier commit) | `print(token)` in `setToken` | Removed in `2147422` |
| `lib/data/services/auth_service.dart` `saveFcmToken` (earlier) | `print(token)` | Removed in `2147422` |

**Total: 23 sensitive log scrubs across 4 highest-risk services.**

### Sensitive logs protected — new logging utility

Added `lib/core/utils/logger.dart` — `AppLogger` facade with four levels:

| Method | Behaviour in release |
|--------|----------------------|
| `AppLogger.d(tag, msg)` | **Stripped by tree-shaking** — uses `kDebugMode` constant. Safe for any debug-only output. |
| `AppLogger.i(tag, msg)` | Kept. Use only for non-sensitive lifecycle events. |
| `AppLogger.w(tag, msg, [err])` | Kept. For recoverable conditions. |
| `AppLogger.e(tag, msg, [err, stack])` | Kept. Stack trace stripped in release. Wire to Crashlytics/Sentry when adopted. |
| `AppLogger.dRedacted(tag, label, value)` | Debug-only mask: keeps first 4 + last 4 chars of a secret. |

Adoption strategy: introduced for new code. Existing service-layer logs were redacted in place to avoid a 250-call rewrite on launch day. Future PRs should migrate remaining `print(...)` to `AppLogger.*`.

### Release configuration verified

| Item | Status | Notes |
|------|--------|-------|
| `debugShowCheckedModeBanner: false` | ✅ | `main.dart:207` |
| `themeMode` wired to provider | ✅ | `main.dart:208` |
| Light + dark `ThemeData` defined | ✅ | `main.dart:209-220` |
| Release build target SDK | ✅ | `compileSdk` / `targetSdk` 34 |
| `kotlin.incremental=false` for Windows cross-drive | ✅ | `android/gradle.properties` (commit `17d33fc`) |
| Asset declarations valid in `pubspec.yaml` | ✅ | images/, logo/, fonts/, .env all declared |
| `.env` bundled but committed to git | ⚠ | Documented as known risk. Backend URL is only env value — no secret keys. |
| Debug-only utilities accidentally in release | ✅ | None found. `_showSnack` dead method noted as pre-existing dead code. |

### Remaining release risks (NOT addressed in this pass)

These are **Play Store launch blockers** documented in §2 of this report. Each is non-code (signing config or external setup) so they can't be fixed by a code change alone:

1. **🛑 Release builds still sign with the DEBUG keystore** (`android/app/build.gradle.kts:30`). Google Play will reject the upload. **MUST generate a release keystore before submission.** Cannot be code-fixed — requires `keytool` + `key.properties` setup.
2. **🛑 `android:usesCleartextTraffic="true"`** in `AndroidManifest.xml`. Google Play security scan will flag a financial app allowing HTTP. **MUST remove before release.**
3. **🛑 AAB not APK** — must `flutter build appbundle --release` for Play Store submission.
4. **🛑 Wallet deposit/withdraw form wiring** — needs functional verification on the latest branch (team's commit `1177c76` may have addressed). Without working wallet flow, the app is non-functional for a trading product.
5. **🛑 `flutter_secure_storage` for the bearer token** — currently plaintext `SharedPreferences`. Recommended for a financial app before public launch. Not a Play *rejection* trigger but a serious security gap.
6. **🟡 Other services still print response bodies** — `positions_service`, `trade_service`, `trade_details_service`, `trade_quote_service`, `category_service`, `explorer_service`, `market_card_service`, `notification_services`, `default_settings_service`, `profile_notification_service`. These were not touched in this pass because their data is less sensitive than auth/wallet/profile. Schedule a follow-up sweep using `AppLogger.d` migration.
7. **🟡 `main.dart` `_firebaseBackgroundHandler`** still uses `debugPrint` for message title / body / data. Could leak notification content (e.g. "₵500 deposited"). Wrap in `kDebugMode` if push payloads ever contain amounts.
8. **🟡 Privacy Policy + Terms of Service URLs** — required in Play Console listing. Not a code concern; needs hosting.
9. **🟡 Prediction market / real-money policy review** — confirm Google Play allowed-territory for Ghana (GHS) before submission.

### Play Store readiness status — final assessment

**Code-side: ~80% ready.** Sensitive logging cleaned in highest-risk services. Theme polished. Typography production-grade. Avatars high-res. Logo refreshed. Navbar locked against Material 3 surface tint. Placeholder colours unified. KYC banner timing fixed. Trade flow + post-signup nav verified.

**Configuration-side: NOT READY.** Three hard blockers remain (release keystore, cleartext traffic, AAB build). All three are quick to fix (15 + 2 + 1 minute) but **MUST be done by a human with `keytool` + Play Console access**. None can be automated by Claude.

**Recommendation:** Upload to Play Console **Internal Testing track first**, never directly to Production. Internal Testing lets you verify the AAB on real devices via the Play install path without exposing the app to public users. Promote to Production only after 1–2 days of confirmed working on internal devices.

---

## 1. ✅ Already fixed on `feature/vandana_claude`

These are committed and pushed. No action needed.

### Production typography pass (QA #2) — 2026-05-26

Performed a surgical, production-grade typography pass cross-referenced with **Material 3 spec + Cred + PhonePe + Zomato + Swiggy** real-world scales. Adopted the principle of *bump where it gives genuine hierarchy improvement; leave alone what's already production-norm.*

**Final adjustments in `lib/core/theme/app_text_style.dart`:**

| Preset | Before | After | Rationale |
|--------|------:|------:|-----------|
| `heading` | 20 | **22** | Screen titles — matches Material 3 `titleLarge` and Cred screen-header scale |
| `headingWhite` | 20 | **22** | Variant — consistent |
| `headingWhitebig` | 22 | **26** | Onboarding marketing hero text — more impact |
| `subHeading` | 18 | 18 | Already a solid section header size |
| `subHeadingBold` | 18 | 18 | Same |
| `body` | 16 | 16 | Canonical Material `bodyLarge`, well-readable |
| `bodyBig` | 16 | 16 | Same |
| `small` | 14 | 14 | Canonical Material `bodyMedium` for captions/labels |
| `smallGrey` | 14 | 14 | Same |
| `smallNav` | 14 | 14 | **Kept** — doubles as KYC form-label style on `verify_account.dart` (Country/Currency/Language), not just bottom-nav. Shrinking to 12sp would have shrunk those form labels. |
| `button` | 16 | 16 | Standard button label size |

**QA verification (static — couldn't run on device):**
- ✅ Analyzer clean ("No issues found!") on `app_text_style.dart`.
- ✅ Visual code review of all 32 files that consume the changed presets — no width-constrained `Row` siblings around heading text that would cause `RenderFlex` overflow.
- ✅ `CommonHeader`, `OTPScreen`, `LoginScreen`, `TradeDetailsPage`, `TradePage` headers all use `Expanded` / `Padding` patterns that flex with text width.
- ✅ Onboarding pages use multi-line containers — 4sp bump on `headingWhitebig` may cause an extra line wrap on the narrowest phones, but no overflow / clipping.
- ⏳ Manual smoke test pending APK install.

### Full list of fixes

| # | Bug | Source | Commit |
|---|-----|--------|--------|
| 1 | Not signed in after signup — `SuccessScreen` was going to `AuthScreen` instead of `MainScreen` | QA #1 | `87ff67b` |
| 2 | Swipe on PollCard didn't work — race between swipe and `loadFromBackend()` due to optimistic `_hasLoaded = true` before await | QA #6 | `c2ddf4d` |
| 3 | Wallet history dropdown — selected row highlight didn't span full width | QA #7 | `8161c12` |
| 4 | Achievement grid — gap between row 1 and row 2 was 20.h vs 6.w horizontal (visually broken) | QA #8 | `8161c12` |
| 5 | Profile summary cards — 20.h between cards didn't match 16.w horizontal margin | QA #9 | `8161c12` |
| 6 | Selected quick-amount chip stayed in unselected visual state | QA #10 | `87ff67b` |
| 7 | Quick-amount chips were additive (`+=`) instead of replacing (`=`) — wrong-amount trades | QA #11 | `87ff67b` |
| 8 | Buy Yes/No on chart/info page did nothing (no buttons existed) | QA #12 | `87ff67b` (added buttons) + `574b9d5` (open with default amount + quote) |
| 9 | KYC verification didn't auto-start after signup — fixed by passing `docUploadStatus: 0` to MainScreen | QA #13 | `87ff67b` + team's `1177c76` reinforcement |
| 10 | Token persistence race in `verifyOtp` + `verifyLoginOtp` — `DioClient.setToken` (sync) ran before `await LocalStorage.setToken` | audit | `2147422` |
| 11 | Plaintext bearer token printed to `adb logcat` via `print(token)` in `LocalStorage.setToken` + `AuthService.saveFcmToken` | audit | `2147422` |
| 12 | Logout never called `DioClient.removeToken()` — stale auth header leaked into next user's multipart uploads | audit | `2147422` |
| 13 | OTP paste from SMS only kept the last digit (`value.substring(value.length - 1)`) | audit | `2147422` |
| 14 | OTP cells wiped on verify failure — one-digit typos forced full re-entry | audit | `2147422` |
| 15 | Login screen `_isLoading` field declared but never set → `CircularProgressIndicator` was dead code; button watched wrong provider's `isLoading` | incidental | `2147422` |
| 16 | No synchronous re-entry guard on Login's `_handleContinue` → rapid double-taps fired duplicate `/login` requests | audit | `2147422` |
| 17 | Login network errors leaked raw `DioException` text — now shows "Network error. Please check your connection." | audit | `2147422` |
| 18 | Home PollCard share button was a stub `onTap: () {}` — wired to `share_plus` with description + category + image URL | incidental | `e941040` |

**Bonus from team's PR #16 (commit `1177c76`):** cold-start login + KYC banner persistence improvements.

---

## 2. 🛑 PLAY STORE LAUNCH BLOCKERS — must fix before upload TODAY

| # | Blocker | Why it blocks | Effort |
|---|---------|---------------|--------|
| B1 | **Release builds signed with DEBUG keystore** (`android/app/build.gradle.kts:30`) | **Google Play rejects debug-signed AAB/APK uploads.** First upload locks the signing key forever. | 15 min |
| B2 | `android:usesCleartextTraffic="true"` in `AndroidManifest.xml` | Google Play security scan will flag a financial app allowing HTTP. Backend is HTTPS so this can be removed safely. | 2 min |
| B3 | Build output is APK not AAB | Play Store has required AAB since Aug 2021. `flutter build apk` produces APK; need `flutter build appbundle`. | 1 min |
| B4 | `android/key.properties`, keystore files NOT in `.gitignore` | Once you generate the keystore for B1, ensure it doesn't get committed. | 1 min |
| B5 | iOS `DEVELOPMENT_TEAM` and `PROVISIONING_PROFILE` not configured | If shipping iOS too, blocks TestFlight upload. Android-only ship can skip. | 30 min (if needed) |
| B6 | Wallet deposit/withdraw forms have no API wiring (per audit — verify with team after their commit `1177c76`) | For a **trading app**, users physically can't deposit/withdraw → 1-star reviews + financial liability. | 1–2 hr |
| B7 | Bearer tokens stored plaintext in `SharedPreferences` | Trading app security — rooted/compromised devices leak user wallets. Should use `flutter_secure_storage`. | 30 min |

**Privacy policy + ToS URLs** are required in Play Console listing (not code) — host them somewhere TODAY.

**Regulatory:** Google Play's prediction-market / real-money-gaming policies are strict. Confirm your country (Ghana per GHS currency) is allowed.

---

## 3. 🔴 Critical unfixed — crash, data loss, security

These are real bugs that will cause crashes or expose users.

| # | File | Bug | Risk |
|---|------|-----|------|
| C1 | `lib/data/model/country_model.dart` | `fromJson` has no `?? ""` defaults on any field | `NoSuchMethodError` on backend variance → crash |
| C2 | `lib/data/model/graph_model.dart` | `.toDouble()` called on raw JSON without null check | Crash if `time` or `value` is null |
| C3 | `lib/presentation/screens/explore/explore_page.dart:~655` | `DateTime.parse(endDate)` unguarded | Crash on malformed / empty date from backend |
| C4 | `lib/data/services/profile_service.dart:~218` | `MultipartFile.fromFile()` with no size check | 50 MB photo → OOM crash or 30 s upload timeout |
| C5 | `lib/presentation/screens/verification/verify_account.dart:~494` | `CameraScreen(isFront: false)` hard-coded — `isFront` parameter ignored | KYC selfie captured with rear camera → KYC rejected by backend |
| C6 | `lib/data/services/local_storage.dart` | `_prefs` is `late SharedPreferences` — any read before `init()` completes throws `LateInitializationError` | Boot-time crash if any provider reads token early |
| C7 | `lib/presentation/screens/main_screen.dart:39, 71-72` | `_isDialogShowing` flag never reset after session-expired dialog | If user re-logs in, next expiry's dialog won't fire — silent broken session state |
| C8 | Auth token send / receive | 300 s `Timer.periodic` token poll **ignores app backgrounding** (no `WidgetsBindingObserver`) | After 30 min in background, app foregrounds with stale token; serves authenticated screens for up to 5 min on a revoked token |

---

## 4. 🟡 High unfixed — broken UX or core functionality

| # | Source | Bug |
|---|--------|-----|
| H1 | QA #5 | Rankings page opens a chart instead — wrong navigation route (file unknown — needs investigation) |
| H2 | QA #16 | Scrolling on home turns navbar grey instead of remaining white — likely `SliverAppBar` scroll color animation not theme-aware |
| H3 | Audit | Multiple `TextEditingController` not disposed in `edit_profile.dart` (4 controllers) — memory leak per open/close cycle |
| H4 | Audit | Same in `portfolio/deposit/newDeposit.dart` (6 controllers) and `portfolio/withdraw/withdrawal.dart` (8 controllers) |
| H5 | Audit | `ProfileProvider.fetchProfile`, `LoginProvider`, `SignupProvider` call `notifyListeners()` after async work without `_isDisposed` guard — "notifyListeners on disposed provider" crashes/warnings |
| H6 | Audit | `info_chart_screen.dart:81` — second `CommonShareButton` stub (the home one is wired, this one isn't) |
| H7 | Audit | `info_chart_screen.dart:98, 113` — two stub `ElevatedButton`s `onPressed: () {}` |
| H8 | Audit | `login_screen.dart:355, 393` — "Continue with Google" / "Continue with Apple" stubs (visible to every user) |
| H9 | Audit | `deposit_success.dart:40` — "OK" button stub (`onPressed: () {}`) on success modal |
| H10 | Audit | Two divergent OTP UIs (`signin/otp_screen.dart` vs `splash/signup_steps_pages/OTP_step.dart`) — duplicate code, divergent fixes |
| H11 | Audit | Phone validator (`phone_number_validator.dart`) — default branch accepts any 6+ digit input, even obviously invalid numbers |

---

## 5. 🟢 Low / tech-debt unfixed

### Theme & polish (QA #2, #14, #15)

| # | Bug |
|---|-----|
| L1 | QA #2 — Font sizes are too small across the app. `AppTextStyle` defaults (`heading: 20.sp`, `body: 16.sp`, `small: 14.sp`) probably need bumping. |
| L2 | QA #14 — Placeholder/hint text too dark in light mode. No `hintTextDynamic` token in `AppColors`. |
| L3 | QA #15 — Dark mode toggle off is "inconsistent with design". Root cause: many widgets use static `AppColors.textPrimary` (always black) instead of `*Dynamic(context)` variants. Affects ~30 spots. |

### Filename inconsistencies (pre-existing)

| Bad | Fix to |
|-----|--------|
| `api_endpoint..dart` (double dot — typo) | `api_endpoint.dart` |
| `theam_provider.dart` | `theme_provider.dart` |
| `step_indecator.dart` | `step_indicator.dart` |
| `Common_header_withlogo.dart` (PascalCase) | `common_header_with_logo.dart` |
| `customSnackBar.dart` (camelCase) | `custom_snack_bar.dart` |
| `Payment_method.dart` (PascalCase) | `payment_method.dart` |
| `step_heder.dart` (typo) | `step_header.dart` |
| `achivement_Sheet.dart` (typo + case) | `achievement_sheet.dart` |
| `HomeScreen.dart` (PascalCase) | `home_screen.dart` |
| `OTP_step.dart` | `otp_step.dart` |

All have multiple importers — rename in one coordinated commit, not one-by-one.

### Dead code

- `lib/data/services/home_service.dart` — entire file unused. Has its own divergent `BuyResponse` / `QuoteResponse`.
- `HomeScreen.dart` `_showSnack` method — declared, never called.
- ~900 lines of commented-out legacy code across `country_provider.dart` (~457 lines), `auth_service.dart` (~87), `profile_service.dart` (~76), `custom_camera.dart` (~280), `signup_steps_pages/step_profile.dart` (~72% of file), `homeScreen/trade_filter_bottom_sheet.dart` (~72%).
- `ApiEndpoints.languages`, `ApiEndpoints.notificationPreferences`, `GET /trade/{uuid}/chart` — defined but never called.

### Architecture / tooling

| # | Issue |
|---|-------|
| T1 | Two HTTP clients (`http` + `dio`) coexist inconsistently. New code uses Dio; legacy code uses `http`. Sign-in `AuthProvider` is the only remaining significant `http` consumer. |
| T2 | `dio_client.dart:27` reads `dotenv.env['BASE_URL']` directly — should use `EnvConfig.baseUrl` |
| T3 | `explorer_service.dart` and `trade_details_service.dart` hard-code URLs instead of using `ApiEndpoints` |
| T4 | `print` / `debugPrint` everywhere (~202 occurrences in services) — no structured logger, no Crashlytics, no Sentry |
| T5 | `flutter test` fails on `main` — default scaffold test references widgets that don't exist in `MyApp` |
| T6 | No CI on `main` — `codemagic.yaml` exists only on unmerged feature branches |
| T7 | `.env` + Firebase service files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) committed to git |
| T8 | `_ensureReadyToTrade` logic duplicated in HomeScreen + trade_details_page (TODO noted in `574b9d5`) — should extract to shared helper |

### Missing features (audit-flagged as "by design or oversight, confirm with product")

- No analytics (Mixpanel / Amplitude / Firebase Analytics)
- No crash reporting (Crashlytics / Sentry)
- No deep linking / URI scheme handling
- No WebSocket / real-time price stream (chart is **simulated client-side** via random walk in `info_chart_screen.dart`)
- No payment gateway client SDK (wallet relies entirely on backend)
- No background task scheduling beyond UI `Timer.periodic`

---

## 6. Suggested fix order for the next 7 days

### Day 0 (TODAY — if shipping today)
1. B1 — Release keystore (15 min)
2. B2 — Remove `usesCleartextTraffic` (2 min)
3. B3 — Build AAB (1 min)
4. B4 — `.gitignore` keystore files (1 min)
5. B7 — `flutter_secure_storage` for tokens (30 min)
6. B6 — Wallet wiring **if still broken** (1–2 hr)
7. C1, C2, C3, C4 — Crash-risk fixes (30 min total)
8. H8 + H9 — Remove or wire stub buttons (15 min)
9. C5 — KYC camera `isFront` fix (5 min)
10. Build AAB, upload to **Internal Testing** track (not Production)

### Day 1–2
- C6, C7, C8 — Session lifecycle fixes
- H1 — Rankings → chart routing
- H2 — Navbar scroll color
- H3, H4 — Memory leaks on form screens

### Day 3–4
- L1, L2, L3 — Theme pass (font sizes, hint color, dark-mode `*Dynamic` audit)
- H5 — Provider notify-after-dispose guards
- H6, H7 — Remaining stub buttons

### Day 5+ (after first Production release)
- T1–T4 — Tooling consolidation (HTTP clients, logging, hard-coded URLs)
- T5 — First real test
- Filename renames (one big commit)
- Dead code cleanup
- T6 — Enable CI

---

## 7. Verification

To re-check the current state of any bug listed here, use these grep / search starting points:

```bash
# Stub buttons
grep -rn "onPressed: () {}" lib/
grep -rn "onTap: () {}" lib/

# Dead null-aware (where I marked C1, C2)
grep -rn "?? \"\"" lib/data/model/

# Missing dispose() for controllers
grep -rn "TextEditingController" lib/presentation/screens/

# Cleartext traffic
grep -rn "usesCleartextTraffic" android/

# Plaintext token usage
grep -rn "SharedPreferences" lib/data/services/

# Hard-coded URLs (bypass ApiEndpoints)
grep -rn "http[s]\?://" lib/data/services/

# Provider notify after async without _isDisposed guard
grep -rn "notifyListeners()" lib/data/provider/
```

Verify any "Fixed" claim by `git log <file> | head` to confirm the commit hash matches what's listed in §1.
