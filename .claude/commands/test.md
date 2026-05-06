---
name: test
description: Run the project test suite and report results
---
Run the full test suite for this project:

1. Read `CLAUDE.md` to find the correct test command
2. Run the test command (this Flutter project: `flutter test`)
3. Report results: total tests, passed, failed, skipped
4. For any failures, show the test name, file, and error message
5. Suggest fixes for failing tests if the cause is obvious

**Note**: As of the initial documentation pass, `flutter test` fails on `main` because `test/widget_test.dart` is the unmodified `flutter create` scaffold and asserts on widgets that don't exist in `MyApp`. See `test/CLAUDE.md`.

Do NOT modify any code unless I explicitly ask you to fix a failing test.
