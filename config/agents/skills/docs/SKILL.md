---
name: docs
description: "Use for creating, editing, restructuring, or validating technical documentation: README, how-to, reference, architecture docs, runbooks, API/config docs, diagrams, and docs tooling. Do not use for code review or product decisions unless documentation is the main artifact."
---

# Docs

## Job

Create or improve source-backed documentation with high signal first and deeper explanation lower on the page.

When the work involves knowledge catalogs, references, folder structure, agent-facing docs, or explicit OKF requests, use OKF-inspired authoring: one durable concept per page, explicit links between related concepts, `index.md` for folder navigation, citations for external or drift-prone claims, and optional `log.md` for meaningful lifecycle notes.

## Signal Gradient

Default order:

1. Title.
2. One-line summary.
3. TL;DR.
4. Visual overview, optional.
5. Quick path.
6. Common tasks.
7. Facts/contracts.
8. Examples.
9. Details/trade-offs.
10. Troubleshooting.
11. Appendix/reference.

Do not start with background unless the reader needs it to act safely.

Use diagrams early only when they compress orientation or make the reader safer/faster. Put flow, sequence, state, data, or dependency diagrams next to the section they explain; put large or exhaustive diagrams in appendix/reference.

## Steps

1. Identify reader, doc type, scope, source of truth, and target location.
2. Ground claims in repo files, docs, code, config, pipelines, tests, work items, contracts, public docs, or user material.
3. Preserve names, links, `.order`, terminology, and tooling unless reorganizing is requested.
4. Use tables for structured facts and code fences with accurate languages.
5. Add frontmatter only when local tooling allows it; for `SKILL.md`, keep Codex-compatible top-level keys and put optional OKF-style fields under `metadata.okf`.
6. Link instead of duplicating when another source owns the fact.
7. Validate links, examples, Markdown, diagrams, and unverifiable claims as practical.

## Output

- Ready doc or targeted edits
- Files affected
- Sources/evidence
- Checks run/skipped
- Assumptions and unverifiable facts

## Guardrails

- Do not invent architecture, ownership, deployment, operations, APIs, config, or process facts.
- Never include secrets or private live values.
- Do not write long docs when a compact page or section is enough.
- Write docs for human scanning: concise, natural, and easy to act on.
- Prefer short phrases and small concepts over long prose when meaning stays clear.
- Prioritize readability, then maintainability, then structural complexity.

## References

- Read `references/doc-shapes.md` for README/page/runbook/reference shapes.
- Read `references/diagrams.md`, then use `$diagrams` and `../../references/diagrams/diagrams.md` for diagram-heavy docs.
- Read `references/azure-devops-wiki.md` only when Azure DevOps wiki structure is explicitly in scope.
- Read `../../references/okf/okf.md` when authoring OKF-inspired docs, references, folder indexes, knowledge catalogs, or Codex skill metadata.
