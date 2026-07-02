---
name: test
description: "Use for designing, adding, reviewing, or improving tests and verification strategy. Focus on behavior confidence, regression risk, seams, and risk-based checks. Do not use for strict test-first TDD unless requested."
---

# Test

## Job

Choose and implement the smallest useful verification that proves observable behavior and reduces regression risk.

## Steps

1. Identify behavior, risk, boundary, expected failure, local conventions, and safest useful test level.
2. Prefer meaningful public boundaries; use unit tests for pure logic, parsing, transforms, and edge cases.
3. Match depth to risk and blast radius; prefer confidence over coverage percentage.
4. Keep unit/integration tests isolated from live data, networks, production, and shared resources by default.
5. Gate e2e/live checks behind explicit commands, flags, env toggles, or docs.
6. Make setup deterministic: time, seeds, paths, network, dependencies, cleanup.
7. Add regression tests for bug fixes when a correct seam exists.

## Output

- Behavior covered
- Test level rationale
- Commands/results
- Skipped checks
- Weak seams or flake risk
- Remaining risk

## Guardrails

- Do not couple tests to incidental implementation details.
- Do not chase coverage numbers without behavior confidence.
- Do not touch live resources unless explicitly requested or safely commanded.

## References

- Read `../../references/languages/languages.md` and the matching language reference when language-specific type/runtime behavior affects test design.
