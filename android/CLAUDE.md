# android/

## Purpose
Android platform project (Kotlin/Gradle). Customised manifest and build config. Application ID and namespace are both `com.build.betrade`. Built on JDK 11 with R8 + `shrinkResources` enabled. Receives the Flutter module from `lib/` and produces APK/AAB outputs.

## Key files
- `app/build.gradle.kts` — `applicationId`/`namespace` = `com.build.betrade`. **Line 30: `signingConfig = signingConfigs.getByName("debug")`** — release builds use the DEBUG keystore (must be fixed before Play Store distribution; see `docs/CODEBASE_AUDIT.md` §8). `isMinifyEnabled = true`, `isShrinkResources = true`.
- `app/src/main/AndroidManifest.xml` — permissions: `INTERNET`, `CAMERA` (with `<uses-feature required="false">`), `READ_EXTERNAL_STORAGE` (`maxSdkVersion="32"`), `READ_MEDIA_IMAGES`. Only intent-filter is `MAIN`/`LAUNCHER` (no deep links). **`android:usesCleartextTraffic="true"`** at line 17 — should be removed for production.
- `app/src/main/java/com/example/betrade/MainActivity.java` — declares `package com.build.betrade;` despite living under `com/example/betrade/`. Folder/package mismatch; fix by moving the file.
- `gradle.properties`, `settings.gradle.kts`, `build.gradle.kts` (project-level) — Gradle config.
- `app/src/main/res/` — Android resource files (drawable, mipmap, values).
- `gradle/wrapper/gradle-wrapper.properties` — pinned Gradle version.

## Data flow
Receives the compiled Flutter module from `lib/` via the Flutter Gradle plugin → produces `build/app/outputs/flutter-apk/*.apk` (`flutter build apk`) or `build/app/outputs/bundle/release/*.aab` (`flutter build appbundle`).

## Dependencies
- Outbound: Flutter Gradle plugin, AndroidX, Android SDK.
- Inbound: invoked by Flutter toolchain (`flutter run`, `flutter build apk` / `appbundle`).

## Conventions
- Application ID and namespace: `com.build.betrade`.
- No `key.properties`, no env-driven release keystore (release currently signs with debug — fix required).
- No `proguard-rules.pro` despite minify being enabled — only Flutter's default rules apply.
- No `CFBundleURLTypes` / deep-link intent-filter equivalent.

## Common commands
Run from repo root unless noted:
- `flutter build apk` — assemble release APK.
- `flutter build apk --split-per-abi` — produce per-ABI APKs.
- `flutter build appbundle` — produce AAB for Play Store.
- `flutter clean` — wipe `build/` and `.dart_tool/`.
- `cd android && ./gradlew tasks` — list raw Gradle tasks (rare; prefer `flutter` commands).
