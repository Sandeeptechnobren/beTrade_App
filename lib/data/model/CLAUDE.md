# lib/data/model/

## Purpose
Data Transfer Objects (DTOs) decoded from backend JSON. Five model classes total, all with manual `fromJson` factory constructors and **no `toJson`** — outbound payloads are built ad-hoc as `Map<String, dynamic>` literals inside services. No relationships between models — fields are denormalised (e.g., `TradeModel.categoryName` is a flat string, not a `CategoryModel` reference).

## Key files
- `trade_model.dart` — `TradeModel`. Trade listings from `GET /trade/list` and `GET /trade/explore`. Fields: `uuid`, `categoryName`, `description`, `minTradeAmount` (kept as String), `image?`, `endDate` (kept as String).
- `profile_model.dart` — `ProfileModel`. User profile from `GET /profile`, `PUT /edit-profile`. Fields: `firstName`, `lastName`, `avatar`, `phone?`, `gender?`, `country?`, `currency?`, `language?`. Includes `_fixAvatar` helper. Lines 1–26 are a stale earlier version (commented out).
- `country_model.dart` — `CountryModel`. From `GET /countries`. Fields: `id`, `name`, `phoneCode`, `flag`, `currency`. **Note**: `fromJson` lacks `?? ""` defaults — will throw on a missing field. Don't replicate this in new models.
- `category_model.dart` — `CategoryModel`. From `GET /trade/categories-list`. Fields: `uuid`, `name` (both default to `""`).
- `graph_model.dart` — `ChartData`. From `GET /chart`. Fields: `x` (← `time`), `y` (← `value`). Class name does not match filename. `.toDouble()` will throw if either field is missing/non-numeric.

## Data flow
One-way: services call `Model.fromJson(json)` on decoded responses. Models are read-only DTOs; data leaves the app as inline `Map<String, dynamic>` literals constructed in service methods (or as `MultipartRequest` form fields), never via a `toJson`.

## Dependencies
- Outbound: pure Dart (no Flutter, no packages).
- Inbound: `lib/data/services/*` (parse responses), `lib/data/provider/*` (hold lists/instances), `lib/presentation/screens/*` (display).

## Conventions
- All fields `final`; named `required` constructor params; nullable types only for genuinely optional fields (e.g., `image`).
- Single factory: `factory ModelName.fromJson(Map<String, dynamic> json)`.
- Defensive defaults via `?? ""` for required-on-Dart-side strings (`TradeModel`, `CategoryModel`, `ProfileModel` follow this; `CountryModel` and `ChartData` do not — they're the outliers).
- Snake-case JSON keys map to camelCase Dart fields manually inside `fromJson`.
- Numeric- and date-shaped fields are deliberately kept as `String` (e.g., `minTradeAmount`, `endDate`) — parsing happens at the call site.
- No code generation: no `freezed`, no `json_serializable`, no `build_runner` in `pubspec.yaml`.
- File naming is `<name>_model.dart` and class is `<Name>Model` (except `ChartData` in `graph_model.dart` — pre-existing inconsistency; new files should match filename to class).

## Common commands
None.
