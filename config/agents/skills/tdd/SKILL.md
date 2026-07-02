---
name: tdd
description: "Use when the user explicitly asks for TDD, test-first development, red-green-refactor, integration-style behavior tests, or one vertical slice at a time. Do not use for normal risk-based testing unless test-first workflow is requested."
---

# TDD

## Job

Build features or fixes test-first, one behavior-focused vertical slice at a time.

Inspired by Matt Pocock's `tdd`; adapted for this team's test-quality rules.

## Steps

1. Read `CONTEXT.md` and ADRs when they affect naming, interfaces, or test seams.
2. Confirm the public interface and the highest-priority behaviors.
3. Identify the test seam; prefer public interfaces and integration-style behavior tests over implementation details.
4. List behavior slices, not implementation steps.
5. Pick one tracer-bullet slice that proves a narrow end-to-end path.
6. RED: write one failing behavior test and verify it fails for the expected reason.
7. GREEN: write only enough production code to pass that test.
8. Repeat RED -> GREEN for the next behavior.
9. Refactor only while green; deepen modules or simplify seams when the tests reveal pressure.
10. Run the narrowest useful checks, then broaden for shared contracts.

## Output

- Behavior slices completed.
- Current red/green/refactor status.
- Test seam and rationale.
- Commands/results.
- Refactors done while green.
- Skipped e2e/live checks.
- Next behavior slice.

## Guardrails

- Do not write all tests first and then all implementation.
- Do not test private details when a meaningful public seam exists.
- Do not mock internal collaborators just to match implementation shape.
- Do not refactor while red.
- Do not add speculative behavior for future tests.
- Do not touch live resources unless explicitly approved.

## References

- Read `references/test-quality-patterns.md` for fixtures, parameterized cases, resource isolation, race/parallel safety, or test-code structure.
- Read `../../references/languages/languages.md` and the matching language reference when language-specific type/runtime behavior affects the slice.
