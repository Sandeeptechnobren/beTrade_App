# lib/presentation/screens/

## Purpose
Feature screens, organised one folder per feature. Covers boot/onboarding (`splash/`), auth (`signin/`), KYC (`verification/`), the main app shell (`main_screen.dart`), and feature areas: `homeScreen/`, `explore/`, `trade/`, `portfolio/`, `profile/`, `camera/`. The shell uses `IndexedStack` to keep tab state across switches.

## Key files / folders
- `main_screen.dart` — `MainScreen` with `IndexedStack` of 5 tabs (Home, Explore, InfoChart, Portfolio, Profile). Runs `Timer.periodic(Duration(seconds: 10))` for token-validity polling; shows glassmorphic "Session Expired" dialog on failure.
- `splash/splash_screen.dart`, `signup_screen.dart`, `signup_steps_pages/` — boot screen + multi-step signup. **`signup_steps_pages/step_profile.dart` is 72% commented-out.**
- `signin/login_screen.dart`, `otp_screen.dart`, `country_picker_sheet.dart` — sign-in (legacy `http`+hard-coded-URL pipeline).
- `verification/verify_account.dart`, `country_services_step_one.dart`, `step_heder.dart` (sic) — KYC; `verify_account.dart` calls `/kyc/submit` and `/profile/preferences` directly via `http`.
- `homeScreen/HomeScreen.dart`, `trade_filter_bottom_sheet.dart` — landing screen + filter sheet (filter sheet is 72% commented-out).
- `explore/explore_page.dart` — explore list with debounced search via `ExploreProvider`.
- `trade/trade_page.dart` — trade detail; **"Buy Yes" / "Buy No" buttons are no-op stubs** (`onPressed: () {}`).
- `portfolio/portfolio_page.dart`, `deposit/`, `withdraw/`, `wallet_history.dart` — portfolio area; **deposit/withdraw forms have no API wiring**.
- `profile/profile_page.dart`, `edit_profile.dart`, `info_chart_screen.dart`, `notification_page.dart`, `Payment_method.dart`, `all_payment_methods.dart`, `new_Payment_method.dart`, `profile_Detail_Screen.dart`, `help_support_page.dart`, `achivement_Sheet.dart` (sic) — profile area.
- `camera/camera_screen.dart`, `selfie_camera.dart`, `preview_screen.dart`, `selfie_preview_screen.dart` — KYC capture.

## Data flow
Each screen reads providers via `context.watch<T>()` / `Consumer<T>` in `build()`; triggers fetches in `initState` via `SchedulerBinding.instance.addPostFrameCallback`; navigates imperatively via `Navigator.push(MaterialPageRoute(builder: (_) => Screen()))`.

## Dependencies
- Outbound: `lib/data/provider/*`, `lib/data/model/*`; some screens call services directly (`verify_account.dart`, `trade_page.dart`); `lib/data/services/local_storage`; `lib/core/theme/*`; `lib/presentation/widget/*`; packages `camera`, `image_picker`, `permission_handler`, `path_provider`, `flutter_image_compress`.
- Inbound: `SplashScreen` is rendered from `lib/main.dart`; all other screens reached via `Navigator.push`.

## Conventions
- `StatefulWidget` when timers/controllers/scroll exist; `StatelessWidget` for static screens.
- Always cancel timers and dispose controllers in `dispose()`; check `mounted` after `await`.
- Several files have very large commented-out legacy versions (see `docs/CODEBASE_AUDIT.md` §11); ignore those and edit only the active class.
- File naming inconsistencies present (`HomeScreen.dart`, `OTP_step.dart`, `Payment_method.dart`, `Gender_step.dart`, `stepPhone.dart`, `newDeposit.dart`, `step_heder.dart` (sic), `achivement_Sheet.dart` (sic)) — new files should use `snake_case.dart` with correct spelling.

## Common commands
None module-specific.
