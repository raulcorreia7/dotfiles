---
name: refactor
description: "Use when the user explicitly asks to refactor, simplify, reorganize, reduce complexity, or preserve behavior while changing code shape. Do not use for incidental cleanup."
---

# Refactor

## Job

Improve structure while preserving observable behavior and agreed scope.

## Steps

1. Confirm target, pain, desired shape, non-goals, preserved behavior, stop condition, and safety net.
2. Inspect behavior, tests, public interfaces, callers, data shape, compatibility, and local patterns.
3. Align before cross-module, API, ownership, layout, naming, or broad architecture moves.
4. Use small behavior-preserving steps.
5. Preserve public contracts, data shape, runtime behavior, and compatibility unless approved.
6. Validate behavior at the narrowest useful level.

## Output

- Structural improvement
- Behavior-preservation proof
- Checks/results
- Assumptions/deviations
- API or compatibility impact
- Follow-ups

## Guardrails

- Do not add features, dependencies, formatting churn, or unrelated cleanup.
- Do not optimize for line count.
- Add abstractions only when they reduce duplication, clarify boundaries, or lower real complexity.

## References

- Read `../../references/languages/languages.md` and the matching language reference when refactoring language-specific code.
