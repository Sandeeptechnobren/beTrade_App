# ios/

## Purpose
iOS platform project (Xcode). Bundle ID `com.build.betrade`, display name `Betrade`, portrait-locked. Permission usage strings configured for Camera, Microphone, Photo Library (read + add), and Documents Folder. Receives the Flutter module from `lib/` and produces `.app` / `.ipa` artefacts via Xcode.

## Key files
- `Runner/Info.plist` — bundle ID (templated `$(PRODUCT_BUNDLE_IDENTIFIER)`), display name `Betrade`, portrait-only orientation lock, usage strings (`NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`, `NSDocumentsFolderUsageDescription`). **No `CFBundleURLTypes`** (no deep links). **No `NSAppTransportSecurity`** (defaults: HTTPS-only).
- `Runner.xcodeproj/project.pbxproj` — Xcode project. Bundle IDs: `com.build.betrade` (Runner), `com.build.betrade.RunnerTests` (test target). **No `DEVELOPMENT_TEAM`, no `PROVISIONING_PROFILE`** — non-interactive CI signing is unconfigured. Versioning via `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` from `pubspec.yaml` (currently `1.0.0+10`). Pre-existing parse oddity at line ~404: `PRODUCT_BUNDLE_IDENTIFIER =com.build.betrade.RunnerTests` (missing space).
- `Runner/AppDelegate.swift` (+ `AppDelegate.h`) — Flutter iOS bootstrap.
- `Runner/SceneDelegate.swift` — scene lifecycle.
- `Runner/GoogleService-Info.plist` — iOS Firebase credentials (project `betrade-new`). **Committed to git** (see audit §9).
- `Runner/Assets.xcassets/` — iOS app icon set.
- `Flutter/AppFrameworkInfo.plist`, `Flutter/Debug.xcconfig`, `Flutter/Release.xcconfig` — Flutter framework integration.
- `Podfile`, `Podfile.lock` — CocoaPods. iOS 13.0+ platform pin.
- `RunnerTests/RunnerTests.swift` — empty iOS unit-test target (not used).

## Data flow
Receives the Flutter module from `lib/` → Xcode build produces `.app` (Simulator / Device debug) or `.ipa` (`flutter build ipa`) under `build/ios/`.

## Dependencies
- Outbound: Flutter framework, CocoaPods, Firebase iOS SDKs (for FCM).
- Inbound: invoked by Flutter toolchain (`flutter run`, `flutter build ios`, `flutter build ipa`).

## Conventions
- Bundle IDs: `com.build.betrade` (app) and `com.build.betrade.RunnerTests` (test).
- Versioning is dynamic via Flutter (`$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`); single source of truth is `pubspec.yaml`'s `version: 1.0.0+10`.
- **Provisioning team must be configured before non-interactive CI** (Codemagic / TestFlight) can sign builds — currently absent.
- FCM credentials live in `Runner/GoogleService-Info.plist`; don't duplicate values elsewhere.

## Common commands
Run from repo root unless noted.
- `flutter build ios` — build for device.
- `flutter build ipa` — produce signed IPA archive (requires team + provisioning profile).
- `cd ios && pod install` — refresh CocoaPods after `pubspec.yaml` plugin changes.
- `open ios/Runner.xcworkspace` — open in Xcode for signing config / device runs.
- `flutter clean` — wipe `build/` and `.dart_tool/` if iOS gets confused.
