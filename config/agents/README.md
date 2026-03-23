# agents

Single source of truth for shared agent guidance.

- Edit `AGENTS.md` for the canonical shared instructions used by Codex and OpenCode.
- Keep only the startup-loaded core guidance in `rules/`.
- Keep optional deep-dive or example material outside `rules/` so it is not loaded by default.
- Keep optional reference material in `reference/`.
- Keep slash-command prompt content in `commands/`.
- If a tool requires its own `AGENTS.md`, keep it synchronized with the canonical file and avoid tool-specific drift.
