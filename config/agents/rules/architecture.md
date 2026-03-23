# Architecture

## First Principles
- Solve the problem at hand
- Defer irreversible decisions when uncertainty is still high
- Optimize for deletability
- Keep designs readable, pragmatic, and easy to explain
- Choose the fastest safe validation for uncertain decisions

## Boundaries and Layers
- Layers flow inward: Interface -> Application -> Domain -> Infrastructure
- Domain logic knows nothing about infrastructure details
- Application coordinates workflows; domain owns business rules
- Side effects live at boundaries and adapters
- Dependencies should be explicit and directional

## Interfaces and Abstractions
- Start concrete inside modules by default
- Introduce interfaces at real seams: external systems, lifecycle boundaries, or proven variability points
- Prefer small consumer-owned contracts over broad producer-owned abstractions
- Do not add interface layers that only rename a concrete implementation
- Composition is preferred to inheritance-like hierarchies

## Structural Invariants
- No circular dependencies
- No god modules
- No hidden dependencies or action at a distance
- No primitive obsession when domain concepts deserve types
- No deeply nested control flow when guard clauses or extraction would make intent clearer

## Ownership and State
- Assign a single owner for each lifecycle concern such as install, update, cleanup, lock, or restore
- State is a liability: minimize it
- Mutable state must be explicit and localized
- If state becomes complex, model it explicitly instead of spreading it across flags
- When multiple runtime sources exist, define one precedence order and centralize source resolution

## Risk Management
- Breaking changes require migration notes and rollback options
- High-risk work should define rollout and rollback before implementation
- If startup timing can break correctness, persist a startup contract instead of relying on late initialization
- Changes to source precedence, contracts, or ownership boundaries require explicit rationale

## Diagrams and Documentation
- Diagrams should reflect real dependency direction, ownership, and boundaries
- Prefer boundary-focused, high-signal diagrams over implementation-detail diagrams
- Use multiple small diagrams when one dense diagram hides intent
- Update architecture diagrams when boundaries or critical flows change

## Anti-Patterns
- Premature abstraction
- Distributed monoliths without real boundaries
- Over-engineered data models
- Optimizing edge cases before the core path
- Hardcoded environment assumptions
- Hidden infrastructure in domain logic
