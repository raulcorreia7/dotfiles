---
name: code-comments
description: "Use to audit and improve source-code comments, docstrings, XML docs, TSDoc/JSDoc, Javadoc, Rustdoc, Godoc, public API documentation, TODO/FIXME/HACK markers, stale comments, comment density, and comment style. Use when the user asks to review, add, remove, rewrite, polish, tidy, or standardize code comments without changing behavior."
---

# Code Comments

## Job

Audit and improve code comments while preserving runtime behavior.

This skill covers:

- public API docs: TSDoc/JSDoc, docstrings, XML docs, Javadoc, Rustdoc, Godoc, and similar language-native docs;
- exported functions, classes, types, schemas, routes, config, and module contracts;
- implementation comments;
- TODO/FIXME/HACK markers;
- stale, noisy, missing, misleading, or over-broad comments;
- comment density and placement.

## Default Mode

Default to **edit mode** when the user asks to fix, polish, clean up, add, or rewrite comments.

Default to **audit-only mode** when the user asks to review, audit, assess, or check comments.

Do not change runtime behavior unless the user explicitly asks.

## Required References

Read the shared comment guidance before editing:

- `../../references/comments/comments.md`

Choose the relevant language reference:

- read `../../references/languages/languages.md`;
- then read the matching language file for the codebase under `../../references/languages/`.

For TypeScript/JavaScript, read:

- `../../references/languages/typescript.md`

## Workflow

1. Inspect repo guidance and current diff/status.
2. Search comments, markers, and public surfaces with an available grep-like tool. Use `rg` when available, otherwise use `grep` or the repo's normal search tool. Start broad, then narrow by language:
   - pattern: `//|/\\*|#|TODO|FIXME|HACK|NOTE|WARNING|docstring|export |public |class |interface |type |schema|route|config`.
3. Classify each comment:
   - keep: durable constraint, contract, risk, rationale, external quirk;
   - rewrite: useful but too vague, wordy, stale, or not in local style;
   - remove: repeats mechanics or narrates obvious code;
   - add: exported API or boundary contract lacks documentation.
4. Add public API docs where signatures do not fully explain:
   - purpose;
   - caller-visible behavior;
   - errors, throws, panics, or failure modes;
   - side effects;
   - auth/security boundaries;
   - lifecycle, state, ordering, or concurrency constraints;
   - external system assumptions.
5. Keep implementation comments sparse:
   - prefer `NOTE:` for durable context;
   - use `WARNING:` only for real footguns;
   - use `TODO:` only with owner, issue, date, condition, or removal path.
6. Run appropriate checks after editing source files.
7. Report files changed, checks run, skipped checks, and residual comment gaps.

## Style Rules

- Comment the durable reason, not the visible action.
- Prefer clear code and explicit types over comments that explain mechanics.
- Use short, direct comments.
- Do not add decorative or generic module summaries.
- Do not document every private helper unless its contract is easy to misuse.
- Do document public/exported functions, classes, types, schemas, config, routes, and integration boundaries.
- Keep comments close to the code they constrain.
- Do not include secrets, private URLs, tokens, customer data, or live operational values.
- Do not leave bare `TODO: clean up`.

## Doc Comment Defaults

Use language-native doc comments for exported surfaces when useful:

```ts
/**
 * Creates the HTTP app without starting a listener.
 *
 * Throws when configuration is invalid. Direct admin routes require
 * `x-admin-api-key` when hosted bot settings are configured.
 */
export function createApp(config: AppConfig): Hono {
  ...
}
```

Use inline `NOTE:` for local constraints:

```ts
// NOTE: Azure DevOps WIT create requires "$Type" URL segments and JSON Patch bodies.
const typeSegment = encodeURIComponent(`$${workItemType}`);
```

Avoid comments like:

```ts
// Create the URL.
const url = ...
```

## Audit Output

When audit-only, use:

- Verdict:
- Missing API docs:
- Stale/noisy comments:
- Marker issues:
- Security/privacy comment risks:
- Suggested edits:
- Checks run/skipped:

## Edit Output

When editing, use:

- Changed:
- Files:
- Checks:
- Skipped:
- Residual risk:
