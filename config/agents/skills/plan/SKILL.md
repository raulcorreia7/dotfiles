---
name: plan
description: "Use for architecture or implementation planning: boundaries, contracts, data, migrations, rollout, tests, risks, and handoff. Do not use for direct implementation, commit, or pure code review."
---

# Plan

## Job

Turn an ambiguous or non-trivial change into an implementation-ready path with clear decisions, phases, validation, and risks.

## Steps

1. Identify goal, non-goals, constraints, reader, and context mode: prompt-only, repo-informed, or greenfield.
2. Inspect repo evidence when it can change boundaries, APIs, data, rollout, tests, or risk.
3. Resolve material decisions before finalizing; state assumptions when proceeding.
4. Choose the smallest maintainable design that fits local conventions.
5. For docs, references, or folder-structure plans, include concept boundaries, indexes, cross-links, citations, and validation of moved links.
6. Order work by dependency and risk: safety nets first, contracts before consumers, rollout before cleanup.
7. Add diagrams only when they reduce load.

## Output

- Goal
- Decisions
- Target shape
- Steps or phases
- Contracts/data/config changes
- Validation
- Risks and rollback
- Assumptions/open questions

## Guardrails

- Do not implement unless separately asked.
- Do not leave public contracts, storage, rollout, or validation for the implementer to invent.
- Do not create a deep plan when a short checklist is enough.

## References

- Read `references/diagrams.md`, then use `$diagrams` and `../../references/diagrams/diagrams.md` for Mermaid syntax, Azure DevOps compatibility, edge labels, and visual polish.
- Read `../../references/okf/okf.md` when planning documentation IA, references, folder structure, or knowledge-catalog work.
