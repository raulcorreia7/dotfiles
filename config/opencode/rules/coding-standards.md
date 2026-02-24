# Coding Standards

## Dependency Addition
- Prefer standard library and existing dependencies first
- Add dependencies only for clear net value now
- Record rationale: problem solved, why existing stack is insufficient, maintenance/security/license fit, runtime/build impact
- Keep versions explicit; rely on lockfiles
- Remove unused dependencies promptly

## Library, Framework, and Tool Selection
- Prefer battle-tested, maintained options with strong docs
- Avoid reinventing the wheel unless explicitly requested or truly required
- Prefer latest stable versions when compatibility/migration cost is reasonable
- Verify version and maintenance status via official docs/registries/release notes and MCP research tools when needed
- If not using latest stable, document the pragmatic reason

## Config vs Constants
- Config: environment-specific, secret, deploy-varying, and tunable values
- Constants: stable domain/protocol invariants
- Inline literals only when obvious and local (`0`, `1`, `""`, `true`)
- Validate config once at startup and pass explicitly through boundaries

## TODO/HACK Hygiene
- No orphan TODO/HACK markers
- Every TODO/HACK includes owner or issue reference
- TODOs include intent and exit condition
- HACKs include constraint and removal condition

## Anti-Patterns (Non-Negotiable)
- Deep nesting
- Magic numbers
- Hidden dependencies
- Hardcoded environment assumptions/values
- Premature abstraction

## Formatting, Linting, and Style
- Run formatter before commit; formatter output is source of truth
- Fix linter errors; do not introduce new warnings in changed files
- Prefer explicit names and readable multi-line code
- Keep lines readable (about 80-100 chars when practical)
- Keep indentation, spacing, imports, and quote/bracket style consistent
- Avoid style-only churn in behavior-focused changes
