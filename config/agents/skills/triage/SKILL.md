---
name: triage
description: "Manual. Use only when explicitly invoked to triage issues, PRs, reports, requests, or backlog buckets into category/state roles, verify claims, and draft agent-ready briefs."
---

# Triage

## Job

Move incoming issues or external PRs through a small state machine and produce the next useful artifact.

Inspired by Matt Pocock's `triage`; adapted to be provider-agnostic and approval-gated.

## Categories

- `bug`: something is broken.
- `enhancement`: new behavior or improvement.

## States

- `needs-triage`: maintainer evaluation needed.
- `needs-info`: reporter detail needed.
- `ready-for-agent`: scoped, verified, and briefed for an AFK agent.
- `ready-for-human`: needs human judgment, access, merge authority, or manual validation.
- `wontfix`: duplicate, already implemented, rejected, or out of scope.

## Steps

1. Resolve target: issue, PR, URL, number, label bucket, backlog query, or pasted report.
2. Read issue/PR body, comments, labels, author, dates, prior triage notes, linked docs, and diff if PR.
3. Read repo setup when present: `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`.
4. Search for existing implementation by domain concept, not only reporter wording.
5. Check prior decisions and out-of-scope notes when present.
6. Recommend category and state with evidence.
7. Verify the claim when practical:
   - bug: reproduce or identify exact missing repro detail;
   - PR: inspect diff and relevant checks;
   - enhancement: confirm affected module, interface, and acceptance criteria.
8. Grill only if the request is promising but under-specified.
9. Draft the next action: needs-info note, agent brief, ready-for-human handoff, or close rationale.
10. Apply labels/comments/closing only after explicit approval.

## Agent Brief

- Goal:
- Context:
- Domain terms:
- Affected modules/interfaces:
- Constraints:
- Done when:
- Checks:
- Risks:
- Unknowns:

## Output

- Recommendation.
- Category + state.
- Evidence.
- Verification result.
- Missing info.
- Proposed next action.
- Draft brief/comment when useful.

## Guardrails

- Do not mutate issue trackers, labels, comments, assignees, states, branches, or PRs without explicit approval.
- Do not re-ask resolved questions from prior notes.
- Do not mark `ready-for-agent` unless scope, done criteria, and validation are clear.
- Do not triage issues produced by `$to-issues`; they are already intended to be agent-ready.
- External comments must be clearly marked as AI-generated when the repo requires it.
