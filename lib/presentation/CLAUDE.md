# lib/presentation/

## Purpose
All UI code. Five sibling folders: `auth/` (auth landing), `bottom_navigation/` (custom bottom bar), `onboarding/` (first-run pager), `screens/` (feature screens), and `widget/` (14 reusable widgets). No HTTP calls or JSON parsing here — UI consumes providers and shared widgets.

## Key files / folders
- `auth/auth_screen.dart`, `auth_bottom_sheet.dart` — entry/login chooser.
- `bottom_navigation/bottom_nav.dart` — `CustomBottomNav` widget (used by `screens/main_screen.dart`).
- `onboarding/onboarding_screen.dart`, `onboarding_page.dart` — first-run pager.
- `screens/main_screen.dart` — `IndexedStack` host with the 10s `Timer.periodic` token-validity check (cancelled in `dispose`).
- `screens/splash/splash_screen.dart` — boot screen; routes to onboarding/auth/main based on `LocalStorage` flags.
- `screens/<feature>/` — splash, signin, verification (KYC), homeScreen, explore, trade, portfolio, profile, camera.
- `widget/` — see `widget/CLAUDE.md` for the 14 reusable widgets.

## Data flow
- Inbound: providers registered globally in `lib/main.dart` are consumed via `context.watch<T>()` (rebuild on changes), `Consumer<T>` (scoped rebuild), or `context.read<T>()` (one-off action). State changes from provider mutation propagate up to the watching widget tree.
- Outbound: imperative navigation via `Navigator.push` / `pushReplacement` / `pushAndRemoveUntil` wrapped around `MaterialPageRoute(builder: (_) => Screen())`. 135 such call sites across 28 files.

## Dependencies
- Outbound: `lib/data/provider/*`, `lib/data/model/*`, `lib/data/services/local_storage` (token + onboarding flag check), `lib/core/theme/*`, `lib/core/utils/validators/*`; packages `flutter_screenutil`, `provider`, `iconsax`, `fl_chart`, `camera`, `image_picker`, `permission_handler`.
- Inbound: `lib/main.dart` — `MaterialApp.home: SplashScreen()`. Everything else reachable only via `Navigator.push`.

## Conventions
- `StatelessWidget` when no internal state; `StatefulWidget` for screens with controllers, timers, focus, scroll.
- `const` constructors with `super.key` parameter.
- Sizing via `flutter_screenutil` extensions (`.h`, `.w`, `.r`, `.sp`) — avoid hard-coded pixels.
- Colours via `AppColors` / `AppColors.*Dynamic(context)`; text via `AppTextStyle` (see `lib/core/theme/`).
- Async work kicked off in `initState` via `SchedulerBinding.instance.addPostFrameCallback` or `WidgetsBinding.instance.addPostFrameCallback`.
- Always `dispose` controllers, timers, focus nodes; guard async continuations with `if (!mounted) return;` and (where used) a `bool _isDisposed` flag.
- Imperative `Navigator` only — no central route table, no `go_router`.
- Inconsistent file naming exists (`HomeScreen.dart`, `OTP_step.dart`, `Payment_method.dart`, `achivement_Sheet.dart`); new files should use `snake_case.dart`.

## Common commands
None module-specific.
