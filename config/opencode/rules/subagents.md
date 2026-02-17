# Subagent Rules

## When to Use
Use subagents for self-contained parallel work, fresh-context research,
or specialized tasks.

Do not use subagents for rapid conversational iteration or trivial tasks.

## Required Handoff Context
1. Objective and success criteria
2. Current state, constraints, and relevant files
3. In scope and out of scope
4. Applicable standards (`AGENTS.md`, `rules/*`)
5. Expected output format and destination

## Context Hygiene
- Provide only relevant context
- Prefer concrete files/errors/decisions over broad dumps

## Command Mapping
- `/architect`: system design and boundaries
- `/plan`: task decomposition and dependencies
- `/review`: diff review
- `/commit`: commit structure and messages
- `/docs`: documentation maintenance
- `/orchestrate`: multi-agent coordination

## Acceptance
Before integrating subagent output, verify:
- it meets success criteria
- assumptions are explicit
- recommendations align with project rules
