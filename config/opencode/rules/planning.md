# Planning Rules

## When to Plan
Plan when a task:
- touches more than 3 files
- changes architecture or data model
- adds dependencies
- involves more than 2 stakeholders

Skip planning for isolated single-file fixes and routine maintenance.

## Task Size
- Target 1-4 hour tasks
- Split until each task has one clear outcome

## Task Template
Each task defines:
1. Objective
2. Context (files/patterns/constraints)
3. Acceptance criteria
4. Dependencies (hard vs soft)

## Prioritization
- Default order: Impact -> Urgency -> Risk
- Use effort as tie-breaker, not primary driver
- Prioritize work that de-risks or unblocks others

## Risk-First Execution
- Resolve highest uncertainty first (spike/prototype/targeted test)
- De-risk critical path before polish
- Define rollout and rollback for high-risk work

## Definition of Done
- Acceptance criteria met and scope respected
- Tests, lint, and build pass with no new warnings
- Behavior/contract changes include tests and docs
- Medium/high-risk changes include rollback notes
- No orphan TODO/HACK markers

## Estimation
- Use ranges, not single-point estimates
- Add 20-30% buffer for unknowns
- Track estimate vs actual to calibrate

## When Plans Change
1. Reassess goal and scope
2. Communicate impact
3. Document rationale
4. Capture lessons learned
