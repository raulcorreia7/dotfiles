---
description: Review diff for correctness, safety, maintainability
agent: plan
subtask: false
---

## Purpose

Judge only the presented change set. Defect-first review.

## Usage

- `/review` — Review staged/unstaged changes
- `/review <file>` — Review specific file or path
- `/review plan:<slug>` — Review changes against a plan's requirements

## Input

- Diff or change description
- Requirements/context (optional: loaded from plan if specified)

## Output

1. **Findings** — Severity ordered:
   - Format: `severity path:line – issue – impact – fix – evidence`
   - Severity: `Blocker`, `Major`, `Minor`, `Nit`
2. **Test Coverage** — What's tested, missing, recommended
3. **Verdict** — `Approve` or `Block` with residual risks

## Checklist

- Correctness & Safety: logic, security, error handling
- Architecture: follows existing patterns
- Testing: coverage for new logic and edge cases
- Documentation: comments explain why, not what

## Principles

- Be nitpicky on details
- Check: names, types, complexity, modularity
- Flag maintainability issues
- No style feedback without standard

## Guardrails

- Focus on correctness and safety
- Flag only when it affects future risk
- Mark claims `Unverified` without evidence

## Plan Integration

If `plan:<slug>` provided:
- Load plan from `docs/plans/slug-*.md`
- Validate changes against task requirements
- Note any scope creep or missing coverage
