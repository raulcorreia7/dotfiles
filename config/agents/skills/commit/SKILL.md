---
name: commit
description: "Manual invocation only. Use only when the user explicitly asks to stage or commit changes, choose commit boundaries, inspect commit scope, or write commit messages. Do not use automatically after implementation, validation, review, docs, or prior permission."
---

# Commit

## Job

Create focused commits only after explicit user request.

## Steps

1. Inspect status and relevant diffs before staging.
2. Identify one coherent requested boundary.
3. Stage explicit paths only; avoid `git add .` unless status proves every changed file belongs.
4. Re-check staged diff before committing.
5. Use Conventional Commits by default: `<type>[optional scope]: <description>`.
6. Add a body only for useful rationale, behavior, migration, or validation.
7. If the commit changes version metadata, generated changelog output, or
   release bump files, include the exact version in the subject.
   Example: `chore(release): prepare v0.3.2`. Avoid generic subjects like
   `patch bump` or `prepare release`.

## Output

- Hash and subject when committed
- Included scope/files
- Intentionally unstaged files
- Why no commit happened, if applicable

## Guardrails

- Do not infer permission from implementation, validation, review, docs, or prior turns.
- Do not stage unrelated/user-authored work.
- Do not commit secrets, env files, build artifacts, caches, editor state, or unexpected generated files.
- Do not amend, rebase, squash, tag, push, or force-push unless explicitly requested.
