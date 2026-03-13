# Code Review

## Required Quality Gate
- Change works end-to-end
- Tests, lint, and build pass
- No new warnings in changed files
- Behavior changes include tests
- Test level matches change scope (unit/integration/e2e)
- Feature changes include happy-path and validation/failure-path tests
- Bug fixes include a regression test
- Contract/config changes include docs

## Core Review
- Naming and boundaries are clear
- Error handling is explicit and actionable
- Edge cases and failure paths are covered
- No dead code, stray debug logging/prints, or commented-out blocks

## Security Baseline (Required)
- Validate untrusted input at boundaries (API/CLI/files/events)
- Do not expose secrets in code, logs, errors, commits, or docs
- Run dependency vulnerability checks; at minimum when deps/lockfiles change

## Craftsmanship Lens
- Core change is understandable in one pass
- Complexity is reduced or contained
- Domain invariants are explicit in code and tests
- Module/API contracts are clear; compatibility is considered
- Interface additions are justified by boundaries or real variability (not speculative wrappers)
- No unexplained magic literals in changed code (numbers/strings/sentinels)
- Boundary concerns are handled where relevant (timeouts/retries/idempotency)
- Logs and errors help debugging and operations
- Logging is high-signal, structured where practical, and free of secrets/sensitive data
- Debug/trace logging is gated behind config/flags and disabled by default
- Risky changes include migration and rollback notes

## Nitpicks (Fix If Cheap)
- Formatting consistency
- Simplify complex conditionals
