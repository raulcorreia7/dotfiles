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
4. **Verify** — Run tests/lint/build as appropriate
5. **Update Plan** — Mark task `[x]` with commit hash or evidence

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
- Update plan when done
- Report blockers clearly

## Guardrails

- Don't touch other tasks
- Ask if requirements unclear
- Fail fast with context
