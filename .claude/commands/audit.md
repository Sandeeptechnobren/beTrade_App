---
name: audit
description: Run Impeccable design audit on UI work
---
Run a design audit on the current UI work. Use the `frontend-design` skill installed at `.claude/skills/frontend-design/`.

1. Read `.claude/skills/frontend-design/SKILL.md` for the skill's invocation
2. Read `.claude/skills/frontend-design/reference/audit.md` for the audit reference
3. Read `.claude/skills/frontend-design/brand-context.md` if present (per-project context — created by `/teach-impeccable`)
4. Apply the audit to all uncommitted UI changes (screens, widgets, theme, layout)
5. Report findings by severity: Critical, Warning, Suggestion

Run **after** `/review` and **before** `/polish` for any frontend/UI work.
