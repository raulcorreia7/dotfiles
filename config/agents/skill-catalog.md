# Skill Catalog

> Trigger and routing catalog for the team Codex skills pack.

## Philosophy

Small skills. Sharp triggers. One job each. Composable by default.

- Global taste lives in `~/.codex/AGENTS.md`.
- Skills carry repeatable workflows.
- References carry optional depth.
- Recipes carry provider/project-specific patterns.
- Use subagents only for bounded, parallel, read-only work that is large enough to justify the overhead.

## Quick Path

| Task | Command or file |
|---|---|
| Install the pack | `bash tools/sync-files.sh --apply` |
| Install the pack on Windows | `pwsh -File tools/sync-files.ps1 -Apply` |
| Validate skills | `bash tools/validate-skills.sh` |
| Check installed drift | `bash tools/sync-files.sh` |
| Authoring guide | [skills/README.md](skills/README.md) |
| Maintainer notes | repo `docs/agent-guidance.md` |

## Installed Surfaces

| Surface | Default install target | Purpose |
|---|---|---|
| Global guidance | `$CODEX_HOME/AGENTS.md` | Always-on style, evidence, Goldilocks engineering |
| Skills | `$HOME/.agents/skills` | Reusable task workflows |
| Shared references | `$HOME/.agents/references` | Cross-skill references for languages, comments, diagrams, and subagent templates |
| Skill catalog | `$HOME/.agents/skill-catalog.md` | Human-readable trigger/reference map |
| Rules | `$CODEX_HOME/rules` | Optional command permission rules |
| Custom agents | `$CODEX_HOME/agents` | Opt-in specialized agents, such as Azure Explorer |

`CODEX_HOME` defaults to `$HOME/.codex`.

## Skill Groups

### Core implicit skills

| Skill | Trigger | Avoid |
|---|---|---|
| `$code` | Normal application-code implementation, edits, and explanations | Scripts, docs, commits, reviews, strict TDD, diagnosis, behavior-preserving refactors |
| `$plan` | Architecture or implementation planning | Direct implementation, commits, pure review |
| `$review` | Code/diff review | PR/story orchestration, docs-only review |
| `$pr-review` | PR/MR/story URL, local branch, diff, PR text proposal | Posting comments or mutating PRs without approval |
| `$diagnose` | Broken, failing, throwing, flaky, or slow behavior | Broad refactors before a repro loop exists |
| `$test` | Risk-based test design, adding/reviewing tests | Strict TDD unless requested |
| `$tdd` | Explicit test-first red-green-refactor or vertical slices | Normal testing |
| `$refactor` | Explicit behavior-preserving simplification/reorganization | Incidental cleanup |
| `$docs` | README, how-to, reference, runbook, API/config docs, diagrams | Product decisions or code review unless docs are the artifact |
| `$docs-polisher` | Plan or implement docs IA, navigation, duplication, links, readability, diagrams | Code edits, publishing, large rewrites without source evidence |
| `$code-comments` | Audit and improve source comments, docstrings, public API docs, markers, density, and style | Runtime behavior changes unless explicitly requested |
| `$diagrams` | Mermaid diagrams, Azure DevOps wiki compatibility, edge labels, and visual styling | Diagrams that do not reduce cognitive load |
| `$scripts` | Repo automation, TypeScript/Node/zx scripts, CLIs, maintenance scripts | App feature code unless automation is the entrypoint |
| `$pipeline` | Typed task pipelines, staged processing, complex script flows, validation/import/export/codemod/generator pipelines | CI/CD pipelines, simple shell pipes, small linear code |
| `$ast-grep` | Structural code search/rules/rewrite previews | Plain text search or missing ast-grep binary |
| `$codebase-design` | Module interfaces, seams, deep modules, testability, locality | Generic architecture essays without concrete pressure |
| `$domain-modeling` | `CONTEXT.md`, context maps, glossary terms, ADR-worthy decisions | Specs, scratch notes, implementation logs |

### Explicit/manual skills

These are reachable only when the user types them or names the workflow directly. Their `agents/openai.yaml` should set `policy.allow_implicit_invocation: false`.

| Skill | Trigger | Avoid |
|---|---|---|
| `$commit` | Explicit staging/commit/message request | Automatic commits, push/rewrite unless explicit |
| `$goal-loop` | Explicit goal implementation loop using `.codex/goals/<slug>.md` and bounded subagents | Small edits, normal planning, reviews, one-shot implementation |
| `$grill-me` | Stateless one-question-at-a-time interrogation | Repo/domain doc updates; use `$grill-with-docs` |
| `$grill-with-docs` | Repo-backed grilling with `CONTEXT.md`/ADR updates | Stateless design grilling |
| `$triage` | Issue/PR/report triage into category/state roles | Mutating trackers without approval |
| `$worktrees` | Explicit Git worktree create/adopt/inspect/move/repair/remove/prune workflow | Automatic branch deletion, forced cleanup, provider checkout without requested context |
| `$improve-codebase-architecture` | Architecture-deepening scan and visual candidate report | Direct refactoring or style-only cleanup |
| `$to-prd` | Synthesize current conversation into a PRD | Under-specified ideas; grill first |
| `$to-issues` | Split plan/spec/PRD into vertical-slice issues or one standalone issue file per slice | Publishing issues without approval; one mega issue file |
| `$prototype` | Throwaway logic/state or UI prototype | Production implementation |

