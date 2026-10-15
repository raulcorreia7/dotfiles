# AGENTS.md — Dotfiles Project

## Git & Local State
- Keep machine-local or plugin-manager state out of shared history
- Ignore local state in the closest project `.gitignore`; use the root `.gitignore` only for cross-cutting patterns
- Examples:
  - `dotconfigs/.config/tmux/.gitignore` for `plugins/`
  - `dotconfigs/.config/alacritty/.gitignore` for `themes/`

## Project Pattern
- Shared dotfiles config is committed
- Desktop-local checkouts, generated artifacts, caches, and local plugin-dev paths stay ignored
- No tooling beyond `setup` + `init.sh`: clone the repo and run `./setup`; keep it that simple
