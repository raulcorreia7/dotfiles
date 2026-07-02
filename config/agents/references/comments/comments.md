# Comments

Shared comment guidance for code, scripts, config, rule files, and agent assets.

Use comments as guardrails for future maintainers. Preserve intent, contracts, constraints, risks, and rationale that code alone does not reliably communicate. Load this only when comment style or comment quality matters.

## Principles

- Comment the durable reason, not the visible action.
- Treat public API documentation and implementation comments as different tools.
- Use the comment form expected by the language, framework, formatter, linter, and documentation tooling.
- Prefer clear code and explicit contracts, but do not rewrite code only to avoid comments unless refactoring is in scope.
- Avoid comments that narrate ordinary mechanics or drift faster than the code.

## Public API Documentation

Use language-native doc comments for public or exported APIs when the contract is not fully obvious from the signature, type, or local convention.

Document caller-visible contracts:

- purpose and behavior;
- parameters or fields whose meaning is not obvious;
- return behavior;
- errors, exceptions, panics, or safety requirements;
- side effects, lifecycle, ordering, compatibility, or concurrency constraints;
- examples when they prevent misuse.

## Implementation Comments

Use implementation comments for local context that future maintainers must preserve.

Good reasons:

- invariants, ordering, ownership, or lifecycle constraints;
- security, privacy, safety, cost, migration, or compatibility rationale;
- external system quirks;
- generated-code or tooling boundaries;
- concurrency, cancellation, locking, or resource ownership;
- intentionally surprising tradeoffs.

Avoid:

- restating mechanics already visible in the code;
- explaining every branch in simple control flow;
- using comments as a substitute for unclear code when code changes are in scope;
- broad history that belongs in docs, ADRs, issues, or git history.

## Multiline Comments

Use multiline comments when the explanation is genuinely multi-sentence, structured, or easier to scan as a block. Use repeated line comments when that is the local or language idiom.

Allowed uses:

- public API contracts;
- examples;
- safety, security, lifecycle, or compatibility rationale;
- longer warnings;
- structured notes in config, rule, or agent files;
- generated-file or file-level context.

Do not use multiline comments to hide unclear names, tangled logic, stale history, or missing tests.

## Freshness

Keep comments synchronized with the code they guard.

- When changing code near a comment, update or remove the comment in the same change if behavior, intent, constraints, or contracts changed.
- Remove comments that no longer describe current behavior.
- Prefer docs, ADRs, issues, or git history for broad historical context.
- Treat stale comments as correctness risk, not style noise.

## Enforcement

Comments explain constraints; they do not enforce them.

- Use tests, assertions, types, validation, linters, or runtime checks when a rule can be enforced practically.
- Use comments for the context enforcement cannot explain: rationale, risk, external constraint, or tradeoff.
- Do not treat comments as a substitute for missing tests around important behavior.
- If a comment describes a safety, security, data, or compatibility rule, prefer pairing it with an enforcing mechanism when practical.

## Placement

Put comments where they reduce the chance of misuse.

- Keep local constraints close to the code, setting, or command they constrain.
- Put public API contracts on the API surface using the language-native doc form.
- Put generated-file, tool, migration, or file-wide constraints near the top of the file.
- Put broad architecture, history, and tradeoffs in docs, ADRs, issues, or runbooks.
- Avoid distant comments that require the reader to connect context manually.

## Security And Privacy

Use comments to explain security or privacy rationale, not sensitive values.

- Do not put secrets, tokens, keys, credentials, private customer data, or live operational values in comments.
- Use placeholders when examples need sensitive-looking values.
- Explain trust boundaries, validation requirements, auth/authz assumptions, data retention constraints, and privacy rationale where future edits could weaken them.
- Link to owned secure references instead of copying sensitive material inline.

## Searchable Markers

Use consistent markers when a comment is meant to be found later.

Allowed markers:

- `NOTE:` for durable context that prevents misuse.
- `WARNING:` for real footguns, safety risks, destructive behavior, or security/privacy risk.
- `TODO:` for planned follow-up with a known trigger.
- `FIXME:` for known incorrect behavior intentionally left in place.
- `HACK:` for a deliberate workaround around a constraint.

Rules:

