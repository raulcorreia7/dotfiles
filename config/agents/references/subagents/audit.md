# Audit Subagents

Use only when subagents are available and the audit is broad enough to justify parallel work.

```text
Run a read-only audit for this perspective only: <project|code|tests|docs|infra|security>.

Inspect only source/docs/config available in the workspace unless the parent has explicit approval for live checks.
Do not edit, stage, commit, deploy, rotate credentials, or query production data.

Return:
- scope inspected;
- evidence-backed findings;
- confidence and impact;
- blocked checks and approval-gated checks;
- recommended follow-up workflow.
```

The parent thread owns deduplication, severity, and final synthesis.
