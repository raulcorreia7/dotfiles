---
description: Break complex task into parallel, self-contained tasks
---

## Purpose

Decompose into tasks that agents can complete in parallel.

## Input

- Goal and constraints
- Architecture (from /architect if available)

## Output

1. **Summary** — Goal in one sentence
2. **Domains** — Components touched
3. **Tasks** — For each:
   ```
   [n] Title
   - Objective: ...
   - Dependencies: ... (None if independent)
   - Done when: ...
   - Commit hint: type(scope): description
   ```
4. **Table** — Task | Component | Depends On

## Principles

- Human-first descriptions
- Single responsibility per task
- Minimal dependencies
- Goldilocks split (not too big, not too small)

## Guardrails

- Avoid overlapping file edits
- Framework-agnostic descriptions
- Reshape until tasks feel "just right"

## Closing

End with: "These [N] tasks can be implemented in parallel. Each is self-contained and conflict-aware."

## Persistence

After planning, write the plan to a file:

1. Check if `docs/plans/` exists; create if needed
2. Look for an existing plan matching this goal (similar name/topic)
3. If found, update it in place
4. If not, create new file: `docs/plans/slug-YYYY-MM-DD.md`
   - Use today's date
   - Slug = 2-4 words from the goal (kebab-case)

File format:
```markdown
# [Goal Title]

**Status**: Planning | In Progress | Complete
**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD

## Summary
[One-line goal]

## Tasks
[List from output above]

## Notes
[Any relevant context or decisions]
```
