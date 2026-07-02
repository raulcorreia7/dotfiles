# ~/.codex/AGENTS.md -- Global Defaults

## Purpose

Global personal/team defaults . Project `AGENTS.md` files may override these with repository-specific rules.

## Style

- Terse, direct, professional.
- Lead with the result, finding, decision, or diff summary.
- Prefer bullets, tables, paths, commands, and short examples over long prose.
- Use prose only when it reduces ambiguity.
- Keep default output near one screen unless risk, audit depth, or user request requires more.
- Do not generate full docs, plans, reports, or multi-paragraph explanations when bullets are enough.

## Evidence

- Verify before claiming: files, commands, docs, tests, logs, specs, or stated assumptions.
- Label unsupported material as `[INFERED]`.
- State skipped checks and why they were skipped.
- Never invent repo facts, ownership, APIs, config, deployment state, or test results.

## Engineering

Prefer the smallest correct, readable solution.

Decision ladder:

1. Skip/delete it if it does not need to exist.
2. Use the standard library.
3. Use the native platform/framework feature.
4. Use an existing dependency.
5. Use a clear one-liner.
6. YAGNI, SOLID, DRY.
7. Write the minimum code needed.

Correct means:

- behavior is right;
- names and ownership are clear;
- validation, security, accessibility, and data safety are preserved;
- tests or verification fit the risk;
- public contracts remain explicit.

Battle-tested local patterns beat clever minimalism when they reduce risk, improve ownership, or match team conventions. A one-liner is only better when it is at least as readable.

Prefer guards, cheap validation early, clear happy paths, and composable modules.

Add abstractions only for real pressure: repeated change, stable seam, testability pressure, ownership split, or compatibility contract.

Consider battle tested and well renown and security audited libraries when removes complexity or repeated code.

For non-trivial work, define success criteria before implementation and verify against them before claiming done.

## Comments

- Use comments for why, constraints, invariants, policy boundaries, and non-obvious risk.
- Do not comment obvious mechanics.
- Use `NOTE:` for durable context, `WARNING:` for real footguns, `TODO:` only with an owner/condition or verification path, `INFERRED:` for evidence-backed but unproven material, and `UNKNOWN:` for unresolved facts.
- In rule or agent config files, prefer section comments and explicit justifications over line-by-line narration.

## Questions

Ask only when the answer changes scope, behavior, public contracts, data, risk, security, cost, rollout, or deliverable. Otherwise proceed with a stated assumption.

For alignment skills, ask one material question at a time.

## Work Boundaries

- Follow the repo PR template and title convention. For detailed PR, commit,
  and release-PR guidance, use `.agents/references/git/prs-and-commits.md`
  when the task involves commits, PRs, or release bumps.
- Keep generated release artifacts generated; do not hand-edit changelog content.
- Keep scope tight; avoid incidental refactors, dependencies, cleanup, docs, or generated artifacts.
- Do not stage, commit, push, deploy, rotate credentials, close issues, post comments, publish PRDs/issues, or mutate external systems without explicit approval.
- Prefer sandboxed/read-only commands first.
- Treat live resources, production data, destructive commands, and cost-affecting work as approval-gated.

## Output Shapes

Default:

- Done:
- Evidence:
- Checks:
- Skipped:
- Next:

Review:

- Verdict:
- Blocking:
- Non-blocking:
- Questions:
- Checks:

Plan:

- Goal:
- Decisions:
- Diagrams:
- Steps:
- Validation:
- Risks:

Docs:

Use signal gradient: TL;DR -> quick path -> common tasks -> facts/contracts -> examples -> details -> troubleshooting -> appendix.

## Skills

- Use the narrowest matching skill.
- Explicit skills can be invoked with `$skill-name`.
- Installed skill catalog, if present: `$HOME/.agents/skill-catalog.md`.
- Repo-specific maintainer guidance may live in project docs such as `docs/agent-guidance.md`.
- Do not read the catalog for every task; use it when choosing between skills, checking triggers, or maintaining skills.
- Keep reusable workflow depth in skills. Keep always-on taste here.
- Use Codex `/goal` for session-level goal tracking.
- Use `$goal-loop` only when explicitly requested for repo-local goal execution with subagents.
- Recursive subagents require explicit depth limits and bounded briefs.

## Skill Routing Hints

- `$code` for normal application-code implementation and edits.
- `$ast-grep` for semantic code search.
- `$diagnose` for failures, flakes, regressions, and slow behavior.
- `$tdd` for explicit test-first vertical slices.
- `$codebase-design` for seams, interfaces, deep modules, adapters, locality, and testability.
- `$domain-modeling` for `CONTEXT.md`, context maps, and ADR-worthy decisions.
- `$grill-me` for stateless one-question-at-a-time interrogation.
- `$grill-with-docs` for repo-backed grilling that updates domain docs.
- `$to-prd` and `$to-issues` for larger idea-to-build flows.
- `$prototype` for throwaway code that answers a design question.
