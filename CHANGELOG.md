# Changelog
All notable changes to this project are documented here.
Format: [DATE] [AUTHOR] Description

## [Unreleased]

### Added
- 2026-04-30 — Initial Claude Code documentation layer (`CLAUDE.md`, `docs/`, `tasks/`, `.claude/`).
- 2026-04-30 — `docs/CODEBASE_AUDIT.md` — read-only audit covering structure, tech stack, data flow, models, endpoints, tests, build/deploy, env vars, integrations, and dead code.
- 2026-04-30 — `docs/ARCHITECTURE.md` — system overview, layered architecture, directory map, API surface, auth model, deployment notes.
- 2026-04-30 — `docs/PATTERNS.md` — descriptive style guide with real code examples for the 12 standard pattern categories.
- 2026-04-30 — Per-directory `CLAUDE.md` files in `lib/`, `lib/core/`, `lib/data/`, `lib/data/model/`, `lib/data/provider/`, `lib/data/services/`, `lib/presentation/`, `lib/presentation/widget/`, `lib/presentation/screens/`, `test/`, `android/`, `ios/`, `assets/`.
- 2026-04-30 — Slash commands in `.claude/commands/` (explore, plan, review, done, pickup, test, security, deploy, rollback, monitor, logs, status, generate-manual, db, plus the testing suite and Impeccable bootstrap).
- 2026-04-30 — `.claude/agents/doc-updater.md` — documentation maintenance agent.
- 2026-04-30 — `.claudeignore`, `tasks/todo.md`, `tasks/lessons.md`, `docs/DEPLOY_LOG.md`, `docs/SSH_CONFIG.md`, `docs/ACCESS.md`.

### Changed
- 2026-05-23 — Refreshed Claude Code documentation layer with current state. Corrected stale counts (~14 providers, ~13 models — were 9/5) and token-polling interval (300 s — was 10 s). `.claude/settings.json` Bash permissions adapted from Node-style (`npm`/`pnpm`/`docker`/`pg_dump`) to Flutter-native (`flutter`/`dart`/`pod`/`./gradlew`/`adb`/`firebase`/`flutterfire`) and gained Write/Edit denies for `.env`, `android/key.properties`, `*.keystore`/`*.jks`, and Firebase service files. Root `CLAUDE.md`, docs/, all 13 subdirectory `CLAUDE.md` files, 15 slash commands, and the `doc-updater` subagent rewritten; pre-existing maintainer content in `tasks/todo.md`, `tasks/lessons.md`, prior `CHANGELOG.md` entries, `docs/ACCESS.md`, `docs/SSH_CONFIG.md`, and `.claudeignore` preserved as supersets of provided templates.
- 2026-05-05 — `lib/presentation/screens/signin/otp_screen.dart` migrated to `pinput` (^5.0.0) for the 6-cell OTP input. Replaces the manual `List<TextEditingController>` + `List<FocusNode>` + per-cell `TextField` with a single `Pinput` widget; gains paste-fill, haptics, fade animation, and platform SMS-autofill hooks. All business logic (timer, verify, resend, navigate, error handling) preserved unchanged.

### Fixed
(none)

### Removed
(none)
