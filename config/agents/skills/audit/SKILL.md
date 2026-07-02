---
name: audit
description: "Manual invocation only. Use only when the user explicitly invokes audit or asks for a read-only audit of project, code, tests, docs, infra, security, or the full repo. Produces evidence-backed findings and follow-ups."
---

# Audit

## Job

Run a read-only audit and return ranked, evidence-backed findings.

## Modes

- `project`: repo shape, build, ownership, docs, interfaces, stale/optimization signals.
- `code`: implementation risk, contracts, maintainability, dependencies, stale code.
- `tests`: behavior confidence, gaps, flakes, fixtures, CI reliability.
- `docs`: coverage, correctness, freshness, navigation, diagrams, source-backed claims.
- `infra`: IaC, deployment, environments, config, secrets posture, observability, operations.
- `security`: auth/authz, secrets, inputs, dependencies, data exposure, logging, config, abuse paths.
- `full`: synthesize all relevant modes.

## Steps

1. Define scope, depth, mode, and approval boundaries.
2. Inspect repo evidence before live/provider checks.
3. Map the audited surface: entrypoints, owners, contracts, tests, docs, config, infra, or operations as relevant.
4. In docs or full audits, check durable knowledge shape: concept boundaries, indexes, cross-links, citations, duplication, and stale lifecycle notes.
5. Separate facts, inferences, unknowns, and approval-gated checks.
6. Rank findings by impact, confidence, exploitability/blast radius, and verification path.
7. Recommend the smallest useful next workflow.

## Finding Format

| Severity | Finding | Evidence | Fix direction | Confidence |
|---|---|---|---|---|

Severity:

- Critical: data loss, security break, production outage, broken public contract.
- High: likely bug/regression, unsafe migration, essential validation gap.
- Medium: maintainability, test gap, stale docs, unclear ownership, ops risk.
- Low: local improvement or minor gap.

## Output

- Scope and mode
- Executive summary
- Findings table
- Approval-gated checks
- Unknowns
- Focused follow-ups

## Guardrails

- Do not edit, delete, refactor, optimize, deploy, rotate credentials, stage files, or query production data.
- Do not treat missing text matches as proof code is unused.
- Do not make compliance or vulnerability-absence claims without evidence and limits.
- Redact secrets and report sensitive locations generically.

## References

- Read `../../references/subagents/audit.md` for broad `full` audits or requested parallel review.
- Read `../../references/okf/okf.md` for docs, references, folder-structure, or knowledge-catalog audits.
