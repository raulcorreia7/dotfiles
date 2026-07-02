---
name: prototype
description: "Manual. Use only when explicitly invoked to build throwaway prototype code that answers a design question: logic/state via runnable terminal app or UI via toggleable variations."
---

# Prototype

## Job

Build throwaway code that answers one design question fast, then preserve only the answer.

Inspired by Matt Pocock's `prototype`; adapted for generic repo workflows.

## Branches

- Logic/state question: tiny runnable terminal app or script that drives hard-to-reason cases.
- UI question: several clearly different variations reachable from one route or local preview, switchable with a simple toggle.

## Steps

1. State the question the prototype must answer.
2. Choose the branch: logic/state or UI. If ambiguous, pick the branch that matches nearby code and state the assumption.
3. Put prototype code near the relevant module/page, but mark it obviously as throwaway.
4. Provide one command to run it using the repo's existing task runner.
5. Keep state in memory unless persistence is the question.
6. Surface full relevant state after each action or variation switch.
7. Skip production polish: no broad tests, abstractions, persistence, or error handling beyond runnable feedback.
8. Capture the answer in a PRD, issue, ADR, notes file, or final response.
9. Delete or absorb the prototype when the decision is made.

## Output

- Question answered.
- Prototype path.
- Run command.
- What to try.
- Observed decision/answer.
- Delete/absorb recommendation.

## Guardrails

- Do not leave prototype code looking production-ready.
- Do not add dependencies unless the prototype question cannot be answered otherwise.
- Do not use production data, live services, or persistent stores unless explicitly approved.
- Do not treat prototype code as the implementation plan.
- Do not keep the prototype without a clear cleanup or absorption path.
