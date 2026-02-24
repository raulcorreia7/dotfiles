# Dotfiles Architecture

## Overview

This repository is split into two explicit layers:

- Installer layer: machine bootstrap and package/tool setup
- Runtime layer: interactive shell behavior (`rdf`, aliases, plugin init)

The installer never depends on runtime internals, and runtime never depends on
installer internals.

## Entrypoints

- `install`: phased installer runner
- `uninstall`: restore backups created during setup
- `init.sh`: runtime entrypoint sourced by shell rc files

## Layer Responsibilities

### Installer Layer (`installers/`)

- `lib.sh`: logging, guards, OS detection, phase helpers
- `config.sh`: path and package-list configuration
- `phases/10-check.sh`: readiness checks (OS/support, required tools)
- `phases/20-setup.sh`: linking via GNU Stow
- `phases/30-install.sh`: OS package installation dispatcher
- `phases/40-tools.sh`: mise/zimfw/nvim post-package tooling
- `phases/50-configure.sh`: post-install configuration trigger
- `install-arch.sh` and `install-macos.sh`: OS-specific package installation
- `link.sh`: symlink orchestration using GNU Stow
- `post-install.sh`: shell, PATH, directories, and git defaults

### Runtime Layer (`init.sh`, `config/`)

- `init.sh`: runtime bootstrap, env load, zimfw init, aliases, manifest
- `config/runtime.sh`: public runtime API and `rdf` command
- `config/manifest.sh`: plugin registration order
- `config/plugins/*/init.sh`: isolated plugin integration points

## Runtime Public API

### Commands

- `rdf reload`
- `rdf edit`
- `rdf doctor`
- `rdf cd`
- `rdf update [--full]` (Arch)
- `rdf orphans [--remove]` (Arch)
- `rdf cache [--clean]` (Arch)

### Functions

- `dot_has <cmd>`
- `dot_shell_type`
- `dot_eval_init <tool>`
- `dot_load_plugin <plugin>`

## Install Flow

```text
install
  -> phases/10-check.sh
  -> phases/20-setup.sh
  -> phases/30-install.sh
  -> phases/40-tools.sh
  -> phases/50-configure.sh
```

## Runtime Flow

```text
~/.zshrc or ~/.bashrc
  -> ~/.dotfiles/init.sh
  -> config/runtime.sh
  -> config/env (optional)
  -> zimfw init (zsh)
  -> config/aliases
  -> config/manifest.sh
  -> config/plugins/*/init.sh
```

## Tooling

- Local checks: `make check`
- Markdown lint in `make check`: `npx markdownlint-cli2` (latest by default)
- Native git hook: `.githooks/pre-commit` (installed with `make hooks-install`)
- CI: `.github/workflows/ci.yml` runs `make check` and bats smoke tests
- Smoke tests: `tests/*.bats`

## Design Invariants

- Keep installer and runtime concerns separate
- Keep shell scripts POSIX-`sh` compatible
- Keep plugin loading opt-in via `DOTFILES_ENABLE_*`
- Prefer explicit failures with actionable messages
