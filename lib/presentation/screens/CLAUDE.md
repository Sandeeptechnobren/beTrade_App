# lib/presentation/screens/

## Purpose
Feature screens, organised one folder per feature. Covers boot/onboarding (`splash/`), auth (`signin/`), KYC (`verification/`), the main app shell (`main_screen.dart`), plus feature areas `homeScreen/`, `explore/`, `trade/`, `portfolio/`, `profile/`, `camera/`. The shell uses `IndexedStack` to keep tab state across switches.

## Key files / folders
- `main_screen.dart` — `MainScreen` with `IndexedStack` of 5 tabs. Runs `Timer.periodic(Duration(seconds: 300))` for token-validity polling (line 58); shows glassmorphic "Session Expired" dialog on failure. **Note: earlier sub-docs said 10 s — actual is 300 s.**
- `splash/splash_screen.dart`, `splash/signup_screen.dart`, `splash/signup_steps_pages/` — boot + multi-step signup. **`signup_steps_pages/step_profile.dart` is ~72 % commented-out.**
- `signin/login_screen.dart`, `signin/otp_screen.dart`, `signin/country_picker_sheet.dart` — sign-in. Legacy `http` + hard-coded-URL pipeline via `AuthProvider`.
- `verification/verify_account.dart`, `verification/country_services_step_one.dart`, `verification/step_heder.dart` (sic) — KYC. `verify_account.dart` calls `/kyc/submit` and `/profile/preferences` directly via `http`, bypassing providers.
- `homeScreen/HomeScreen.dart`, `homeScreen/trade_filter_bottom_sheet.dart` — landing + filter sheet (filter sheet is ~72 % commented-out).
- `explore/explore_page.dart` — search list with debounced `ExploreProvider` calls.
- `trade/trade_page.dart`, `trade/trade_details_page.dart` — trade detail; live quote via `TradeDetailProvider`. **"Buy Yes" / "Buy No" buttons are stubs in `trade_page.dart`** (`onPressed: () {}`).
- `portfolio/portfolio_page.dart`, `portfolio/position_detail_page.dart`, `portfolio/deposit/newDeposit.dart`, `portfolio/withdraw/withdrawal.dart` — portfolio. **Deposit/withdraw forms lack API wiring.**
- `profile/profile_page.dart`, `profile/edit_profile.dart`, `profile/info_chart_screen.dart` (700 ms simulated chart), `profile/notification_page.dart`, `profile/Payment_method.dart`, `profile/achivement_Sheet.dart` (sic) — profile area.
- `camera/camera_screen.dart`, `camera/selfie_camera.dart`, `camera/preview_screen.dart`, `camera/selfie_preview_screen.dart` — KYC capture.

## Data flow
Each screen reads providers via `context.watch<T>()` / `Consumer<T>` in `build()`; triggers fetches in `initState` via `WidgetsBinding.instance.addPostFrameCallback`; navigates imperatively via `Navigator.push(MaterialPageRoute(builder: (_) => Screen()))`.

## Dependencies
- Outbound: `lib/data/provider/*`, `lib/data/model/*`; some screens call services directly (`verify_account.dart`, `trade_page.dart`); `lib/data/services/local_storage`; `lib/core/theme/*`; `lib/presentation/widget/*`; packages `camera`, `image_picker`, `permission_handler`, `path_provider`, `flutter_image_compress`, `pinput`, `fl_chart`.
- Inbound: `SplashScreen` is rendered from `lib/main.dart`; all other screens reached via `Navigator.push`.

## Conventions
- `StatefulWidget` when timers/controllers/scroll exist; `StatelessWidget` for static screens.
- Always cancel timers and dispose controllers in `dispose()`; check `mounted` after every `await`.
- Several files have large commented-out legacy versions (see `docs/CODEBASE_AUDIT.md` §11); ignore those and edit only the active class.
- File-naming inconsistencies (`HomeScreen.dart`, `OTP_step.dart`, `Payment_method.dart`, `Gender_step.dart`, `stepPhone.dart`, `newDeposit.dart`, `step_heder.dart`, `achivement_Sheet.dart`) are pre-existing — new files should use `snake_case.dart` with correct spelling.

## Common commands
None module-specific.
