---
description: Resume or execute an existing plan
agent: build
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
    - **Spawn subagent using Task tool** with `/task-do <slug> <task-id>` for isolated execution
   - **Verify completion** — do NOT mark done without evidence:
     - Subagent must report what tests ran and passed
     - If no tests, subagent must describe manual verification
     - Reject "task done" claims without verification details
   - Update plan file after each task
   - Repeat until complete or blocked

4. **Persist**
   - Update `**Updated**` date in plan
   - Mark tasks `[x]` with evidence (commit hash)

5. **Finalize**
   - When all tasks complete and status is `Complete`:
     - Rename file: `slug-YYYY-MM-DD.md` → `slug-YYYY-MM-DD.completed.md`
     - Use: `mv docs/plans/slug-YYYY-MM-DD.md docs/plans/slug-YYYY-MM-DD.completed.md`

## Subagent Delegation

All tasks execute as subagents for isolation and fresh context:

| Task Type      | Command                     |
| -------------- | --------------------------- |
| Implementation | Task tool: `/task-do <slug> <task-id>` |
| Review         | `/review` (subagent)        |
| Commit         | `/commit` (subagent)        |
| Docs           | `/docs` (subagent)          |

Use Task tool for parallel execution only if explicitly planned.

## Principles

- Plan file is source of truth
- One task at a time
- **Verify before complete** — no assumed completion without evidence
- Commands stay independent; this coordinates
- Escalate on 2 consecutive failures

## Guardrails

- Don't create plans; only execute
- Keep plan synchronized
- Preserve command independence
