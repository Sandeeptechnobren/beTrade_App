# test/

## Purpose
Flutter test directory. Currently contains exactly **one** file — the unmodified default scaffold from `flutter create`. It does not test the actual app and **`flutter test` will fail on `main`** because its assertions reference a counter widget that does not exist in `MyApp` (which renders `SplashScreen`).

## Key files
- `widget_test.dart` — the default scaffold. `testWidgets('Counter increments smoke test', ...)` pumping `const MyApp()` and asserting on `find.text('0')` and `find.byIcon(Icons.add)`. None of those widgets exist in `MyApp`'s tree.

## Data flow
None — there is no real coverage. Effective `lib/` coverage is ~0% (87+ source files, none exercised).

## Dependencies
- Outbound: `flutter_test` (only); imports `MyApp` from `package:betrade/main.dart`.
- Inbound: invoked by `flutter test` from the repo root.

## Conventions
- Test framework: `flutter_test`.
- File naming: `<thing_under_test>_test.dart`.
- Top-level `void main()` containing `testWidgets(...)` / `test(...)` calls.
- No mocking package is configured (`mockito`, `mocktail`, `bloc_test`, `fake_async` are all absent from `dev_dependencies`). Adding `mocktail` would be the first step before testing providers/services.
- No `integration_test/` folder exists; no `integration_test` dev-dep.
- The current `widget_test.dart` is **broken** — replace it (don't extend it) when adding the first real test. A first useful test would mock the providers and pump `MyApp` to assert the splash screen renders.

## Common commands
- `flutter test` — run all tests (currently fails on `main`).
- `flutter test --coverage` — run with coverage; output to `coverage/lcov.info` (gitignored).
- `flutter test test/widget_test.dart` — run a single file.
- `flutter test --plain-name 'Counter'` — run tests matching a substring.
