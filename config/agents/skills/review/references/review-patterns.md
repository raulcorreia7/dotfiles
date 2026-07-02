# Review Patterns

## Review Stance

- Favor approval when the change improves code health and has no blocking correctness, security, data, migration, compatibility, or test-confidence issue.
- Let automation handle formatting; spend human/agent attention on behavior and risk.
- For huge reviews, ask for split or give high-level risk direction first.

## Surface

| Area | Check |
|---|---|
| Behavior | Expected outcome, edge cases, failure paths |
| Contracts | APIs, schemas, types, config, migrations, versioning |
| Data | persistence, idempotency, concurrency, rollback |
| Security | auth/authz, input handling, secrets, injection, resource limits |
| Tests | meaningful assertions, regression seams, flake risk |
| Maintainability | names, ownership, boundaries, abstraction cost |
| Operations | logging, metrics, rollout, fallback, supportability |

## Specialist Triggers

Recommend specialist review for auth/authz, secrets/crypto, database migrations, public APIs, dependencies/licenses, UI/accessibility, infra/deployment, privacy, legal, or regulated data.

## Comment Quality

- Comment on code, not the author.
- Explain why it matters.
- Offer the smallest practical fix.
- Mark optional ideas as non-blocking.
- Prefer clearer code over review-thread explanations.

## Labels

- `blocking`: must fix before merge.
- `question`: answer may change the review.
- `suggestion`: non-blocking improvement.
- `nit`: optional polish.
- `note`: useful context, no action required.

## Sources

- Google Engineering Practices, Code Review: https://google.github.io/eng-practices/review/
- GitHub Pull Request Reviews: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews
- Conventional Comments: https://conventionalcomments.org/
- OWASP Code Review Guide: https://owasp.org/www-project-code-review-guide/
