# Subagent References

Shared prompt templates for bounded, read-only subagent work.

Use these only when the selected workflow is broad enough for parallel work or the user explicitly requests subagents. The parent thread owns scope, deduplication, severity, and final synthesis.

| Reference | Use for |
|---|---|
| `audit.md` | Broad full audits or requested parallel review |
| `discovery.md` | Parallel repo/system discovery |

Guardrails:

- Keep subagents read-only unless the user explicitly approves mutation.
- Give each subagent one bounded perspective.
- Require evidence-backed findings and unknowns.
- Synthesize in the parent thread.
