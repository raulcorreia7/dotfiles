---
description: Plan commits, confirm, then execute
agent: build
subtask: false
---

## Purpose

Craft human-first commit history and execute it.

## Process

### 1. Analyze Changes

- Staged and unstaged changes
- Current git status
- Branch name (extract issue reference if present)

### 2. Detect Issue Reference

Parse branch name for issue number:

- `feat/123-add-foo` → `(#123)`
- `fix/ABC-456-bug` → `(ABC-456)`
- `main`, `develop`, no pattern → no reference

Apply to all commits in the plan.

### 3. Plan Commits

For each cohesive cluster, show **full message preview**:

```
[Commit N/Total]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type(scope): imperative summary (#issue)

Optional body line 1
Optional body line 2

Files:
  src/foo/bar.ts
  tests/foo/bar.test.ts

Coverage: tests included | docs included | N/A
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Principles:**

- Group by single responsibility
- Keep logic and tests together
- Flag generated/noisy changes
- Conventional Commits: feat, fix, refactor, chore, test, docs

**Ordering:**

1. Config/chores
2. Refactors
3. Features/fixes
4. Tests
5. Docs

### 4. Confirm Per Commit

For each planned commit, ask:

```
Proceed with Commit N? [y/n/e/skip]
  y     - proceed
  n     - abort all
  e     - edit message before committing
  skip  - skip this commit, continue to next
```

### 5. Output Commands

For each confirmed commit, output the exact commands for the user to run manually:

```
git add <file1> <file2> ...
git commit -m "type(scope): imperative summary (#issue)

Optional body line 1
Optional body line 2"
```

**Do not execute any git commands unless ordered to.**
