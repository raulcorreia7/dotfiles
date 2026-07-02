---
name: review
description: "Use for code or diff review: correctness, behavior, contracts, security risk, maintainability, and tests. Do not use for PR/story orchestration or docs-only review."
---

# Review

## Job

Review code or diffs for material risk and actionable findings.

## Steps

1. Read intent, changed files, tests, contracts, and local conventions.
2. Review diff-first when a diff exists; follow callers, schemas, config, migrations, and docs only as needed.
3. Look for correctness, regressions, data loss, auth/authz, compatibility, failure paths, and meaningful missing tests.
4. Treat style as a finding only when it affects behavior, readability, ownership, or maintenance risk.
5. Separate blocking findings from non-blocking suggestions and questions.

## Output

- Verdict
- Blocking findings ordered by severity
- Non-blocking suggestions
- Questions
- Checks run/skipped
- Residual risk

## Finding Format

- Severity:
- Location:
- Issue:
- Impact:
- Fix:
- Confidence:

## Guardrails

- Do not block on perfection.
- Do not list speculation as findings.
- Do not approve, request changes, post comments, or mutate external systems without explicit approval.

## References

- Read `references/review-patterns.md` for non-trivial diffs, public contracts, security-sensitive code, migrations, or large reviews.
- Read `../../references/languages/languages.md` and the matching language reference for non-trivial language-specific diffs.
