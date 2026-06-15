# agents

Single source of truth for shared agent guidance.

- Edit `AGENTS.md` for the canonical shared instructions used by Codex and OpenCode.
- Keep only OpenCode startup-loaded instruction fragments in `rules/`.
- Keep optional deep-dive or example material outside `rules/` so it is not loaded by default.
- Keep optional reference material in `reference/`.
- Keep OpenCode slash-command prompt content in `commands/`.
- Keep portable Codex/OpenCode skills in `skills/<name>/SKILL.md`.
- Do not put Codex command-approval policies here; those use `.rules` files under `~/.codex/rules/`.
- If a tool requires its own `AGENTS.md`, keep it synchronized with the canonical file and avoid tool-specific drift.