- Keep marker names uppercase and searchable.
- Do not invent one-off labels.
- Use markers only when the category matters.
- Do not use `WARNING:` for ordinary complexity or personal preference.
- Avoid normalizing tool or type-checker suppressions as ordinary comments; keep suppression guidance language-specific.

## Follow-Up Comments

`TODO:`, `FIXME:`, and `HACK:` should include enough context for a future maintainer to act.

Accepted anchors:

- ticket, work item, issue, or ADR: `TODO(ENG-423): Remove fallback after mobile clients require PKCE.`;
- owner: `TODO: @first.lastname replace shim after Partner API v2 rollout.`;
- condition: `TODO: Remove after v3 clients are retired.`;
- version or date boundary: `TODO: Remove after 2026-09-01 migration window closes.`;
- verification or removal path: `TODO: Delete once import backfill passes in production.`

Avoid bare reminders such as `TODO: clean this up`.

## Links

Use links when they preserve source context the code cannot carry.

Good link targets:

- owned docs, ADRs, runbooks, issues, or work items;
- external specs, standards, API docs, or compatibility notes;
- upstream library issues, changelogs, release notes, or bug reports;
- migration plans or deprecation notices.

Rules:

- Prefer durable, authoritative links over chat threads or generic blog posts.
- Link to the source of the constraint, workaround, or compatibility decision.
- Add enough local context that the comment still helps if the link moves.
- Do not copy sensitive or private operational details into comments.

## File-Level Comments

Use file-level comments when the whole file has a constraint the reader must know before editing.

Good reasons:

- generated file or generated section;
- unusual format, parser, or tooling constraint;
- ownership or boundary rule;
- security, privacy, migration, or compatibility constraint;
- rule, policy, config, or agent asset whose purpose is not obvious from filename alone.

Avoid generic summaries that duplicate filenames, module names, or obvious ownership.

## Tone

Write comments as concise, neutral guidance for the next maintainer.

- Use present tense.
- Be specific about the constraint, rationale, or action.
- Avoid jokes, blame, sarcasm, speculation, and vague warnings.
- Do not depend on private team context the next maintainer may not have.
- Use neutral wording for legacy behavior and external constraints.

## Examples

Prefer durable reason over visible action:

```ts
// Bad: repeats mechanics.
for (const user of users) {
  // Send each user an email.
  await sendEmail(user);
}

// Better: preserves a constraint.
for (const user of users) {
  // Preserve input order because the audit export reconciles by row position.
  await sendEmail(user);
}
```

Public API docs should describe caller-visible contracts:

```ts
/**
 * Creates a payment authorization without capturing funds.
 *
 * Throws when the payment method is expired or the provider rejects the request.
 * The returned authorization must be captured or voided before `expiresAt`.
 */
```

Use anchored follow-up comments:

```ts
// Bad
// TODO: clean this up

// Better
// TODO(ENG-423): Remove fallback after mobile clients require PKCE.

// Better
// TODO: @first.lastname replace shim after Partner API v2 rollout.
```

Use multiline comments when the rationale is easier to scan as a block:

```go
// Keep this retry loop outside the transaction.
// The provider may accept the request and fail before returning a response.
// Retrying inside the transaction can duplicate the ledger write.
```

Use neutral wording:

```ts
// Bad
// Weird legacy nonsense. Don't touch.

// Better
// Preserve this field name; Partner API v1 rejects `customerId`.
```

## Non-Code Formats

- Markdown: prefer prose sections over hidden HTML comments.
- YAML, TOML, shell-style config, and rules files: use `#` comments.
- Keep config comments close to the setting or command they constrain.
- Explain purpose, boundary, risk, and limitation when context prevents misuse.

## Sources

- PEP 8 comments: https://peps.python.org/pep-0008/#comments
- Google Testing Blog, "Code Health: To Comment or Not to Comment?": https://testing.googleblog.com/2017/07/code-health-to-comment-or-not-to-comment.html
- Go doc comments: https://go.dev/doc/comment
- Rustdoc, "How to write documentation": https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html
- C# XML documentation comments: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/
- TSDoc approach: https://tsdoc.org/pages/intro/approach/
- Oracle, "How to Write Doc Comments for the Javadoc Tool": https://www.oracle.com/technical-resources/articles/java/javadoc-tool.html
