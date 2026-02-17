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
