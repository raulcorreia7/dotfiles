# Coding

## Core Approach
- Readability > Maintainability > Performance
- Prefer simple, explicit, boring solutions over cleverness
- Keep one concept per function, file, or module when practical
- Preserve local patterns unless they are clearly broken or inconsistent
- If a reviewer cannot explain the change in one pass, refactor

## Scope Discipline
- Stay in scope
- Do not change unrelated code unless explicitly asked
- Remove dead code or stale abstractions when they are clearly in scope
- Do not expand scope for opportunistic cleanup without approval

## Modules and Abstractions
- Prefer one concern per module
- Keep control flow flat with guard clauses and early returns
- Start concrete; introduce interfaces at real boundaries or proven variability points
- Abstract on the third repetition unless a domain boundary or clear risk justifies earlier extraction
- Avoid speculative wrappers and broad utility layers

## Function and API Design
- Make non-trivial inputs, outputs, and failure modes explicit
- Keep one abstraction level per function
- Avoid magic booleans in APIs; prefer named options or enums
- Avoid magic numbers, strings, and sentinels in domain logic
- Public APIs should use named contracts for non-trivial input/output shapes
- Keep one absence model per field unless protocol constraints require otherwise
- Avoid assertion-based casts for payload shaping; build typed values directly
- Prefer schema validation for external or untrusted input

## Naming
- Functions are verbs
- Variables are nouns
- Booleans are predicates (`isX`, `hasX`, `shouldX`)
- Types and classes use domain nouns
- Avoid shorthand names in non-trivial code when explicit names improve clarity
- Files and modules should be named by primary concern

## Dependencies and Configuration
- Prefer standard library and existing project dependencies first
- Add dependencies only for clear net value now
- Prefer existing project versions by default; upgrade only when required, requested, or clearly justified
- Document rationale for new dependencies and significant version changes
- Treat config as environment-specific or deploy-varying; treat constants as stable domain or protocol invariants
- Validate config once at startup and pass it explicitly through boundaries
- Avoid hardcoded environment assumptions and hidden dependencies

## State, Errors, and Logging
- Prefer immutable data by default; isolate mutable state
- Validate inputs early and fail fast with actionable errors
- Never swallow errors silently
- Pass dependencies explicitly; avoid hidden globals
- Keep domain logic pure where practical
- Logs should be high-signal and operationally useful
- Prefer structured logs where practical and never log secrets or sensitive data
- Keep debug and trace logging disabled by default and gated by config

## Review Quality Bar
- Behavior changes include tests at the appropriate level
- Bug fixes include a regression test
- Changes should work end-to-end for the intended scope
- Do not introduce new warnings in changed files
- Comments explain why, not what
- Risky changes include migration and rollback notes
- Run dependency vulnerability checks when dependencies or lockfiles change
