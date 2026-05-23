# lib/core/

## Purpose
Cross-cutting infrastructure used across the app: env config, the shared Dio HTTP client, theme tokens, input validators, and standalone animations. Five subfolders (`animations/`, `config/`, `network/`, `theme/`, `utils/`) totalling ~7 small files. Pure utilities only — no business logic, no state.

## Key files
- `config/env_config.dart` — `EnvConfig.baseUrl` getter; throws if `BASE_URL` is missing/empty in `.env`. The only sanctioned reader of `dotenv` in the codebase.
- `config/api_endpoint..dart` — `ApiEndpoints` static class with URL builders composed from `EnvConfig.baseUrl`. **Filename has a double-dot typo** propagated to 7 importers — preserve it.
- `network/dio_client.dart` — `DioClient` singleton (15 s timeouts) + `multipartInstance` (30 s, fresh Dio per upload, copies auth header). `setToken` / `removeToken` mutate the shared `Authorization` header. Lines 1–20 are dead commented code; live class starts at line 24. **`dio_client.dart:27` reads `dotenv.env['BASE_URL']` directly** (legacy — new code should use `EnvConfig`).
- `theme/app_colors.dart` — `AppColors` static palette + `*Dynamic(BuildContext)` helpers that branch on `Theme.of(context).brightness`.
- `theme/app_text_style.dart` — `AppTextStyle` `TextStyle` presets using `SFProRounded` + `flutter_screenutil` `.sp`. Includes `custom({size, weight, color})` factory and dark-mode variants.
- `utils/validators/phone_number_validator.dart` — `Validators.validatePhone(phone, {countryCode})` with rules for `+91`, `+1`, `+44`, plus a default branch.
- `animations/success_animation.dart` — `SuccessScreen` particle/scale animation used after signup completes (runs a 16 ms `Timer.periodic`).

## Data flow
No I/O originates here. Consumed by `lib/data/services/*` (URL building + HTTP transport via `ApiEndpoints` + `DioClient`) and `lib/presentation/*` (theme tokens + validators).

## Dependencies
- Outbound: `dio`, `flutter_dotenv`, `flutter_screenutil`, `flutter`.
- Inbound: `lib/data/services/*`, `lib/data/provider/country_provider.dart` (Dio + endpoints); `lib/presentation/screens/*` and `lib/presentation/widget/*` (theme + validators).

## Conventions
- Static-method utilities only — no instances, no DI.
- All env reads should go via `EnvConfig.baseUrl`. The audit flags `dio_client.dart:27`'s direct `dotenv` read as legacy.
- `ApiEndpoints` entries: getters when static, functions when parameterised (e.g. `tradeQuote(String uuid)`).
- Ignore the commented top of `dio_client.dart` — the live class starts at line 24.

## Common commands
None module-specific.
