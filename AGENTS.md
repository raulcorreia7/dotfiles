# AGENTS.md — Dotfiles Project

## Git & Local State
- Keep machine-local or plugin-manager state out of shared history
- Ignore local state in the closest project `.gitignore` instead of adding broad root-level repo rules when the scope is local to one area
- Examples:
  - `config/tmux/.gitignore` for `plugins/`
  - `config/opencode/.gitignore` for `plugins/`

## Project Pattern
- Shared dotfiles config is committed
- Desktop-local checkouts, generated artifacts, caches, and local plugin-dev paths stay ignored
