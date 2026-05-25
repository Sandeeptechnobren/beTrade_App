# lib/presentation/

## Purpose
All UI code. Five sibling folders: `auth/` (auth landing + bottom sheet), `bottom_navigation/` (custom bottom bar), `onboarding/` (first-run pager), `screens/` (~20 feature screens), `widget/` (14 reusable widgets). No HTTP calls or JSON parsing here — UI consumes providers and shared widgets.

## Key files / folders
- `auth/auth_screen.dart`, `auth/auth_bottom_sheet.dart` — entry/login chooser shown after onboarding.
- `bottom_navigation/bottom_nav.dart` — `CustomBottomNav` widget (used by `screens/main_screen.dart`).
- `onboarding/onboarding_screen.dart`, `onboarding/onboarding_page.dart` — first-run pager.
- `screens/main_screen.dart` — `IndexedStack` host of 5 tabs (Home, Explore, InfoChart, Portfolio, Profile). Runs `Timer.periodic(Duration(seconds: 300))` for token-validity polling (cancelled in `dispose`); shows glassmorphic "Session Expired" dialog on failure.
- `screens/splash/splash_screen.dart` — boot screen; routes to onboarding/auth/main based on `LocalStorage` flags.
- `screens/<feature>/` — splash, signin, verification (KYC), homeScreen, explore, trade, portfolio, profile, camera.
- `widget/` — 14 reusable widgets; see `widget/CLAUDE.md`.

## Data flow
- Inbound: providers registered globally in `lib/main.dart` are consumed via `context.watch<T>()` (rebuild on change), `Consumer<T>` (scoped rebuild), or `context.read<T>()` (one-off). Provider mutations propagate via `notifyListeners()`.
- Outbound: imperative navigation via `Navigator.push` / `pushReplacement` / `pushAndRemoveUntil` wrapped around `MaterialPageRoute(builder: (_) => Screen())`. ~135 call sites across ~28 files.

## Dependencies
- Outbound: `lib/data/provider/*`, `lib/data/model/*`, `lib/data/services/local_storage` (token + onboarding flag), `lib/core/theme/*`, `lib/core/utils/validators/*`; packages `flutter_screenutil`, `provider`, `iconsax`, `lucide_icons`, `pinput`, `fl_chart`, `camera`, `image_picker`, `permission_handler`.
- Inbound: `lib/main.dart` — `MaterialApp.home: SplashScreen()`. Everything else reached via `Navigator.push`.

## Conventions
- `StatelessWidget` when no internal state; `StatefulWidget` for screens with controllers, timers, focus, scroll.
- `const` constructors with `super.key`.
- Sizing via `flutter_screenutil` extensions (`.h`, `.w`, `.r`, `.sp`) — avoid hard-coded pixels.
- Colours via `AppColors` / `AppColors.*Dynamic(context)`; text via `AppTextStyle`.
- Async work kicked off in `initState` via `WidgetsBinding.instance.addPostFrameCallback`.
- Always `dispose` controllers, timers, focus nodes; guard async continuations with `if (!mounted) return;`.
- Imperative `Navigator` only — no central route table, no `go_router`.
- Pre-existing filename inconsistencies (`HomeScreen.dart`, `OTP_step.dart`, `Payment_method.dart`, `achivement_Sheet.dart`); new files should use `snake_case.dart`.

## Common commands
None module-specific.
