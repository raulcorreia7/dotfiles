# Docs Polish Model

Use this reference for broad docs audits, broad reorganizations, diagram-heavy work, or link/duplication sweeps.

## Source Model

Use Diataxis as the broad docs architecture:

| Type | Purpose |
|---|---|
| Tutorial | Learning path |
| How-to | Task completion |
| Reference | Stable facts |
| Explanation | Background and rationale |

Use topic typing inside pages:

- concept
- task
- reference
- troubleshooting

Use a signal gradient inside pages:

1. Summary.
2. Quick path.
3. Common tasks.
4. Facts and contracts.
5. Examples.
6. Diagrams.
7. Details and rationale.
8. Troubleshooting.
9. Reference or appendix.

## Audit Checklist

Inventory:

- README files.
- docs folders.
- wiki folders.
- ADRs.
- runbooks.
- diagrams.
- architecture docs.
- API/config/reference docs.
- onboarding docs.
- troubleshooting docs.
- navigation files.
- links and assets.

Check file tree:

- reader-oriented groups.
- related files grouped by resource, topic, or domain.
- no orphan pages.
- no deep nesting without reason.
- useful index pages.
- stable names.
- clear navigation order.
- no mixed unrelated doc types in one folder.

Check page structure:

- clear title.
- one-line summary.
- high-signal top section.
- quick path before details.
- headings that form a clean outline.
- tables for structured facts.
- examples near tasks.
- diagrams near the text they explain.
- troubleshooting after common flows.
- reference at the bottom.

Check links:

- relative links where practical.
- no broken links.
- no duplicate target confusion.
- descriptive link text.
- canonical source links.
- no stale moved-page links.
- no unnecessary raw URLs when a descriptive link is clearer.

Check correctness:

- claims trace to source files, commands, config, docs, tests, pipelines, schemas, ADRs, or user-provided context.
- unknowns are marked.
- generated or inferred docs are not presented as facts.
- examples match source-backed commands or are marked illustrative.

Check duplication and noise:

- duplicate setup instructions.
- duplicate command lists.
- duplicate configuration tables.
- duplicate architecture descriptions.
- duplicate glossary terms.
- duplicate runbook steps.
- duplicate diagrams.
- repeated introductions.
- verbose prose.
- outdated warnings.
- empty sections.
- TODOs without owner or verification path.
- screenshots or diagrams that do not add clarity.

Check security:

- no secrets.
- no private operational values.
- no sensitive hostnames or connection strings.
- placeholders are used for examples.
- sensitive details are generalized.

## Diagram Model

Large diagrams are allowed when they orient the reader, but they must not be the only view when they are dense. Keep an overview, then decompose it into focused views.

Useful granularities:

- Context: actors, external systems, major boundaries.
- Architecture/container: applications, services, stores, queues, jobs, ownership boundaries.
- Cloud/topology: subscriptions, resource groups, networks, private endpoints, managed identities, monitoring.
- System interaction: dependencies between systems or repos.
- Use case: user or operator goals and participating systems.
- Sequence/runtime: important request, event, job, or deployment flows.
- Data/state: lifecycle, ownership, state transitions, schema boundaries.
- Trust boundary: identity, access, secrets, sensitivity, and network boundaries.

Diagram rules:

- Every diagram has a view type, direction, caption, and source notes.
- Labels are short and consistent.
- Dense diagrams are split into focused views.
- Relationship arrows explain the relationship, such as `calls`, `publishes`, `writes`, `owns`, `deploys`, or `monitors`.
- Use Mermaid that fits the target renderer when known.
- Do not invent systems, flows, ownership, or data.
- If no useful diagram can be source-backed, report the missing evidence.

## Target Trees

Use this only when no better local convention exists:

```text
docs/
  README.md
  getting-started.md
  how-to/
  reference/
  explanation/
  troubleshooting/
  architecture/
  diagrams/
  runbooks/
  adr/
```

Use domain/resource grouping when docs naturally belong by domain or resource:

```text
docs/
  README.md
  domains/
    <domain>/
      README.md
      concepts.md
      workflows.md
      reference.md
      diagrams.md
  resources/
    <resource>/
      README.md
      how-to.md
      reference.md
      troubleshooting.md
  architecture/
  runbooks/
  adr/
```

## Azure DevOps Wiki Notes

- Preserve `.order` files when present.
- Keep page names and casing consistent with `.order` entries.
- Use the existing wiki structure unless it is clearly broken.
- Propose file moves before applying large wiki reorganizations.

## Page Template

```md
# <Title>

> Summary: <one sentence>

## Quick path

1. <first useful action>
2. <next useful action>
3. <verify>

## Common tasks

| Task | Link or command |
|---|---|

## Facts and contracts

| Item | Value | Source |
|---|---|---|

## Diagram

<source-backed diagram when it reduces cognitive load>

## Examples

<small examples before large examples>

## Details

<rationale, trade-offs, background>

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|

## Reference

<long lists, links, appendices>
```
