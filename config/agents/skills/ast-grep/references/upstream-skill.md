# Upstream ast-grep Agent Skill

Use this file to preserve the upstream agent-skill shape in compact local form. The active Codex behavior lives in `../SKILL.md`; this reference exists for alignment with the original upstream workflow.

Source: <https://github.com/ast-grep/agent-skill>

## Original Workflow Shape

The upstream skill teaches an agent to translate natural-language code queries into ast-grep structural rules:

1. Understand the query, language, include/exclude cases, and target paths.
2. Create a minimal code example representing the desired match.
3. Write the simplest ast-grep pattern or YAML rule that should match the example.
4. Test the rule against the example before searching the repository.
5. Search the codebase and present file paths, lines, and relevant match context.

## Upstream Defaults To Preserve

- Prefer structural matching when a query depends on code shape rather than raw text.
- Start simple: try a `pattern`, then add `kind`, relational rules, and composite rules only as needed.
- Use `stopBy: end` for deep `has`/`inside` searches unless a nearer boundary is intentional.
- Use debug output to inspect AST structure when a pattern or `kind` does not match.
- Ask for examples or exclusions when the desired structure is ambiguous.
- Show or explain the generated rule when results are surprising.

## Local Adaptations

- Verify `ast-grep` exists before use; do not rely on `sg` as a substitute.
- Keep the active skill compact and route syntax detail to `rule-writing.md`.
- Treat rewrites as hazardous until previewed or explicitly approved.
- Prefer repo-safe commands: scoped paths, globs, result caps, JSON output for parsing, and no automatic installation.
- Use official ast-grep docs as the current behavior authority if this reference conflicts with installed CLI help.