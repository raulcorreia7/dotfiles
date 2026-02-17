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
- Value objects over primitives
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

## Domain Modeling
- Use domain language in modules, types, and APIs
- Make invariants explicit in code and tests
- Translate transport/storage concerns at boundaries

## Evolution and Compatibility
- Prefer backward-compatible interface changes
- Breaking changes require migration notes and rollback options
- Use staged rollout for high-risk changes when feasible

## Decision Checklist
- Is this required now or speculative?
- Can we simplify and add later?
- What is the cost of being wrong?
- What is the fastest safe validation?

## Preferred Patterns
- Composition over inheritance
- Explicit over implicit behavior
- Idempotent operations where relevant

## Anti-Patterns
1. Premature abstraction
2. Distributed monolith without clear boundaries
3. Over-engineered data models
4. Optimizing edge cases before core path
5. Hardcoded environment assumptions
6. Hidden infrastructure in domain logic

## Documentation
- Document why decisions were made
- Document responsibilities and data flow
- Keep implementation details in code
