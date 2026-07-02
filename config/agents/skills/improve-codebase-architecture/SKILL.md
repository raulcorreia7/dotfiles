---
name: improve-codebase-architecture
description: "Manual. Use only when explicitly invoked to scan a codebase for deepening opportunities, produce a visual report, and grill the selected candidate before planning implementation."
---

# Improve Codebase Architecture

## Job

Find high-leverage opportunities to deepen modules: smaller interfaces, better seams, more locality, and stronger testability.

Inspired by Matt Pocock's `improve-codebase-architecture`; adapted for generic team use.

## Steps

1. Read `CONTEXT.md`, `CONTEXT-MAP.md`, and relevant ADRs when present.
2. Use `$codebase-design` vocabulary: module, interface, implementation, depth, seam, adapter, leverage, locality.
3. Explore organically across source, tests, callers, docs, scripts, build config, and dependency direction.
4. Look for real friction:
   - understanding one concept requires bouncing through many shallow modules;
   - callers duplicate rules that belong behind one interface;
   - tests reach past the useful seam;
   - adapters exist for hypothetical variation only;
   - ADRs hide now-costly trade-offs.
5. Apply the deletion test: if deleting the module only moves its complexity to callers, it was earning its keep; if nothing concentrates, it is likely shallow.
6. Rank candidates by impact, confidence, blast radius, and validation path.
7. Produce a visual report. Prefer a temp HTML report for broad scans; use Markdown when the user wants terminal-only output.
8. Ask which candidate to explore.
9. For the selected candidate, run `$grill-with-docs` before implementation planning.

## Output

For each candidate:

- Files/modules.
- Problem.
- Proposed direction.
- Benefits in locality, leverage, and testability.
- Before/after shape or diagram.
- Recommendation strength: `Strong`, `Worth exploring`, or `Speculative`.
- Risks and verification.

Final:

- Top recommendation.
- Report path if a file was written.
- Question: which candidate to explore?

## Guardrails

- Do not edit production code from this skill.
- Do not propose abstractions before proving current friction.
- Do not contradict ADRs silently; call out real friction before reopening a decision.
- Do not reward layer count, coverage percentage, line reduction, or abstraction count by itself.
- Do not write HTML into the repo unless the user asks; use the OS temp directory by default.
