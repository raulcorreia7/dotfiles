---
description: Repository-wide code review for architecture health, tech debt, and standards compliance
agent: plan
subtask: false
---

## Purpose

Comprehensive codebase assessment beyond current changes. Informs technical debt prioritization, architecture decisions, and refactoring planning.

## Usage

- `/review-thorough` — Start guided Q&A then full review
- `/review-thorough <path>` — Focus on specific directory/module

## Output

1. **Q&A Phase** — Scope definition and focus areas
2. **Analysis** — Systematic exploration with rule citations
3. **Findings** — Interactive drill-down by severity and category
4. **Optional Report** — Save as `docs/audit-YYYY-MM-DD.md`

## Phase 1: Q&A

Ask the user these questions before analysis:

### Focus Areas (multi-select)
Which aspects to prioritize?
- **Architecture & structure** — Coupling, cohesion, layer boundaries, module contracts
- **Robustness & safety** — Error handling, validation, edge cases, failure paths
- **Maintainability** — Code smells, complexity, readability, naming
- **Standards compliance** — Conformance to rules/*.md

### Scope
- Review entire codebase or specific paths/modules?
- Any directories to exclude beyond auto-excluded?

### Depth
- **Breadth-first** — High-level overview, then drill into areas user chooses
- **Depth-first** — Deep analysis of critical paths first

### Context (if not obvious)
- What is this codebase's primary purpose?
- Any known pain points or areas of concern?
- Recent or planned major changes?

## Phase 2: Auto-Exclusions

Exclude from analysis:
- `node_modules/`, `vendor/`, `venv/`, `.venv/`
- `dist/`, `build/`, `target/`, `out/`
- `.git/`, `.github/` (workflows OK if reviewing CI)
- `__pycache__/`, `*.pyc`, `.pytest_cache/`
- `coverage/`, `.nyc_output/`
- Lock files: `package-lock.json`, `yarn.lock`, `Cargo.lock`, `poetry.lock`
- Generated files: `*.generated.*`, `*.gen.*`

Ask user to confirm or add exclusions.

## Phase 3: Standards Loading

Load standards from:
1. `AGENTS.md` (or path provided by user)
2. `rules/*.md` or user-specified rules directory

Reference specific rules in findings using format: `rules/architecture.md#Structural Invariants`

## Phase 4: Analysis

For each focus area selected, analyze:

### Architecture & Structure
- Circular dependencies
- Layer boundary violations (domain knows about infrastructure?)
- God modules/classes
- Hidden dependencies
- Cohesion within modules
- Coupling between modules
- Missing abstractions (3rd repetition not abstracted?)

### Robustness & Safety
- Input validation at boundaries
- Error handling (actionable errors vs swallowed)
- Edge cases covered
- Failure paths tested
- Secrets in code/logs/errors
- Idempotency where needed

### Maintainability
- Deep nesting (>2 levels)
- Long functions (readability check)
- Magic numbers/strings
- Unclear naming
- Dead code
- Commented-out blocks
- Complex conditionals
- Primitive obsession

### Standards Compliance
- Match patterns from existing codebase
- Conformance to rules/*.md
- Test coverage expectations
- Documentation requirements

## Phase 5: Findings Output

Present findings interactively:

### Format
```
[Severity] <title>
Path: file:line
Rule: rules/<file>.md#<section>
Issue: <what's wrong>
Impact: <why it matters>
Fix: <how to address>
```

### Severity Levels
- **Critical** — Security, data loss, correctness issues
- **Major** — Architecture violations, maintainability risks
- **Minor** — Style, minor improvements
- **Nit** — Polish items

### Interactive Flow
1. Present summary by category and severity
2. User selects areas to explore in detail
3. Show specific findings with code context
4. User can ask follow-up questions
5. Continue until user satisfied

## Phase 6: Optional Report

Ask at end: "Generate audit report?"

If yes, create `docs/audit-YYYY-MM-DD.md`:

```markdown
# Codebase Audit — YYYY-MM-DD

## Scope
- Focus areas: [selected areas]
- Paths reviewed: [paths]
- Exclusions: [excluded paths]

## Summary
- Critical: X
- Major: Y
- Minor: Z
- Nit: N

## Findings by Category

### Architecture
[Finding details]

### Robustness
[Finding details]

[...]

## Recommendations
[Prioritized action items]

## Standards Referenced
- rules/architecture.md
- rules/code-review.md
[...]
```

## Principles

- Reference specific rules — every finding cites a standard
- Actionable — every issue has a suggested fix
- Evidence-based — cite code locations
- Prioritize by impact — not all issues equal
- User-driven — let user steer depth and focus
