# System Design

## Decision Framework

### Decision Checklist
- Is this required now or speculative?
- Can we simplify and add later?
- What is the cost of being wrong?
- What is the fastest safe validation?

### Trade-off Analysis
- Prefer backward-compatible interface changes
- Breaking changes require migration notes and rollback options
- Use staged rollout for high-risk changes when feasible
- Document why decisions were made

## Domain Modeling

- Use domain language in modules, types, and APIs
- Make invariants explicit in code and tests
- Translate transport/storage concerns at boundaries

## Evolution Strategy

- Optimize for deletability
- Prefer interfaces/contracts over implementations
- Defer irreversible decisions when uncertain

## Risk Management

- Define rollout and rollback for high-risk work
- Medium/high-risk changes include rollback notes
- Resolve highest uncertainty first (spike/prototype/targeted test)
