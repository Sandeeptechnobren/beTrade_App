# lib/data/model/

## Purpose
Data Transfer Objects (DTOs) decoded from backend JSON. ~13 model classes, all with hand-written `factory fromJson` constructors and **no `toJson`** — outbound payloads are built ad-hoc as `Map<String, dynamic>` literals inside services. Relationships are denormalised (fields like `TradeModel.categoryName` are flat strings, not `CategoryModel` references).

## Key files
- `trade_model.dart` — `TradeModel`. Market listings from `GET /trade/list` and `/trade/explore`. Fields: `uuid`, `categoryName`, `description`, `minTradeAmount` (String), `image?`, `endDate` (String).
- `trade_detail_model.dart` — `TradeDetailModel`. Market detail from `GET /trade/view/{uuid}`. Adds `title`, `currentPricePerShare`.
- `profile_model.dart` — `ProfileModel` from `GET /profile` / `/verify-otp/login`. Includes `_fixAvatar()` helper that strips a duplicated `https://` prefix.
- `position_model.dart` — `PositionModel` + `MarketPositionsModel` from `/positions`. Computed `unrealisedPnlPct`, `isYes` getters. Embeds `market{}` and `outcome{}` as nested dicts.
- `quote_model.dart` — `QuoteModel` from `POST /trade/{uuid}/quote`. All numeric fields parsed via a defensive `n(v)` helper that returns `0.0` for non-numeric input.
- `order_model.dart` — `OrderModel`. Filled-order shape; nested inside `BuyResponse`.
- `buy_response.dart` — `BuyResponse`. Envelope for `POST /trade/{uuid}/buy`; carries `success`, `message`, typed `code`, `OrderModel?`, `QuoteModel?`, `walletBalance`.
- `country_model.dart` — `CountryModel` from `/countries`. **`fromJson` lacks `?? ""` defaults — will throw on missing fields. Do not replicate.**
- `category_model.dart` — `CategoryModel` from `/trade/categories-list`.
- `graph_model.dart` — `ChartData` from `GET /chart` (defined, never called). Class name does not match filename. `.toDouble()` throws on missing fields.

## Data flow
One-way: services call `Model.fromJson(json)` on decoded responses. Models are read-only DTOs; data leaves the app as inline `Map<String, dynamic>` literals in service methods, never via a `toJson`.

## Dependencies
- Outbound: pure Dart (no Flutter, no packages).
- Inbound: `lib/data/services/*` (parse responses), `lib/data/provider/*` (hold lists/instances), `lib/presentation/screens/*` (display).

## Conventions
- All fields `final`; named `required` constructor params; nullable types only for genuinely optional fields.
- Single factory: `factory ModelName.fromJson(Map<String, dynamic> json)`.
- Defensive defaults via `?? ""`, `?? 0.0`, `?? false` (most models follow this; `CountryModel` and `ChartData` are outliers — don't copy them).
- Snake-case JSON keys → camelCase Dart fields, mapped manually inside `fromJson`.
- Numeric/date-shaped fields are sometimes deliberately kept as `String` (`minTradeAmount`, `endDate`) — parse at the call site.
- No code generation: no `freezed`, `json_serializable`, `build_runner`.
- File naming is `<name>_model.dart` matching `<Name>Model`. Pre-existing exception: `graph_model.dart` → `ChartData`. New files should match filename to class.

## Common commands
None.
