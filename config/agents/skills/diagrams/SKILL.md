---
name: diagrams
description: "Use when choosing, drafting, validating, or improving diagrams for docs or plans, especially Mermaid diagrams, Azure DevOps wiki compatibility, edge labels, and polished visual styling."
---

# Diagrams

## Job

Choose and draft source-backed diagrams that reduce cognitive load, use labeled relationships, and render in the target Markdown or wiki surface.

## Steps

1. Identify the reader, doc location, target renderer, and diagram purpose.
2. Read `../../references/diagrams/diagrams.md` for Mermaid types, Azure DevOps support, edge labels, examples, and visual-quality rules.
3. Choose the smallest diagram type that explains the relationship, flow, state, data model, timeline, or decision.
4. Put diagrams near the section they explain; use a small visual overview near the top only when it compresses orientation.
5. Label arrows with what the relationship does, such as `calls`, `writes`, `publishes`, `triggers`, `owns`, or `verifies`.
6. Use restrained semantic colors where supported; never rely on color alone.
7. Validate syntax and renderer compatibility as practical, especially for Azure DevOps and newer Mermaid diagram types.

## Output

- Diagram code or targeted doc edits
- Placement recommendation when doc order matters
- Renderer compatibility notes
- Sources/evidence behind the diagram
- Checks run or skipped

## Guardrails

- Do not add diagrams that repeat obvious prose.
- Do not invent systems, dependencies, ownership, data flows, or states.
- Keep broad overviews small; split dense diagrams into focused views.
- Prefer portable Mermaid unless the target renderer is known.

## References

- Read `../../references/diagrams/diagrams.md` whenever Mermaid syntax, supported diagram types, Azure DevOps compatibility, edge labels, or visual polish matters.
