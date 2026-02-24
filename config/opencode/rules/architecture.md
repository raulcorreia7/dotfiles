# Architecture Rules

## First Principles
1. Solve the problem at hand
2. Defer irreversible decisions when uncertain
3. Optimize for deletability
4. Prefer interfaces/contracts over implementations
5. Keep designs readable and pragmatic

## Code Aesthetics
- Flat over nested: guard clauses, early returns
- Small over clever: if it needs a comment, simplify
- Explicit over implicit: no magic, no surprises
- Obvious over clever: the next reader is tired and distracted

## Structural Invariants (Non-Negotiable)
- No circular dependencies
- No god modules
- No action at a distance
- No hidden dependencies
- No primitive obsession: model domain with types
- No nested conditionals past 2 levels: extract or guard

## Pattern Preferences
- Composition over inheritance (pragmatic)
- Value objects over primitives (unless language perf requires otherwise)
- Factory functions over complex constructors
- Strategy over inheritance for varying behavior
- Pure functions over side effects in core logic

## Layer Boundaries
- Layers: Interface -> Application -> Domain -> Infrastructure
- Dependencies point inward only
- Domain knows nothing about infrastructure
- Application orchestrates workflows; domain owns business rules
- Side effects live at boundaries (adapters/infrastructure)
- Validate config once at startup and pass it explicitly

## Component Rules
- Single responsibility
- Explicit dependencies
- Small, focused contracts
- Fail fast with actionable errors

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

## Anti-Patterns
1. God objects
2. Premature abstraction
3. Distributed monolith without clear boundaries
4. Over-engineered data models
5. Optimizing edge cases before core path
6. Hardcoded environment assumptions
7. Hidden infrastructure in domain logic
