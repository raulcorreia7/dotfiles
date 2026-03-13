---
description: Coordinate multi-agent workflows
agent: plan
subtask: false
---

## Purpose

Execute tasks from current plan context. `/plan` creates tasks; this runs them.

## Usage

- `/orchestrate` — Run tasks from current plan context (no file needed)
- `/orchestrate file:<slug>` — Load and run from `docs/plans/slug-*.md`

## Process

1. **Clarify** — Restate goal, constraints, success signals
2. **Grid** — List tasks: ID | Objective | Agent | Status
3. **Delegate** — One task at a time to appropriate agent
4. **Verify** — Check completion; simplify if confused
5. **Escalate** — On 2 failures or scope creep
6. **Synthesize** — Summary of done work and residual risks

## Delegation

| Task Type | Agent |
|-----------|-------|
| Implementation | build |
| Review | review |
| Commit | commit |
| Docs | docs |

## Principles

- One task at a time
- Clear scope per delegation
- Human-first instructions
- Update grid as tasks complete

## Guardrails

- Don't implement; delegate
- Ask before proceeding if blocked
- Preserve command independence
