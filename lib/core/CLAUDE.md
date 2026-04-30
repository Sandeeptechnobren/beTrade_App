# lib/core/

## Purpose
Cross-cutting infrastructure used across the app: environment config, the shared Dio HTTP client, theme tokens (colours + text styles), input validators, and standalone animations. No business logic — only utilities. Subfolders (`animations/`, `config/`, `network/`, `theme/`, `utils/`) each hold 1–2 files; this `CLAUDE.md` covers all of them.

## Key files
- `config/env_config.dart` — `EnvConfig.baseUrl` getter; throws if `BASE_URL` missing/empty in `.env`. Single sanctioned reader of dotenv.
- `config/api_endpoint..dart` — `ApiEndpoints` static class with 14 URL builders composed from `EnvConfig.baseUrl`. **Filename has a double-dot typo** that has propagated to 7 importers — preserve the typo when importing.
- `network/dio_client.dart` — `DioClient` singleton. `BaseOptions(baseUrl: dotenv.env['BASE_URL'])`, 15s timeouts; exposes `instance`, `multipartInstance` (30s, fresh Dio per upload, copies auth header), and `setToken`/`removeToken` mutating shared `Authorization` header.
- `theme/app_colors.dart` — `AppColors` with static colour constants and `*Dynamic(BuildContext)` helpers branching on `Theme.of(context).brightness`.
- `theme/app_text_style.dart` — `AppTextStyle` static `TextStyle` instances using `SFProRounded` + `flutter_screenutil` `.sp`. Includes `custom({size, weight, color})` factory and dark-mode `*Dynamic` variants.
- `utils/validators/phone_number_validator.dart` — `Validators.validatePhone(phone, {countryCode})` with per-country rules for `+91`, `+1`, `+44`, plus a default branch.
- `animations/success_animation.dart` — `SuccessScreen` particle/scale animation used after signup completes.

## Data flow
Pure utilities — no I/O initiated here. Consumed by `lib/data/services/*` (services use `ApiEndpoints` + `DioClient`) and `lib/presentation/*` (widgets/screens use `AppColors`, `AppTextStyle`, validators).

## Dependencies
- Outbound: `dio`, `flutter_dotenv`, `flutter_screenutil`, `flutter`.
- Inbound: `lib/data/services/`, `lib/data/provider/country_provider.dart` (Dio + endpoints); `lib/presentation/screens/*` and `lib/presentation/widget/*` (theme + validators).

## Conventions
- Static-method utilities only — no instances, no DI.
- All env reads should go via `EnvConfig.baseUrl`. **Variant note**: `dio_client.dart:27` reads `dotenv.env['BASE_URL']` directly (legacy); new code should use `EnvConfig.baseUrl` instead.
- Endpoint URL builders in `ApiEndpoints` are getters when static, functions when parameterised (e.g., `tradeList(int page)`).
- Lines 1–20 of `dio_client.dart` are a dead, fully-commented earlier `DioClient`; the live class starts at line 24 — ignore the legacy block.

## Common commands
None module-specific. Use the standard Flutter toolchain from the repo root.
