# Workflow

## Phase Transitions with Quality Gates

### Plan → Build
- Acceptance criteria defined and documented
- Task scope clear and bounded
- Risks identified with mitigation strategies

### Build → Verify
- Code compiles/builds successfully
- Unit tests pass for modified code
- Linting and formatting checks pass
- No debug code or console logs left

### Verify → Complete
- Integration tests pass
- End-to-end tests pass (for user-facing changes)
- Code review approved
- Documentation updated (if behavior changed)

## Progressive Enhancement
- Start with minimal working solution
- Add complexity only when justified
- Verify each step before proceeding
- Prefer small, verifiable changes
