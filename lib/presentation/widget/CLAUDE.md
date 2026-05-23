# lib/presentation/widget/

## Purpose
Reusable presentation widgets used across multiple screens. 14 files: buttons, headers, indicators, dropdowns, embedded cameras, share button, dark-mode toggle. All are stateless or thinly stateful — no business logic, no HTTP, no provider awareness.

## Key files
- `primary_button.dart` — `PrimaryButton`: purple-gradient `GestureDetector` button. **Canonical reusable-widget shape** but hard-codes `Colors.purple` (new widgets should use `AppColors`).
- `purple_button.dart` — alternate purple button variant.
- `common_header.dart` — header with back arrow + title.
- `Common_header_withlogo.dart` — header variant with logo. **PascalCase filename — pre-existing inconsistency.**
- `common_bottom_sheet.dart` — `CommonBottomSheet.open(...)` utility for draggable scrollable sheets.
- `common_share_button.dart` — share button using `CupertinoIcons.arrowshape_turn_up_right` (the only `cupertino_icons` usage in the app).
- `country_picker.dart` — country dropdown widget.
- `custom_camera.dart` — embedded camera widget. **~52 % commented-out** (older implementations).
- `dark_mode_toggle.dart` — dark-mode switcher; persists via `LocalStorage` through `ThemeProvider`.
- `step_indecator.dart` — step indicator. **Filename misspelling** (`indecator` → `indicator`).
- `buy_bottom_sheet.dart`, `deposit_success.dart`, `icon_container.dart`, `leading_icon.dart`, `rounded_tab_indicator.dart`, `customSnackBar.dart` — small wrappers. `customSnackBar.dart` uses camelCase filename — pre-existing inconsistency.

## Data flow
Stateless inputs → rendered output → callbacks fire to caller (`VoidCallback onTap`, `ValueChanged<T> onChanged`, etc.). No data fetching, no `notifyListeners`, no `LocalStorage` reads.

## Dependencies
- Outbound: `flutter`, `flutter_screenutil`; sometimes `lib/core/theme/*` (preferred); a few hard-code `Colors.*`.
- Inbound: `lib/presentation/screens/*` (every feature screen).

## Conventions
- `extends StatelessWidget` where possible.
- All inputs as `final` fields with a `const` constructor and `super.key` named param.
- Sizing via `flutter_screenutil` (`55.h`, `30.r`, `16.sp`).
- New widgets should pull from `AppColors` / `AppTextStyle` rather than literal `Colors.*` / inline `TextStyle`.
- Filename inconsistencies (`Common_header_withlogo.dart`, `step_indecator.dart`, `customSnackBar.dart`) are pre-existing — new widgets must use `snake_case.dart` with correct spelling.

## Common commands
None.
