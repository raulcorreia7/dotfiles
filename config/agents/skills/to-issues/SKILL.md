---
name: to-issues
description: "Manual. Use only when explicitly invoked to break a plan, spec, PRD, or conversation into independently grabbable vertical-slice issues, publishing to an issue tracker or creating one standalone issue file per slice."
---

# To Issues

## Job

Turn a plan, spec, PRD, or conversation into small, independently grabbable issues using tracer-bullet vertical slices.

Inspired by Matt Pocock's `to-issues`; adapted for provider-agnostic trackers.

## Steps

1. Gather source material from the conversation, provided file, issue URL, PRD, or spec.
2. Read repo setup when present: `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`.
3. Inspect codebase context only when it changes slice boundaries, existing seams, dependencies, or risk.
4. Use project domain vocabulary and respect ADRs.
5. Identify prefactoring that must happen before feature slices.
6. Preserve source links and citations when splitting documentation, references, or knowledge-catalog work.
7. Draft vertical slices:
   - each slice crosses all necessary layers end to end;
   - each slice is demoable or independently verifiable;
   - blockers come before dependents;
   - no horizontal-only issues unless they are enabling prefactors.
8. Present the proposed breakdown as a numbered list with title, blockers, and user stories or source sections covered.
9. Ask whether the granularity feels right, whether dependencies are correct, and whether any slices should be merged or split.
10. Iterate until the user approves the breakdown.
11. After approval, publish issues to the tracker or create one standalone issue file per approved slice.
12. When creating files, write them in dependency order under the configured backlog/issues directory. If none is configured, use `issues/`. Do not combine slices into one mega file.

## Issue Body

- Parent:
- What to build:
- Acceptance criteria:
- Blocked by:
- Validation:
- Notes:

## Issue Files

- Use one Markdown file per issue.
- Name files with stable dependency order and a short slug, for example `001-add-basic-import-flow.md`.
- Keep each file self-contained enough for an AFK agent to pick up without reading a mega bundle.
- Include parent/source references in each file when relevant.
- Use real tracker identifiers in `Blocked by` when publishing. Use filenames or titles when writing local issue files.

## Output

- Numbered proposed issues before approval.
- Dependencies/blockers.
- User stories or PRD sections covered.
- Granularity questions.
- Final issue file paths or published issue references.

## Guardrails

- Do not publish, label, assign, close, or mutate tracker state without explicit approval.
- Do not close or modify the parent issue.
- Do not include brittle file paths or code snippets unless they capture a prototype decision better than prose.
- Do not create horizontal layer tickets when a vertical slice can deliver proof.
- Do not produce one consolidated issue file unless the user explicitly asks for a single bundle.

## References

- Read `../../references/okf/okf.md` when splitting documentation IA, references, folder structure, or knowledge-catalog work.
