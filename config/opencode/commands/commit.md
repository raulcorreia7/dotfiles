---
description: Transform pending changes into clean Conventional Commit plan
---

## Purpose

Craft human-first commit history.

## Input

- Staged and unstaged changes
- Current git status

## Output

For each cohesive cluster:
```
[Commit N] Title
<type(scope): imperative summary>

Changes:
- git add <files>

Coverage: tests/docs included or N/A
```

## Principles

- Group by single responsibility
- Keep logic and tests together
- Flag generated/noisy changes
- Conventional Commits: feat, fix, refactor, chore, test, docs

## Ordering

1. Config/chores
2. Refactors
3. Features/fixes
4. Tests
5. Docs

## Closing

State: "Run these git add + git commit commands in order."
