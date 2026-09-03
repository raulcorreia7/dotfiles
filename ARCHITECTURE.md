# Dotfiles Architecture

## Overview

This repository separates pure configuration from OS package installation:

- `install/`: pure-configuration installer (linking, tools, post-install config)
- `packages/`: standalone OS package installer, never invoked by `install/`
- `config/` + `init.sh`: runtime layer (interactive shell behavior)

The configuration installer never installs OS packages. The package installer
never touches dotfiles. Runtime depends on the installer only via `rdf refresh` → `install/link.sh`; otherwise it never depends on installer internals. The package installer shares `install/lib.sh` for logging and OS detection.

## Entrypoints

- `install/install.sh`: pure-configuration installer
- `install/uninstall.sh`: restore backups created during setup
- `packages/install.sh`: standalone OS package installer
- `init.sh`: runtime entrypoint sourced by shell rc files

## Configuration Installer (`install/`)

- `install.sh`: single-stage runner; runs `check -> setup -> tools -> configure` inline
- `lib.sh`: logging, path helpers, user context, dependency guards, OS detection
- `config.sh`: path configuration
- `link.sh`: symlink orchestration using GNU Stow plus bridges for Codex-managed files
- `post-install.sh`: shell, PATH, desktop, login-screen, and git defaults
- `desktop-defaults.sh`: targeted KDE shortcuts and XDG application defaults
- `uninstall.sh`: backup restore

Install flow:

```text
install/install.sh
  check      shell, git, stow, dotfiles structure
  setup      link.sh (GNU Stow)
  tools      mise, zimfw, nvim plugins, rtk (each opt-out via DOTFILES_ENABLE_*)
  configure  post-install.sh
```

## Package Installer (`packages/`)

- `install.sh`: standalone dispatcher (arch/macos), run manually
- `install-arch.sh`: pacman + AUR via paru
- `install-macos.sh`: Homebrew bundle categories
- `install-windows.ps1`: manual Windows setup
- `arch/`, `macos/`, `windows/`: package lists

## Runtime Layer (`init.sh`, `config/`)

- `init.sh`: runtime bootstrap, env load, zimfw init, aliases, manifest
- `config/runtime.sh`: public runtime API and `rdf` command
- `config/manifest.sh`: plugin registration order
- `config/plugins/*/init.sh`: isolated plugin integration points
- `config/agents/`: shared guidance, skills, references, templates, and catalog exposed through `~/.agents`
- `config/codex/`: managed Codex config, command rules, and custom agents linked into `~/.codex`
- `config/nvim/lua/plugins/theme-browser.lua`: minimal `lazy.nvim` plugin spec
- `config/nvim/lua/config/theme-browser.lua`: theme-browser runtime config and local dev toggle

## Runtime Public API

### Commands

- `rdf reload`
- `rdf edit`
- `rdf sync`
- `rdf refresh` (re-runs `install/link.sh`, then reloads)
- `rdf health [tools|dirs|links|git|all]`
- `rdf update [--full]` (Arch)
- `rdf orphans [--remove]` (Arch)
- `rdf cache [--clean]` (Arch)

### Functions

- `dot_has <cmd>`
- `dot_shell_type`
- `dot_eval_init <tool>`
- `dot_load_plugin <plugin>`

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

- Keep configuration install and package install in separate folders; `install/` never invokes `packages/`
- Keep shell scripts POSIX-`sh` compatible
- Keep plugin and tool loading gated via `DOTFILES_ENABLE_*` (default on, set to `0` to skip)
- Prefer explicit failures with actionable messages
- Preserve an existing `~/.agents` as a numbered backup before installing the managed link
- Keep OpenCode minimal; shared guidance lives in `config/agents`, while Codex command-approval `.rules` files live in `config/codex/rules`
- Keep Neovim plugin specs declarative; put local dev/runtime behavior in adjacent config modules
