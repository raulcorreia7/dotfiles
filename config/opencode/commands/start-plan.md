---
description: Resume or execute an existing plan
agent: plan
subtask: false
---

## Purpose

Execute an existing plan. Does NOT create plans — use `/plan` first.

## Usage

- `/start-plan <slug>` — Load plan from `docs/plans/slug-*.md`
- `/start-plan` — Use current conversation context (plan discussed above)

## Workflow

1. **Load Context**
   - If slug: find and read `docs/plans/slug-*.md`
   - If no args: use plan discussed in current conversation
   - If neither found: prompt user to run `/plan` first

2. **Sync State**
   - Parse tasks from plan
   - Check what's already done (git log, file state)
   - Update task checkboxes if stale

3. **Execute Loop**
   - Pick next pending task
   - Delegate to appropriate agent
   - Update plan file after each task
   - Repeat until complete or blocked

4. **Persist**
   - Update `**Updated**` date in plan
   - Mark tasks `[x]` with evidence (commit hash)

## Delegation

| Task Type | Delegate To |
|-----------|-------------|
| Implementation | `build` agent |
| Review | `/review` |
| Commit | `/commit` |
| Docs | `/docs` |

## Principles

- Plan file is source of truth
- One task at a time
- Commands stay independent; this coordinates
- Escalate on 2 consecutive failures

## Guardrails

- Don't create plans; only execute
- Keep plan synchronized
- Preserve command independence
