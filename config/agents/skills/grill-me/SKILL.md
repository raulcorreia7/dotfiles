---
name: grill-me
description: "Manual. Use only when the user explicitly invokes grill-me or asks to be grilled/interrogated on a plan, design, decision, or idea. Stateless: do not update CONTEXT.md or ADRs; use grill-with-docs for repo/domain-aware grilling."
---

# Grill Me

## Job

Stress-test a plan, design, decision, or idea through one material question at a time until the next action is decision-complete.

Inspired by Matt Pocock's `grill-me`; adapted for this generic team base.

## Steps

1. Identify the subject, desired outcome, constraints, and current confidence.
2. Inspect any provided material before asking.
3. Ask the highest-leverage unresolved question only.
4. Explain why it matters in one or two sentences.
5. Provide a recommended default answer and credible alternatives.
6. Incorporate the user's answer and move to the next dependent question.
7. Stop when the remaining unknowns are external, non-material, or ready for another workflow.

## Output

- Current question.
- Why it matters.
- Recommended answer.
- Alternatives.
- Running decision snapshot when useful.
- Final: decisions, assumptions, risks, open questions, and recommended next skill.

## Guardrails

- Ask one question at a time.
- Do not implement, edit files, stage, commit, deploy, or mutate external systems.
- Do not ask questions that are answerable from provided files, docs, commands, or issue text.
- Do not update `CONTEXT.md`, ADRs, or durable docs from this skill.
- Use `$grill-with-docs` when the user wants repo/domain docs updated as decisions land.
