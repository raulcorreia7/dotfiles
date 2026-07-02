---
name: <skill-name>
description: "<Trigger-focused description. Say when to use this skill and when not to use it.>"
# Optional for skill-pack knowledge maintenance:
# metadata:
#   okf:
#     type: Skill
#     tags: [<topic>]
---

# <Skill Name>

## Job

<One sentence explaining the task/domain this skill helps with.>

## Steps

1. <First task-specific step.>
2. <Clarify only decisions that materially change scope, risk, design, or output.>
3. <Apply the topic workflow.>
4. <Validate with checks appropriate to this task.>
5. <Report outcome, assumptions, and skipped checks.>

## Output

- <Expected response or artifact shape.>
- <What must be reported back.>

## Guardrails

- <Boundary or overreach to avoid.>
- <Safety or quality rule.>

## References

- Read `references/<file>.md` when <specific condition>.

## Metadata

For OKF-inspired skill metadata, keep fields under `metadata.okf`. Do not add top-level `type`, `tags`, or `timestamp` to `SKILL.md`.

For command-only skills, set this in `agents/openai.yaml`:

```yaml
policy:
  allow_implicit_invocation: false
```
