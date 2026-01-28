# AGENTS.md — Dotfiles Development Contract

Authoritative contract for autonomous work on this dotfiles repository.

---

## Repository Context

| | |
|--|--|
| **Type** | Personal dotfiles |
| **Languages** | Shell (POSIX sh, zsh), some PowerShell |
| **Entry Point** | `init.sh` — sourced by shell config |

```
.dotfiles/
├── config/          # App configs + shell modules
├── lib/install/     # Installation system
├── os/install/      # OS-specific installers
│   ├── lib/         # Shared libraries
│   ├── before/      # Pre-install hooks
│   ├── modules/     # Modular components
│   ├── os/          # OS-specific installers
│   └── after/       # Post-install hooks
├── bin/             # User scripts → ~/.local/bin
├── docs/            # Documentation
│   ├── development/ # Developer guides
│   └── reference/   # API reference
└── init.sh          # Shell entrypoint
```

---

## Path Variables

Defined in `config/paths.sh`:

| Variable | Description |
|----------|-------------|
| `DOTFILES_DIR` | Repository root |
| `DOTFILES_CONFIG_DIR` | Configuration directory |
| `DOTFILES_BIN_DIR` | User scripts directory |
| `DOTFILES_INSTALLERS_DIR` | Installers root |
| `DOTFILES_LIB_DIR` | Shared libraries |
| `DOTFILES_MODULES_DIR` | Modular components |
| `DOTFILES_OS_DIR` | OS-specific installers |
| `DOTFILES_BEFORE_DIR` | Pre-install hooks |
| `DOTFILES_AFTER_DIR` | Post-install hooks |

---

## Workflows

## Coding Standards

### Shell Code

- `#!/bin/sh` for POSIX, `#!/bin/zsh` for zsh-specific
- `set -euo pipefail` for strict mode
- Use functions; keep logic minimal

### Naming Conventions

| Prefix | Usage | Example |
|--------|-------|---------|
| `__dot_*` | Core internal | `__dot_log` |
| `dot_*` | Core public API | `dot_reload` |
| `_plugin_*` | Plugin private | `_tmux_autostart` |
| `plugin_*` | Plugin public | `arch_pacman_update` |
| `install_*` | Installer functions | `install_pacman` |

### Config Management

- XDG-first: configs in `config/<app>/`, linked to `~/.config/<app>/`
- No hardcoded personal paths or secrets
- One package per line; `#` for comments

### File Organization

```sh
# ------------------------------------------------------------------------------
# SECTION: Setup/Guard
# ------------------------------------------------------------------------------
```

---

## Tooling

| Tool | Use |
|------|-----|
| `rg` | Gitignore-aware search |
| `fd` | Friendly `find` |
| `jq` / `yq` | JSON/YAML processing |

```bash
# Run full lint suite
./scripts/lint.sh

# Individual checks
sh -n <file>                    # Syntax check
shfmt -w -i 2 -bn -ci <file>    # Format
editorconfig-checker .          # Check editorconfig
```

---

## Change Management

- Small, single-concern commits
- Conventional commits: `type(scope): description`
- No breaking changes to existing configs
- Respect `DOTFILES_ENABLE_<FEATURE>` flags

---

## Dotfiles-Specific Conventions

| Task | Location |
|------|----------|
| Add aliases | `config/aliases` |
| Add functions | `lib/` or `modules/` |
| Add plugins | `modules/<name>/init.sh` → add to `lib/manifest.sh` |
| Add packages | `lib/install/packages/<os>/` |
| Add scripts | `bin/` → linked to `~/.local/bin/` |

Feature flags: `DOTFILES_ENABLE_<FEATURE>=0` to disable, `DOTFILES_<FEATURE>_INSTALL=0` to skip install.

---

## Third-Party Code

Do not modify:

- `config/tmux/plugins/*` — Tmux plugins
- `config/zimfw/modules/*` — Zimfw modules

Excluded from linting via `.editorconfig-checker.json`.

---

## Security

- No network writes without explicit approval
- Validate/sanitize external inputs
- Guard file paths
- Prefer non-root execution
