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

## Function and API Design
- Non-trivial functions should make inputs, outputs, and failure modes explicit (types/schemas/signatures)
- Keep one abstraction level per function; do not mix orchestration and low-level details
- Avoid magic booleans in APIs; prefer named options or enums
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

## Comments and API Docs
- Comment why, not what
- Comment only non-obvious rationale, constraints, or side effects
- Public APIs: document inputs, outputs, errors, and invariants
- Hot paths: document performance characteristics and trade-offs
- Concise and clear over verbose noise: if it doesn't add value, delete it
