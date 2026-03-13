# Coding Practices

## Existing Patterns
- Match local naming, structure, and abstraction level
- Deviate only when the current pattern is broken/inconsistent
- Core-rule exceptions require explicit approval

## Complexity and Modules
- No hard limits on function length/nesting/params; refactor when readability drops
- Keep control flow flat with guard clauses and early returns
- Abstract on the 3rd repetition unless risk/domain boundary justifies earlier
- Prefer one concern per module; split when reasons to change diverge
- Keep internals concrete by default; add interfaces at boundaries and real variation points

## Function and API Design
- Non-trivial functions should make inputs, outputs, and failure modes explicit (types/schemas/signatures)
- Keep one abstraction level per function; do not mix orchestration and low-level details
- Avoid magic booleans in APIs; prefer named options or enums
- Avoid magic numbers/strings/sentinel literals in domain logic; use named constants or domain types
- Prefer unified builders with typed options over proliferating specialized factory functions; use `build(name, type?, options?)` instead of `buildX`, `buildY`, `buildZ` to avoid combinatorial explosion
- Start concrete; extract interface when a second implementation is real or repetition warrants it
- Prefer small consumer-defined interfaces over broad speculative abstractions
- Public APIs should use named contracts for non-trivial input/output shapes; avoid inline structural return/input types
- Define concrete return contracts and reuse them across implementation, callers, and tests
- Use one absence model per field in contracts (optional or nullable), not both unless protocol constraints require it
- Avoid assertion-based casts for payload shaping; build typed values directly
- Avoid returning untyped inline lambdas from public APIs; prefer named handlers or typed function aliases
- In application code, prefer schema/validator libraries over manual runtime shape checks
- Manual runtime checks are acceptable in scripts, tiny local checks, or measured hot paths with rationale
- Never swallow errors; return/throw with actionable context (operation/entity/id)
- Prefer immutable transforms in core logic; isolate shared mutable state
- Delete before add: remove dead paths and stale abstractions when touching code
- Avoid utility sprawl; keep helpers scoped to a domain/module concern
- Treat heavy test mocking as a design smell; simplify boundaries
- Respect user-configured policy/modes; avoid hidden force flags except explicit, documented recovery paths
- Readability gate: if a reviewer cannot explain the change in one pass, refactor

## Naming
- Functions: verbs
- Variables: nouns
- Booleans: predicates (`isX`, `hasX`, `shouldX`)
- Types/classes: domain nouns
- Interfaces/protocols: capability/role names
- Return contracts: `*View` for reads, `*Result` for operations, `*Item` for list entries (unless domain language suggests better names)
- Avoid shorthand names in non-trivial code (`kv`, `ctx`, `req`, `res`) when explicit names improve clarity
- For map/object pairs, prefer `key` and `value` over `k`/`v`
- Files/modules: primary concern; avoid broad `utils/helpers/misc` unless scoped
- Follow language/framework casing and naming conventions

## Immutability and State
- Prefer immutable data and const-correctness by default
- Use `const`/`final`/`val` for variables that don't need reassignment
- Mutability should be intentional, not accidental
- Isolate mutable state; keep transformations pure where possible

## Error Handling and Side Effects
- Validate inputs early; fail fast with specific, actionable errors
- Use language-idiomatic error patterns
- Keep domain logic pure where practical
- Pass dependencies explicitly; avoid hidden globals

## Logging and Observability
- Logs should be high-signal and operationally useful; log events, decisions, and failures, not step-by-step noise
- Prefer structured logs with stable keys and correlation identifiers (request/job/trace id when available)
- Keep debug/trace logging disabled by default; enable via config/flag without code edits
- Do not spam logs in loops/hot paths; use sampling/rate-limiting when verbose diagnostics are necessary
- Never log secrets, tokens, or sensitive personal data; redact or omit sensitive fields
- Error logs must include actionable context (operation, entity, id/correlation id, failure reason)

## Comments and API Docs
- Comment why, not what
- Comment only non-obvious rationale, constraints, or side effects
- Public APIs: document inputs, outputs, errors, and invariants
- Hot paths: document performance characteristics and trade-offs
- Concise and clear over verbose noise: if it doesn't add value, delete it
