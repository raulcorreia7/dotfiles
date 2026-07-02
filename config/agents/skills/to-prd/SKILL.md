---
name: to-prd
description: "Manual. Use only when explicitly invoked to synthesize the current conversation and repo context into a PRD with no broad interview, then optionally publish it to the issue tracker."
---

# To PRD

## Job

Turn the current conversation into a concise PRD using what is already known. Do not run a broad interview.

Inspired by Matt Pocock's `to-prd`; adapted for provider-agnostic teams.

## Steps

1. Synthesize from the current conversation first; do not interview. Ask only when a missing answer changes scope, risk, test seams, or publishability.
2. Inspect repo context only when it changes seams, existing behavior, domain vocabulary, or test strategy.
3. Read `CONTEXT.md`, `CONTEXT-MAP.md`, and ADRs when present.
4. Identify the highest useful test seam; prefer existing public interfaces over new seams.
5. Confirm seams with the user if they materially shape implementation.
6. Preserve source links, domain terms, and citations when the source material is documentation or knowledge-catalog work.
7. Write an extensive user-story list that covers the feature from the user's perspective.
8. Write the PRD using the output shape below.
9. Publish to the configured issue tracker only after explicit approval; otherwise provide copy-pasteable Markdown or a PRD file when requested.

## Output

- Problem statement.
- Solution.
- Long numbered user-story list.
- Implementation decisions.
- Testing decisions.
- Out of scope.
- Further notes.
- Publish target or skipped publishing reason.

## Guardrails

- Do not invent acceptance criteria, ownership, or tracker configuration.
- Do not publish, label, assign, or mutate the issue tracker without explicit approval.
- Do not include stale-prone file paths or code snippets unless they encode a prototype decision precisely.
- Do not over-interview; this skill is synthesis, not grilling.
- Use `$grill-with-docs` first when the idea is still under-specified.

## References

- Read `../../references/okf/okf.md` when synthesizing PRDs for documentation IA, references, folder structure, or knowledge-catalog work.
