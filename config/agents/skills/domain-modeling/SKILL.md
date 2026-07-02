---
name: domain-modeling
description: "Use when building or updating project domain language, ubiquitous terms, CONTEXT.md, context maps, or ADRs, or when another skill needs to maintain the domain model inline."
---

# Domain Modeling

## Job

Actively sharpen domain language and record durable decisions as they crystallize.

Inspired by Matt Pocock's `domain-modeling`; adapted for generic team repos.

## Artifacts

- `CONTEXT.md`: glossary and domain language only.
- `CONTEXT-MAP.md`: maps multiple contexts in monorepos or multi-domain repos.
- `docs/adr/`: hard-to-reverse, surprising, trade-off-driven decisions.
- Domain indexes or reference pages only when they improve navigation across several durable concepts.

## Steps

1. Read existing `CONTEXT.md`, `CONTEXT-MAP.md`, and ADRs before editing.
2. Challenge conflicting terms immediately.
3. Sharpen fuzzy or overloaded words into canonical terms.
4. Stress-test terms with concrete scenarios and edge cases.
5. Cross-check user claims against code when code can confirm or contradict the domain model.
6. Update `CONTEXT.md` inline when a term is resolved.
7. Create context files lazily only when there is something real to write.
8. Use concept-sized sections or pages, explicit links, and citations when domain knowledge spans multiple docs or depends on external sources.
9. Offer ADRs only when the decision is hard to reverse, surprising without context, and trade-off-driven.

## Output

- Terms added/changed.
- Conflicts resolved.
- Scenarios used to sharpen language.
- ADRs created or proposed.
- Open terminology questions.
- Files changed.

## Guardrails

- Do not put implementation details, specs, scratch notes, runbooks, or issue status in `CONTEXT.md`.
- Do not invent business facts or ownership.
- Do not create ADRs for obvious, reversible, or temporary choices.
- Do not batch known domain updates until the end when inline capture is safer.
- Preserve existing context layout and numbering.

## References

- Read `../../references/okf/okf.md` when domain work creates or reorganizes durable docs, indexes, references, or knowledge catalogs.