### Productivity skills

These are manual stateful workflows for personal productivity. Their `agents/openai.yaml` should set `policy.allow_implicit_invocation: false`.

| Skill | Trigger | Avoid |
|---|---|---|
| `$teach` | Explicit multi-session teaching request using a workspace with mission, resources, lessons, references, learning records, glossary, and notes | One-off explanations, generic tutoring, unsupported factual claims |

### Broad read-only skills

| Skill | Trigger | Avoid |
|---|---|---|
| `$discover` | Source-backed repo/system discovery | Routine implementation/docs edits |
| `$audit` | Read-only project/code/test/docs/infra/security/full audits | Mutations, live checks without approval |

## Common Flows

| Flow | Route |
|---|---|
| Idea to build | `$grill-with-docs` -> `$prototype` if needed -> `$to-prd` -> `$to-issues` |
| Stateless design alignment | `$grill-me` -> `$plan` |
| Explicit goal execution | Codex `/goal` for session state -> `$goal-loop` for repo-local execution state |
| Incoming bug/request queue | `$triage` -> `$diagnose` or `$to-issues` |
| Hard bug | `$diagnose` -> `$tdd` for regression seam -> `$improve-codebase-architecture` if no good seam exists |
| Codebase health | `$improve-codebase-architecture` -> `$grill-with-docs` -> `$plan` or `$refactor` |
| PR/story review | `$pr-review` -> `$review` for code findings when needed |

## Trigger Policy

- Descriptions must be concise and front-load trigger words.
- Keep implicit skills narrow enough to avoid accidental use.
- Command-only skills use `agents/openai.yaml` `policy.allow_implicit_invocation: false`.
- Commit remains explicit-only.
- If a skill triggers too often, narrow its description before adding more rules.

## What Belongs Where

| Surface | Use for | Do not use for |
|---|---|---|
| `AGENTS.template.md` | Always-on defaults, style, evidence, Goldilocks taste | Long checklists, provider recipes, task workflows |
| `.agents/skill-catalog.md` | Installed trigger and routing catalog for the skills pack | Repo maintainer docs or explanatory project history |
| Skill | Repeatable task workflow with inputs, steps, output, guardrails | Generic personality or one-off notes |
| Reference | Optional examples/checklists/templates inside a skill's `references/`, or shared material in `.agents/references/` when multiple skills use it | Rules every run must read |
| OKF reference | Shared knowledge-maintenance model for docs, references, indexes, citations, and folder structure | Strict source format for Codex `SKILL.md` files |
| Recipe | Repo-only provider/project notes not needed by installed skills | Installed skill dependencies; put those in skill-local references |
| Custom agent pack | Specialized agent instructions and MCP policy that should not load in normal Codex sessions | Always-on repo behavior or broad style rules |
| Subagent | Bounded parallel read-only exploration | Normal implementation or cheap reasoning |
| Plugin | Distribution bundle for reusable skills/apps | Local authoring only |

## Authoring Rules

- Names are lowercase kebab-case; folder name equals frontmatter `name`.
- Every skill has `SKILL.md` and `agents/openai.yaml`.
- Use imperative steps with explicit output and guardrails.
- Keep `SKILL.md` compact and self-contained for the skill's unique job.
- Put bulky examples, checklists, templates, and source notes in skill-local `references/`.
- Put shared references used by multiple skills in `.agents/references/<topic>/<topic>.md`.
- Link shared references from the relevant `SKILL.md`; do not duplicate their content into each skill.
- When prescribing text search, say grep-like search and use `rg` only as the preferred tool when available.
- Put provider-specific material in skill-local `references/` when a skill depends on it; otherwise keep it in repo-only `recipes/`.
- Update this catalog and run validation after changes.

## Selected Matt-Inspired Skills

Included:

- `$teach`
- `$grill-me`
- `$grill-with-docs`
- `$triage`
- `$improve-codebase-architecture`
- `$to-issues`
- `$to-prd`
- `$prototype`
- `$diagnose`
- `$tdd`
- `$domain-modeling`
- `$codebase-design`

Excluded from the generic base for now:

- `$ask-matt`: covered by this catalog's common flows.
- `$setup-matt-pocock-skills`: too repo-specific; use project-local setup docs when needed.

## Validation

```bash
bash tools/validate-skills.sh
```

## Sources

- Codex skills: https://developers.openai.com/codex/skills
- Codex AGENTS.md: https://developers.openai.com/codex/guides/agents-md
- Codex customization: https://developers.openai.com/codex/concepts/customization
- Matt Pocock engineering skills: https://github.com/mattpocock/skills/tree/main/skills/engineering
- Matt Pocock productivity teach skill: https://github.com/mattpocock/skills/tree/main/skills/productivity/teach
