---
name: pr-review
description: "Use when the user provides a PR/MR URL, issue/story URL, local branch, or diff and wants PR review plus alignment questions and proposed PR text. Do not post comments, update PRs, approve, request changes, merge, or mutate external systems without explicit approval."
---

# PR Review

## Job

Review a PR or story-backed change against intent, then produce findings, alignment questions, and copy-pasteable PR/review text.

## Input Modes

- PR/MR URL.
- Issue, user story, or acceptance criteria.
- Local branch, working tree, or diff.
- Pasted diff or patch.

## Steps

1. Resolve context: title/body, linked story, acceptance criteria, author notes, diff, changed files, tests, config, migrations, docs.
2. Identify intent: feature, bugfix, refactor, test-only, docs-only, infra, dependency, or migration.
3. Compare change to story: covered criteria, missing behavior, and out-of-scope behavior.
4. Review diff-first for correctness, contracts, data, auth, errors, tests, docs, rollout, and reviewability.
5. Run or recommend narrow checks when practical.
7. Ask alignment only when the answer changes intent, risk, public behavior, scope, rollout, tests, or PR framing.
8. Draft PR text and optional public review comments.

## Alignment Questions

For each material ambiguity:

- Decision:
- Recommended default:
- Why it matters:
- What changes if different:

Proceed with labeled assumptions when not blocked.

## PR Text Shape

```md
## Summary

- <what changed>
- <why>

## Validation

- <command/check/result>

## Risk / rollout

- Risk:
- Rollback:

## Notes for reviewers

- <specific area to inspect>
```

## Output

1. Verdict.
2. Blocking findings.
3. Alignment needed.
4. Proposed PR text.
5. Suggested review comments.
6. Detailed findings.
7. Checks run/skipped.
8. Assumptions and residual risk.

## Guardrails

- Prefer private reviewer notes unless the user asks for public comments.
- Keep PR copy terse, factual, and copy-pasteable.
- Do not invent acceptance criteria.
- Do not block on missing tests unless risk justifies it.
- Do not post, approve, request changes, merge, push, close, or edit external systems without explicit approval.

## References

- Read `../../references/languages/languages.md` and the matching language reference for non-trivial language-specific PR diffs.
