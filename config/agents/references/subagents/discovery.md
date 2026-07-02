# Optional Discovery Subagents

Use only when the user explicitly requests subagents or parallel discovery.

```text
Spawn read-only subagents.

Agent 1: source structure, entrypoints, commands, tests, dependencies.
Agent 2: docs, architecture notes, diagrams, runbooks, onboarding gaps.
Agent 3: CI/CD, config, containers, IaC, deployment, observability, live-check gates.

Each returns:
- scope inspected;
- evidence-backed findings;
- unknowns;
- recommended artifacts.

Parent synthesizes one report.
```
