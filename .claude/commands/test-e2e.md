---
name: test-e2e
description: Write and run Playwright E2E browser tests
---
Write Playwright end-to-end tests for critical user flows.

1. Check if Playwright is installed. If not: `npx playwright install`
2. Read `docs/ARCHITECTURE.md` for frontend routes/pages
3. Read `docs/QA-SHEET.md` for critical user flows (Priority 1) — if it exists
4. For each critical flow, write a `.spec.ts` file that:
   - Navigates to the page
   - Performs actions (clicks, type, submit)
   - Asserts outcomes
   - Takes screenshot on failure
   - Tests both desktop (1280×720) and mobile (375×667)
5. Run: `npx playwright test`
6. **AUTO-FIX LOOP**: If tests fail — read failure + screenshot, determine if test bug or app bug, fix test bugs (max 3 cycles per file), report app bugs (do NOT fix them)
7. Report: total flows, pass/fail per flow, failure screenshots, app bugs found

Test files go in: `tests/e2e/` (or whatever this project already uses).

> **Project note**: this Flutter app's web target is the unmodified default scaffold. Playwright would only apply if/when the web target ships. For mobile E2E, prefer `integration_test` (Flutter's built-in) or Patrol — not Playwright.

Do NOT fix application code.
