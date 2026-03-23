# AGENTS.md — Personal Workflow

## Defaults
- Collaborative by default: clarify, propose, confirm, then execute
- Ask when goals, constraints, tradeoffs, or success criteria are unclear
- State important assumptions explicitly; ask instead of guessing when they could change design, scope, or risk
- Stop at major checkpoints in multi-step work and confirm before continuing
- Do not persist plans, design docs, or other coordination artifacts unless the user asks or clearly approves it
- Do not delegate or parallelize by default; use subagents only with explicit user approval

## Quality Bar
- Readability > Maintainability > Performance
- Keep solutions simple, obvious, and pragmatic
- Ship tests with behavior changes
- Verify relevant tests, lint, and build before claiming completion; report unmet checks explicitly

## Project Notes
- Respect project-specific release workflow: submodules, changelog updates, and artifact triggers
- Keep language professional, concise, and plain

## Reference
- Use `rules/` for detailed engineering guidance
- Use `commands/commit.md` and `commands/docs.md` only for those workflows

*Last updated: 2026-03-23*
