---
name: goal-loop
description: "Manual only. Use only when the user explicitly invokes goal-loop or asks to run a goal through an implementation loop with a repo-local goal file and bounded subagents. Do not use for small direct edits, normal planning, review, or one-shot implementation."
---

# Goal Loop

## Job

Drive a goal to completion through a small implementation loop backed by a repo-local goal file and bounded subagents.

## Rules

- Use only on explicit invocation.
- Prefer Codex built-in `/goal` for session-level goal tracking.
- Use `$goal-loop` for repo-local goal execution state.
- Keep the goal file short and useful.
- Use the smallest loop that can make progress.
- Spawn subagents only for bounded work packets.
- Subagents may spawn child subagents only when their brief explicitly allows it.
- Default recursive depth is 2 unless the user asks otherwise.
- Do not spawn agents for small tasks that fit in the current thread.
- Do not let subagents edit overlapping files unless the parent assigns clear ownership.
- Parent thread owns synthesis, conflict resolution, final decisions, and final response.
- Do not mutate live systems, trackers, deployments, credentials, or production data without approval.
- Do not stage or commit unless explicitly asked.

## Goal File

Default location:

```text
.codex/goals/<slug>.md
```

Create or update the goal file when the loop starts.

The file should contain:

- outcome;
- non-goals;
- constraints;
- plan;
- current loop state;
- subagent tasks;
- decisions;
- checks;
- risks.

Use this template:

```md
# Goal: <title>

Status: active
Owner: codex
Created: <date>

## Outcome

<What must be true when done.>

## Non-goals

- <thing not included>

## Constraints

- <constraint>

## Plan

- [ ] <slice 1>
- [ ] <slice 2>
- [ ] <slice 3>

## Current Loop

Iteration:
Focus:
Next action:

## Subagents

| Agent | Task | Status | Result |
|---|---|---|---|

## Decisions

- <decision>

## Checks

- <command/result>

## Risks

- <risk>

## Notes

- <short useful notes only>
```

Do not turn the goal file into a long report.

## Loop

1. Resolve goal:
   - user goal;
   - existing goal file if provided;
   - repo evidence;
   - constraints and non-goals.
2. Create or update `.codex/goals/<slug>.md`.
3. Pick the next smallest useful slice.
4. Decide whether subagents are useful.
5. Spawn bounded subagents when useful.
6. Wait for all requested subagent results.
7. Synthesize findings and resolve conflicts.
8. Implement the smallest correct change in the parent thread, or delegate only when file ownership is clear.
9. Run the narrowest useful checks.
10. Update the goal file.
11. Continue until done, blocked, or a stop rule triggers.

## Subagent Use

Use subagents for:

- parallel repo exploration;
- independent implementation slices;
- focused review;
- test strategy;
- risky area inspection;
- docs or migration analysis.

Avoid subagents for:

- small edits;
- unclear goals;
- highly coupled changes;
- single-file changes;
- decisions requiring user alignment first.

## Subagent Brief

Every subagent must receive:

```md
## Task

<one bounded task>

## Context

- Goal file:
- Relevant files:
- Constraints:
- Non-goals:

## Authority

- Read-only or write scope:
- Allowed files:
- Forbidden files:
- May spawn child subagents: yes/no
- Max child depth:
- Max child agents:

## Expected Return

- Result:
- Files inspected:
- Files changed, if allowed:
- Checks run:
- Evidence:
- Risks:
- Blockers:
- Child agents spawned:
```

## Recursive Delegation

A subagent may spawn child subagents only when all are true:

- parent brief says `May spawn child subagents: yes`;
- task can be split into independent bounded packets;
- child depth remains within configured `agents.max_depth`;
- child work has clear read/write scope;
- child results can be summarized back to the parent subagent.

Child subagents must return to their parent subagent. The root thread still owns final synthesis.

## Write Policy

Default:

```text
subagents are read-only
parent implements
```

Allow subagent writes only when:

- each agent owns a disjoint file set;
- the change is easy to validate;
- conflicts are unlikely;
- rollback is clear.

Never let multiple agents edit the same file unless the parent explicitly sequences the work.

## Stop Rules

Stop and report when:

- goal is complete;
- user decision is required;
- validation fails and cause is unclear;
- subagent outputs conflict materially;
- scope expands beyond the goal;
- approval is needed;
- recursive depth limit is reached;
- loop is no longer making progress.

## Output

Use this order:

1. Goal status.
2. Current iteration result.
3. Files changed.
4. Subagent results.
5. Checks run.
6. Goal file update.
7. Blockers or next loop.

## Done

The goal is done when:

- outcome is satisfied;
- relevant checks pass or skipped checks are explained;
- goal file status is `done`;
- risks and residual gaps are stated.
