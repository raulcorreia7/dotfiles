# Skills

> Summary: reusable Codex workflows maintained by this repo and synced to `$HOME/.agents/skills`.

Each folder under `.agents/skills/` is one skill. A skill owns a repeated workflow, its trigger, guardrails, and optional references.

## Quick Path

Install skills with the normal repo sync:

```bash
bash tools/sync-files.sh --apply
```

On Windows with PowerShell 7+:

```powershell
pwsh -File tools/sync-files.ps1 -Apply
```

Validate all skills before handing off changes:

```bash
bash tools/validate-skills.sh
```

Use a skill explicitly by naming it in a prompt:

```text
$docs-polisher clean up the docs navigation and remove stale links.
```

## Common Skills

| Skill | Use for |
|---|---|
| `$plan` | architecture and implementation planning |
| `$review` | code/diff review |
| `$pr-review` | PR/story review plus alignment and PR text |
| `$diagnose` | tight-loop diagnosis of failures, flakes, regressions, and slowness |
| `$test` | risk-based test design |
| `$tdd` | test-first vertical slices |
| `$refactor` | behavior-preserving simplification |
| `$docs` | signal-gradient technical documentation |
| `$docs-polisher` | docs information architecture, navigation, duplication, links, and readability |
| `$code-comments` | source comments, docstrings, public API docs, markers, and comment density |
| `$diagrams` | Mermaid diagrams, Azure DevOps compatibility, labels, and visual polish |
| `$scripts` | developer automation, TypeScript/Node/zx scripts, and CLI helpers |
| `$ast-grep` | structural code search and rewrite previews |
| `$codebase-design` | modules, interfaces, seams, locality, and testability |
| `$domain-modeling` | `CONTEXT.md`, context maps, glossary terms, and ADR candidates |

## Productivity Skills

| Skill | Use for |
|---|---|
| `$teach` | manual multi-session teaching workspaces with mission, resources, lessons, references, learning records, glossary, and notes |

See [../skill-catalog.md](../skill-catalog.md) for the full trigger map.

## Authoring

1. Copy `.agents/templates/SKILL.md` to `.agents/skills/<skill-name>/SKILL.md`.
2. Keep the folder and frontmatter name lowercase kebab-case.
3. Add `.agents/skills/<skill-name>/agents/openai.yaml`.
4. Keep the description trigger-focused.
5. Add `policy.allow_implicit_invocation: false` for command-only skills.
6. Put skill-specific examples, checklists, templates, and source notes in `references/`.
7. Put cross-skill material in `.agents/references/<topic>/<topic>.md` and link to it from the relevant `SKILL.md`.
8. When prescribing text search, say grep-like search and use `rg` only as the preferred tool when available.
9. Update [../skill-catalog.md](../skill-catalog.md).
10. Run `bash tools/validate-skills.sh`.

## Folder Contract

Keep the leading dot in `.agents`.

| Path | Purpose |
|---|---|
| `.agents/skills/<skill>/SKILL.md` | Required skill definition |
| `.agents/skills/<skill>/agents/openai.yaml` | Skill routing and invocation policy |
| `.agents/skills/<skill>/references/` | Optional skill-local material loaded only when needed |
| `.agents/references/languages/languages.md` | Shared language map used by code, review, refactor, test, and TDD skills |
| `.agents/references/comments/comments.md` | Shared comment guidance for code, scripts, config, rule files, and agent assets |
| `.agents/references/diagrams/diagrams.md` | Shared diagram syntax, renderer, and visual-quality guidance |
| `.agents/references/okf/okf.md` | Shared OKF-inspired knowledge model for docs, references, indexes, citations, and folder structure |
| `.agents/references/subagents/subagents.md` | Shared subagent prompt template index for broad audits and discovery |
| `.agents/templates/SKILL.md` | New skill template |

The dot-prefix keeps repo-local agent assets grouped separately from product docs and source code. Tooling in this repo expects the current `.agents/skills` and `.agents/references` paths.

## Installed Shape

`tools/sync-files.sh` and `tools/sync-files.ps1` copy this tree to user-level paths:

| Repo path | Installed path |
|---|---|
| `.agents/skills` | `$HOME/.agents/skills` |
| `.agents/references` | `$HOME/.agents/references` |
| `.agents/skill-catalog.md` | `$HOME/.agents/skill-catalog.md` |
