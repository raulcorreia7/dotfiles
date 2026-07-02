---
name: ast-grep
description: "Use when structural code search, ast-grep rule authoring/debugging, syntax-aware code queries, or safe ast-grep rewrite previews are needed. Prefer grep-like text search for simple text search, using rg when available. Do not use if ast-grep is unavailable except to explain the missing dependency or provide install guidance."
---

# ast-grep

## Job

Use ast-grep for syntax-aware search, YAML rule authoring, rule debugging, and safe rewrite previews.

## Steps

1. Verify `command -v ast-grep`; if absent, do not use `sg`, do not install automatically, and fall back to grep-like text search only when it can satisfy the request.
2. Use grep-like text search, preferably `rg` when available, for literal text, filenames, comments, strings, or simple token search.
3. Use ast-grep when structure, metavariables, containment, absence, or codemods matter.
4. Identify language, target paths, include/exclude globs, expected matches, and whether the task is search, lint-like scan, or rewrite.
5. Use `ast-grep run --pattern ... --lang ...` for simple structural matches.
6. Use `ast-grep scan --inline-rules ...` or `ast-grep scan --rule <file>` for relational/composite YAML rules.
7. Test rules on a minimal snippet before broad scans; use `--debug-query=ast`, `--debug-query=cst`, or `--debug-query=pattern` when node kinds or metavariables are unclear.
8. For broad scans, prefer scoped paths, `--globs`, `--max-results`, `--json=stream|compact`, and `--inspect=summary` when useful.
9. For rewrites, preview first. Use `--interactive` when a human will review; use `--update-all` only after explicit approval.

## Output

- Exact command shape
- Match intent
- Result summary
- Generated rule or pattern when useful
- Rewrite safety posture
- Missing binary or skipped checks

## Guardrails

- Do not rely on `sg`; it can refer to another system command.
- Do not scan the whole repo first when a scoped path or snippet is enough.
- Do not commit generated rules unless requested.
- Do not use `--update-all` without explicit approval and a successful preview.

## References

- Read `references/rule-writing.md` for rule syntax, common patterns, debugging, and pitfalls.
- Read `references/upstream-skill.md` when aligning with the upstream ast-grep workflow.
- Read `references/sources.yml` when source attribution or update provenance matters.
