# Documentation Rules

## README

**Purpose**: Project entry point and onboarding.

**Location**: Project root (`README.md`)

**Required Sections**:
- Title + one-line description
- Quick Start (minimal commands to run)
- Features (bullet list)
- Installation (prerequisites + steps)
- Usage (code examples)
- Commands (table format preferred)
- Architecture (folder structure or diagram)
- Configuration (link to .env.example)
- License

**Style**:
- Concise, scannable
- Code examples over prose
- Tables for commands/options
- Link to detailed docs, don't inline everything
- Human-first narrative: explain what users can do before how internals work
- Strong visual rhythm: short sections, intentional whitespace, predictable heading hierarchy
- High-signal formatting only: emphasize key actions/results, avoid noisy decoration
- Keep docs aesthetically clean and pleasant to read without sacrificing clarity

**Quickstart and Examples (Required)**:
- Put Quick Start near the top with copy-pasteable commands
- Include one minimal end-to-end example that works out of the box
- Include one realistic example for common usage in production-like conditions
- Keep README examples high-signal and short; move extended tutorials/reference to dedicated docs
- Link from each example to deeper docs when advanced configuration is needed
- Ensure examples are formatted for copy/paste with minimal edits

---

## Architecture Diagrams

**Purpose**: Make architecture and flow decisions obvious in one pass.

**Formats**:
- Prefer Mermaid for versioned repository docs and long-lived diagrams
- Use ASCII diagrams for fast inline discussion (PRs, issues, ADR notes)

**Required Views (when system complexity warrants it)**:
- Context view: system, actors, external dependencies, trust boundaries
- Container/layer view: services/modules, ownership, boundary lines
- Runtime flow view: critical request/job/event path including failure path
- Data/state view: stores, ownership, lifecycle/state transitions

**Granularity Rules**:
- Label diagram level explicitly (L0, L1, L2)
- One core message per diagram; split dense diagrams
- Show boundary and flow direction; hide low-value implementation noise

**Hygiene**:
- Keep diagrams near relevant docs (`README`, ADR, or design doc)
- Update diagrams in the same change when behavior/boundaries change
- Remove stale diagrams immediately

---

## ADR (Architecture Decision Record)

**Purpose**: Capture "why" decisions with context, consequences, and alternatives.

**Location**: `docs/decisions/` or `decisions/`

**Naming**: `NNNN-title-with-dashes.md` (e.g., `0001-use-postgres.md`)

**Required Sections**:
- Status: Proposed | Accepted | Deprecated | Superseded
- Context: What problem, why now, what forces
- Decision: What we're doing (specific)
- Consequences: Good/Bad outcomes
- Alternatives: What else we considered and why rejected

**Guidelines**:
- One decision per ADR
- Link related ADRs and PRDs
- Update status when decisions change
- Keep historical record (don't delete, supersede)

---

## PRD (Product Requirements Document)

**Purpose**: Define what to build and why before building.

**Location**: `docs/PRD.md` or project root for small projects

**Required Sections**:
- Problem Statement: Who, what, why now, evidence
- Success Metrics: Quantifiable targets with baselines
- User Personas & Jobs: Who, what job, pain points
- Scope: Explicit in-scope and out-of-scope
- Requirements: Prioritized (Must/Should/Could)
- Risks & Mitigations: Identified upfront
- Open Questions: Tracked with owners
- Timeline: Phases with exit criteria

**Guidelines**:
- Separate problem space from solution space
- Update as scope evolves
- Link to ADRs for technical decisions
- Close PRD when shipped or abandoned

---

## Environment Files

**Purpose**: Document required configuration and secrets.

**Files**:
- `.env.example` → Committed (template, no secrets)
- `.env` → Gitignored (actual values)

**Naming Conventions**:
- SCREAMING_SNAKE_CASE
- Prefix for namespacing: `SERVICE_API_KEY`, `BILLING_DB_HOST`
- Group related vars with comment headers
- Never encode environment in key name (no `PROD_DB_HOST`)

**Content Requirements**:
- All required keys present
- Optional keys commented out
- Each key has inline comment explaining purpose
- Sensitive keys have placeholder values (not empty)

**Security**:
- Never commit `.env` or secrets
- Validate at startup
- Pass explicitly through boundaries

---

## Documentation Hygiene

- Update docs with behavior changes
- Delete stale docs immediately
- Link related docs (ADR ↔ PRD ↔ README)
- One source of truth per concept
- Prefer living docs over separate wikis
- Review docs in code review process
