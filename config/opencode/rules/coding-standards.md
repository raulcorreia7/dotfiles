# Coding Standards

## Core Priorities
- Readability is non-negotiable: code must be a pleasure to read and review
- Proper formatting and indentation are required, not optional
- Keep code intuitive and obvious: the next reader should grasp it instantly
- Prefer clear code over clever code
- Avoid complexity: simplify before extending
- Best judgment, no hardcoding

## Cognitive Load (Non-Negotiable)
- One concept per chunk: function, file, module
- Reader predicts behavior before reading implementation
- If you have to re-read it, rewrite it
- Hide irrelevant details; reveal relevant ones through naming
- No mental gymnastics: keep the happy path obvious and flat

## State Management
- State is a liability: minimize it
- Mutable state must be explicit and localized
- Complex state = state machine (no implicit state spread across flags)
- Side effects live at boundaries; core logic stays pure
- Prefer data transformation over state mutation

## Coupling
- Cohesion within; isolation between
- Depend on abstractions; never on concretions
- If changing A breaks B, they're too coupled
- Shared utilities are either trivial or wrong

## Error Handling
- Errors are values: handle them like any other data
- No silent failures: every error path is explicit
- Recoverable errors vs bugs: know the difference
- Context is mandatory: what, where, why it failed
- Exceptions or Result types: pick one, be consistent
- Actionable errors or don't bother

## Craftsmanship
- Improve clarity with every change, not just checkboxes
- Keep the happy path obvious; isolate edge-case handling
- Prefer minimal moving parts and deletable code
- If a change is hard to explain in 2-3 bullets, simplify

## Senior Engineering Guardrails
- Model domain concepts explicitly in names and APIs
- Make invariants explicit with validation and types/schemas
- Prefer explicit contracts over implicit behavior
- Choose proven, boring solutions unless novelty has measurable payoff
- Surface failures with actionable context; avoid silent catches

## Enforcement Model
- Core rules are strict
- Style rules are flexible when readability improves
- Deviations require rationale in review notes or commit/PR body

## Existing Patterns
- Match local naming, structure, and abstraction level
- Deviate only when the current pattern is broken/inconsistent
- Core-rule exceptions require explicit approval

## Complexity and Modules
- No hard limits on function length/nesting/params; refactor when readability drops
- Keep control flow flat with guard clauses and early returns
- Abstract on the 3rd repetition unless risk/domain boundary justifies earlier
- Prefer one concern per module; split when reasons to change diverge

## Function and API Design
- Non-trivial functions should make inputs, outputs, and failure modes explicit
  (types/schemas/signatures)
- Keep one abstraction level per function; do not mix orchestration and low-level details
- Avoid magic booleans in APIs; prefer named options or enums
- Validate untrusted data at boundaries; keep internals on trusted shapes
- Never swallow errors; return/throw with actionable context (operation/entity/id)
- Prefer immutable transforms in core logic; isolate shared mutable state
- Delete before add: remove dead paths and stale abstractions when touching code
- Avoid utility sprawl; keep helpers scoped to a domain/module concern
- Treat heavy test mocking as a design smell; simplify boundaries
- Readability gate: if a reviewer cannot explain the change in one pass, refactor

## Dependency Addition
- Prefer standard library and existing dependencies first
- Add dependencies only for clear net value now
- Record rationale: problem solved, why existing stack is insufficient,
  maintenance/security/license fit, runtime/build impact
- Keep versions explicit; rely on lockfiles
- Remove unused dependencies promptly

## Library, Framework, and Tool Selection
- Prefer battle-tested, maintained options with strong docs
- Avoid reinventing the wheel unless explicitly requested or truly required
- Prefer latest stable versions when compatibility/migration cost is reasonable
- Verify version and maintenance status via official docs/registries/release notes
  and MCP research tools when needed
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

## Naming
- Functions: verbs
- Variables: nouns
- Booleans: predicates (`isX`, `hasX`, `shouldX`)
- Types/classes: domain nouns
- Interfaces/protocols: capability/role names
- Files/modules: primary concern; avoid broad `utils/helpers/misc` unless scoped
- Follow language/framework casing and naming conventions

## Error Handling and Side Effects
- Validate inputs early; fail fast with specific, actionable errors
- Use language-idiomatic error patterns
- Keep domain logic pure where practical
- Isolate I/O/network/db/filesystem/env/time/random at boundaries
- Pass dependencies explicitly; avoid hidden globals

## Comments and API Docs
- Comment why, not what
- Comment only non-obvious rationale, constraints, or side effects
- Public APIs include brief contract docs (inputs, outputs, errors)

## Anti-Patterns (Non-Negotiable)
- God objects
- Deep nesting
- Magic numbers
- Hidden dependencies
- Hardcoded environment assumptions/values
- Premature abstraction

## Testing (Unit / Integration / E2E)
- Use a test pyramid: many unit tests, some integration tests, few e2e tests
- Unit: test domain/business logic in isolation; keep tests fast and deterministic
- Integration: test module/adaptor interactions and boundary contracts
  (DB/HTTP/queue/files)
- E2E: test highest-value user/business flows and critical failure paths
- For feature work, test happy paths and validation/failure paths
- Keep tests highly relevant to the changed behavior; avoid unrelated test churn
- Bug fixes must include a regression test in the same change
- Prefer real collaborators in integration tests; mock only true externals
- Keep e2e suites small and stable; optimize for release-risk coverage
- Use Arrange -> Act -> Assert; each test should assert one behavior
- Name tests by behavior and expected outcome
- Control time/randomness and test data; avoid sleeps and flaky timing
- Heavy mocking is a design smell; simplify boundaries when tests get brittle

## Formatting, Linting, and Style
- Run formatter before commit; formatter output is source of truth
- Fix linter errors; do not introduce new warnings in changed files
- Prefer explicit names and readable multi-line code
- Keep lines readable (about 80-100 chars when practical)
- Keep indentation, spacing, imports, and quote/bracket style consistent
- Avoid style-only churn in behavior-focused changes
