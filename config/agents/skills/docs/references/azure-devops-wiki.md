# Azure DevOps Repository Wiki Recipe

Use only when an Azure DevOps repository wiki is explicitly requested.

## Rules

- Use Markdown pages plus `.order` files.
- In `.order`, list page names without `.md` and match casing.
- Parent pages with child pages need both `Page.md` and a peer `Page/` folder.
- Keep Azure DevOps-compatible Markdown and Mermaid.
- Use `graph LR` or `graph TB`; avoid `flowchart`, long arrows, and links to/from `subgraph`.
- Use `$diagrams` and `../../../references/diagrams/diagrams.md` for supported diagram types, edge labels, and visual-quality rules.
- Link to canonical repo files when duplicating facts would drift.
- Never include secrets or private live values.

## Default Layout

```text
Home.md
Business-Domain.md
Glossary.md
Use-Cases.md
Specifications.md
Specifications/
Architecture.md
Architecture/
  Diagrams.md
Development.md
Operations.md
Runbooks.md
Runbooks/
Reference.md
Reference/
  Configuration.md
  Interfaces.md
  Dependencies.md
Decisions.md
.order
```

Root `.order`:

```text
Home
Business-Domain
Glossary
Use-Cases
Specifications
Architecture
Development
Operations
Runbooks
Reference
Decisions
```

## Page Responsibilities

| Page | Purpose |
|---|---|
| Home | what the repo owns, ownership, key links |
| Business Domain | business context, actors, capabilities |
| Glossary | canonical terms and aliases |
| Use Cases | scenarios and outcomes |
| Specifications | expected behavior and contracts |
| Architecture | runtime shape, constraints, decisions |
| Development | setup, build, test, debug |
| Operations | deploy, monitor, support, recover |
| Runbooks | specific procedures |
| Reference | stable facts: config, interfaces, dependencies |
| Decisions | ADRs and decision index |
