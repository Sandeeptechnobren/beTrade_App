---
name: test-api
description: Write and run API contract tests
---
Write API contract tests for this project.

1. Read `docs/ARCHITECTURE.md` for the API surface (all endpoints)
2. Read `docs/PATTERNS.md` for the expected response format
3. For **each** API endpoint, write tests that verify:
   - Correct HTTP status code for success (200, 201, 204)
   - Correct HTTP status code for errors (400, 401, 403, 404, 422, 500)
   - Response body matches the documented shape (correct fields, correct types)
   - Required fields are never null/missing
   - Pagination works correctly (limit, offset, total count)
   - Authentication is required where expected (returns 401 without token)
   - Error responses follow the project's standard error format
4. Run all tests and report results

> **Project note**: This Flutter app's "API tests" effectively test the client's parsing of backend responses. Use `flutter_test` plus mocked HTTP responses (e.g., `http_mock_adapter` for Dio, or `nock`-style with `http`). The backend at `api.buildacademy.io` is third-party — don't hit it from automated tests.

Group results by endpoint. Format:
```
[METHOD] [PATH] → [N tests passed, M failed]
```
For failures: `[test name] — expected [X], got [Y]`
