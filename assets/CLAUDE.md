# assets/

## Purpose
Static assets bundled into the Flutter app. Three subfolders: `images/`, `logo/`, and `fonts/` (SFProRounded family, single weight). The app's `.env` file at the repo root is also bundled as a Flutter asset (declared in `pubspec.yaml:39`) — see `docs/CODEBASE_AUDIT.md` §9 for why this is a concern.

## Key files / folders
- `fonts/SF-Pro-Rounded-Regular.ttf` — registered in `pubspec.yaml` under `flutter.fonts` as the `SFProRounded` family, weight 400. Only weight available; no bold/italic.
- `logo/app_icon.png` — source image for `flutter_launcher_icons` (configured in `pubspec.yaml` lines 47–52). Adaptive Android icon background `#ffffff`.
- `logo/` — additional logo variants used in headers and splash.
- `images/` — feature-specific imagery referenced from `lib/presentation/*` via `Image.asset('assets/images/...')`.

## Data flow
Read at runtime from the Flutter asset bundle. UI code references images by string path; fonts are referenced by family name in `TextStyle(fontFamily: 'SFProRounded')` (see `lib/core/theme/app_text_style.dart`).

## Dependencies
- Outbound: none.
- Inbound: registered under `flutter.assets` in `pubspec.yaml` (`assets/images/`, `assets/logo/`, plus `.env`); referenced from `lib/presentation/*` screens; `pubspec.yaml` `flutter_icons.image_path` points at `assets/logo/app_icon.png`.

## Conventions
- Asset paths must be **explicitly registered** in `pubspec.yaml` under `flutter.assets`. Flutter does not auto-include files; adding a new image file or subfolder requires updating the manifest.
- Font family declared once in `pubspec.yaml`; referenced in code as the literal string `'SFProRounded'`.
- Only one font weight (400) is registered. New weights require additional `fonts.fonts` entries in `pubspec.yaml`.
- Keep filenames lowercase + hyphens (PNG/JPG); PascalCase / camelCase image names are inconsistent and harder to reference reliably across platforms.

## Common commands
- `flutter pub get` — re-resolve assets after updating `pubspec.yaml`.
- `dart run flutter_launcher_icons` — regenerate Android + iOS launcher icons after replacing `assets/logo/app_icon.png`.
- After adding files: ensure the parent path is listed under `flutter.assets`, then `flutter pub get` and a hot-restart (not just hot-reload).
