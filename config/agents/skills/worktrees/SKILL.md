---
name: worktrees
description: "Manual. Use only when the user explicitly invokes worktrees or asks for a Git worktree workflow: create, adopt, inspect, move, repair, lock, remove, prune, or checkout review branches in linked worktrees."
---

# Worktrees

## Job

Run predictable Git worktree workflows with explicit paths, preflight checks, and cleanup guardrails.

## Defaults

- Use native `git worktree` commands first.
- Default path shape: `../<repo-name>-worktrees/<branch-slug>`.
- Slug branch names by lowercasing, replacing `/`, `\`, whitespace, and unsafe path characters with `-`, collapsing repeated `-`, and trimming edges.
- Treat branch deletion as a separate explicit action, never part of normal worktree removal.
- Do not mutate Git config by default.

## Preflight

1. Confirm the repo root and current branch state:

   ```bash
   git rev-parse --show-toplevel
   git status --short --branch
   git worktree list --porcelain
   ```

2. Resolve defaults explicitly:

   ```bash
   repo_root="$(git rev-parse --show-toplevel)"
   repo_name="$(basename "$repo_root")"
   base_ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')"
   ```

3. If `origin/HEAD` is missing, inspect remotes or use the current `HEAD` only after stating the assumption.
4. Check whether the branch or target path already exists before creating a worktree.

## Core Workflows

### Create New Branch

Use this when starting new work from a known base branch.

```bash
branch="<branch-name>"
base="origin/<default-branch>"
path="../<repo-name>-worktrees/<branch-slug>"
git worktree add -b "$branch" "$path" "$base"
```

### Adopt Existing Local Branch

Use this when the branch already exists locally.

```bash
branch="<branch-name>"
path="../<repo-name>-worktrees/<branch-slug>"
git worktree add "$path" "$branch"
```

If Git reports that the branch is already checked out in another worktree, inspect with `git worktree list --porcelain` and use the existing worktree instead.

### Adopt Remote Branch

Use this when the branch exists on a remote and no local branch exists yet.

```bash
remote_branch="origin/<branch-name>"
local_branch="<branch-name>"
path="../<repo-name>-worktrees/<branch-slug>"
git worktree add --track -b "$local_branch" "$path" "$remote_branch"
```

Network fetches require normal approval when the environment gates network access.

### Detached Review Worktree

Use this for read-only or throwaway review at a commit, tag, or remote ref.

```bash
ref="<commit-ish>"
path="../<repo-name>-worktrees/review-<slug>"
git worktree add --detach "$path" "$ref"
```

### List And Inspect

```bash
git worktree list
git worktree list --porcelain
git -C "<worktree-path>" status --short --branch
```

Prefer `--porcelain` when parsing or comparing state.

### Move

Use Git's move command rather than manually moving folders.

```bash
git worktree move "<old-path>" "<new-path>"
```

If a worktree was moved manually, use repair.

### Repair

Use after linked worktrees or the main worktree were moved by filesystem operations.

```bash
git worktree repair
git worktree repair "<path-to-moved-worktree>"
```

Re-run `git worktree list --porcelain` afterward.

### Lock And Unlock

Use locks for worktrees on removable drives, network mounts, or locations that should not be pruned.

```bash
git worktree lock --reason "<short reason>" "<worktree-path>"
git worktree unlock "<worktree-path>"
```

### Remove

Remove only clean worktrees by default.

```bash
git -C "<worktree-path>" status --short --branch
git worktree remove "<worktree-path>"
```

If the worktree is dirty, stop and report the status. Use `--force` only after explicit user approval and only when the loss is understood.

### Prune

Always dry-run first.

```bash
git worktree prune -n
git worktree prune
```

Use prune for stale administrative files, not for branch cleanup policy.

## Optional Config

- `git config worktree.guessRemote true`: opt in when new local branch names usually match one remote tracking branch.
- `git config worktree.useRelativePaths true`: opt in only when the main repo and linked worktrees move together and every Git version in use supports relative worktree paths.

Do not set either config without explicit user intent.

## Output

- Repo root and current worktree state.
- Chosen branch, base ref, and target path.
- Exact commands run or proposed.
- Cleanup safety checks and any skipped destructive steps.
- Provider reference used, if any.

## Guardrails

- Do not use `/tmp`, `.tmp`, or repo-local `.worktrees` as the default path.
- Do not delete local or remote branches as part of worktree removal.
- Do not use `--force`, `-B`, real prune, branch deletion, or network fetches without approval when risk or environment policy requires it.
- Do not treat provider CLIs as available until checked.
- Do not parse human `git worktree list` output when `--porcelain` is available.

## References

- Read `references/providers.md` when the user asks to check out a GitHub PR, GitLab MR, or Azure DevOps PR into a worktree.
