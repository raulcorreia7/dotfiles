---
name: grill-with-docs
description: "Manual. Use only when explicitly invoked to grill a repo-backed idea while maintaining CONTEXT.md and ADRs inline. Combines one-question-at-a-time grilling with domain-modeling."
---

# Grill With Docs

## Job

Sharpen a repo-backed plan or design while keeping the project's domain language and durable decisions current.

Inspired by Matt Pocock's `grill-with-docs`; adapted for Codex `$skill` invocation.

## Steps

1. Read relevant `AGENTS.md`, `CONTEXT.md`, `CONTEXT-MAP.md`, and `docs/adr/` material when present.
2. Identify the idea, target context, non-goals, and current decision gaps.
3. Run the grilling loop one question at a time:
   - ask the highest-impact unresolved question;
   - explain why it matters;
   - recommend a default;
   - record the user's decision.
4. Invoke `$domain-modeling` discipline inline when terms become precise, conflict with existing glossary, or deserve an ADR.
5. Update `CONTEXT.md` when a domain term is resolved.
6. Offer an ADR only for decisions that are hard to reverse, surprising without context, and trade-off-driven.
7. Finish with a compact handoff to `$to-prd`, `$to-issues`, `$prototype`, `$plan`, or implementation.

## Output

- Current question.
- Why it matters.
- Recommended answer.
- Updated terms or ADR candidates.
- Decision snapshot.
- Final handoff: goal, decisions, terms, risks, open questions, next skill.

## Guardrails

- Ask one question at a time.
- Do not batch a survey of questions.
- Do not write specs, implementation details, or scratch notes into `CONTEXT.md`.
- Do not create ADRs for obvious, reversible, or temporary choices.
- Do not implement code from this skill.
- Preserve existing doc conventions and user-authored context.
