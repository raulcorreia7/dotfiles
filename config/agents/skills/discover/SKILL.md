---
name: discover
description: "Manual invocation only. Use only when the user explicitly invokes discover or asks to reverse-engineer an existing repo, system, docs set, infrastructure footprint, or deployed system into source-backed maps, docs, diagrams, risks, and follow-ups."
---

# Discover

## Job

Map an existing repo/system into source-backed understanding and the smallest useful artifact set.

## Steps

1. Scope the repo, service, docs, infra, deployed system, or onboarding target.
2. Inspect existing guidance, READMEs, docs, diagrams, CI, scripts, config, manifests, tests, and IaC.
3. Derive facts from evidence; label inferences, unknowns, user context, and approval-gated checks.
4. Prefer repo/IaC evidence before live-provider discovery.
5. Preserve doc conventions, terminology, locations, and diagram style.
6. For durable docs or knowledge maps, prefer concept-sized artifacts, explicit links, source citations, and directory indexes when navigation needs them.
7. Choose the smallest useful artifacts; avoid duplicate sources of truth.

## Output

- Discovery summary
- Sources inspected
- System/repo map
- Selected artifacts
- Diagrams only where useful
- Risks and unknowns
- Follow-up workflows
- Skipped checks

## Guardrails

- Do not edit files unless explicitly requested.
- Require approval for credentials, network, provider CLIs, live systems, production data, or cost-affecting checks.
- Redact secrets and report secret locations generically.

## References

- Read `references/discovery-checklist.md` before broad discovery.
- Read `references/artifact-catalog.md` before choosing artifacts.
- Read `../../references/okf/okf.md` before producing or reorganizing durable docs, references, or knowledge catalogs.
- Read `../../references/subagents/discovery.md` only when the user requests parallel discovery.
