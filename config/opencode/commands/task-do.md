---
description: Execute a single task from a plan
agent: build
subtask: true
---

## Purpose

Execute one task in isolation. Reads plan, does task, updates plan.

## Usage

- `/task-do <slug> <task-id>` — Run task N from `docs/plans/slug-*.md`
- `/task-do <task-id>` — Run task from most recent plan
- `/task-do` — Run next pending task from most recent plan

## Process

1. **Load Plan** — Read plan file, find task by ID
2. **Gather Context** — Read key files listed in plan
3. **Execute** — Implement the task objective
4. **Verify** — MUST pass verification before marking complete:
   - Run tests/lint/build (no new failures or warnings)
   - Manual check: does the change work end-to-end?
   - If tests don't exist, describe what was manually verified
5. **Update Plan** — Mark task `[x]` only after verification passes, include:
   - Commit hash (if committed)
   - Evidence: what tests ran, what was manually verified

## Output

```
✓ Task N: Title
  - Files changed: a.ts, b.ts
  - Tests: passing
  - Commit: abc1234 (if committed)
```

## Principles

- One task only
- Stay in scope
- **No assumed completion** — verify before marking done
- Update plan when done (with evidence)
- Report blockers clearly

## Guardrails

- Don't touch other tasks
- Ask if requirements unclear
- Fail fast with context
