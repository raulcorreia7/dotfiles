# Dotfiles Architecture

## Overview

Modular dotfiles with strict separation between **installer** and **runtime**. Each layer is isolated with single responsibility.

## Public API

### RDF Command

```
rdf <command>
```

| Command | Description |
|---------|-------------|
| `rdf reload` | Reload dotfiles |
| `rdf edit` | Edit dotfiles |
| `rdf doctor` | Check tool status |
| `rdf cd` | Go to dotfiles |
| `rdf update [--full]` | System update (Arch) |
| `rdf orphans [--remove]` | Orphan packages (Arch) |
| `rdf cache [--clean]` | Pacman cache (Arch) |

### Public Functions

| Function | Description |
|----------|-------------|
| `dot_has CMD` | Check if command exists |
| `dot_shell_type` | Print shell type (zsh/bash/sh) |
| `dot_eval_init CMD` | Initialize tool for current shell |

### Alias

| Alias | Description |
|-------|-------------|
| `nvcfg` | Edit neovim config |

---

## Structure

```
.dotfiles/
├── install              # Installer entrypoint
├── init.sh              # Runtime entrypoint
├── Makefile             # Build commands (fmt, lint, install)
├── .shfmt               # Shell formatter config
├── .shellcheckrc        # Shell linter config
│
├── installers/          # INSTALLER LAYER
│   ├── lib.sh           # log_*, detect_os, require_*
│   ├── config.sh        # Paths, URLs, constants
│   ├── phases/          # Install phases
│   │   ├── 10-check.sh
│   │   ├── 20-setup.sh
│   │   ├── 30-install.sh
│   │   ├── 40-tools.sh
│   │   └── 50-configure.sh
│   ├── install-arch.sh
│   ├── link.sh
│   └── post-install.sh
│
├── config/              # RUNTIME LAYER
│   ├── runtime.sh       # rdf, dot_*, __dot_*
│   ├── manifest.sh      # Plugin loader
│   ├── env              # Environment
│   ├── aliases          # Aliases
│   └── plugins/
│       ├── mise/init.sh
│       ├── fzf/init.sh
│       ├── zoxide/init.sh
│       ├── tmux/init.sh
│       └── os/arch/init.sh
│
└── packages/arch/
    ├── pacman
    └── aur
```

---

## Data Flow

```
INSTALL:
./install → installers/lib.sh → phases/*.sh → packages/*

RUNTIME:
.zshrc → init.sh → runtime.sh → manifest.sh → plugins/*/
                  → env
                  → zimfw
                  → aliases
```

---

## Principles

### Layer Separation
- `installers/` ≠ `config/`
- No shared functions between layers
- `log_*` for installer, `__dot_debug` for runtime

### Naming

| Prefix | Scope | Example |
|--------|-------|---------|
| `rdf` | Public command | `rdf reload` |
| `dot_` | Public function | `dot_has` |
| `__dot_` | Private runtime | `__dot_load_plugin` |
| `__rdf_` | Private rdf subcommand | `__rdf_doctor` |
| `log_` | Installer | `log_info` |

---

## Adding Packages

```bash
# pacman
echo "ripgrep" >> packages/arch/pacman

# aur
echo "mise-bin" >> packages/arch/aur
```

## Adding Plugins

1. Create `config/plugins/x/init.sh`:
```sh
#!/bin/sh
dot_has x || return 0
dot_eval_init x
```

2. Add to `config/manifest.sh`:
```sh
__dot_load_plugin "x"
```

---

## Sync

```bash
rsync -avz --delete ~/.dotfiles/ talos:~/.dotfiles/
```
