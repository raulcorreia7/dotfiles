---
name: codebase-design
description: "Use when designing or improving module interfaces, seams, testability, deep modules, adapters, or AI-navigable code structure, or when another skill needs shared codebase design vocabulary."
---

# Codebase Design

## Job

Design deep modules: substantial behavior behind a small interface, placed at a clean seam and testable through that seam.

Inspired by Matt Pocock's `codebase-design`; adapted for Goldilocks-lean engineering.

## Vocabulary

Use these terms consistently:

- Module: anything with an interface and implementation.
- Interface: everything callers must know: types, invariants, ordering, errors, config, and performance expectations.
- Implementation: what sits inside the module.
- Depth: leverage at the interface; more behavior per unit of interface a caller must learn.
- Seam: where behavior can vary without editing the caller.
- Adapter: concrete implementation that satisfies an interface at a seam.
- Leverage: capability callers gain from the module.
- Locality: change, bugs, and verification concentrate in one place.

## Steps

1. Identify the behavior, callers, tests, and current interface.
2. Ask whether the interface is smaller than the behavior it unlocks.
3. Apply the deletion test: would removing the module concentrate complexity in callers or make complexity disappear?
4. Put seams where real variation or testability pressure exists.
5. Prefer one stable public interface over many shallow helper seams.
6. Accept dependencies instead of creating hardwired ones when testability requires it.
7. Return results rather than producing hidden side effects when practical.
8. Compare at least two interface shapes for important modules.
9. Choose the design with best readability, locality, leverage, and verification path.

## Output

- Current module/interface shape.
- Proposed seam and interface.
- Why it is deeper.
- Trade-offs.
- Test surface.
- Migration path.
- Rejected alternatives.

## Guardrails

- Do not add interfaces for hypothetical variation.
- Do not treat line count as depth.
- Do not split modules only to satisfy style preferences.
- Do not test past the interface unless that reveals the interface is wrong.
- Do not use clever minimalism when a boring local pattern is safer.
