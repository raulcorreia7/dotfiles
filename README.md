# dotfiles

Minimal, XDG-first dotfiles with one shell entrypoint, explicit linking, and optional package installs.

## Quickstart

```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
~/.dotfiles/install
```

Or for a minimal setup:

```sh
~/.dotfiles/lib/install/link.sh
```

Add to your shell config:

```sh
[ -r "$HOME/.dotfiles/init.sh" ] && . "$HOME/.dotfiles/init.sh"
```

`init.sh` ensures `~/.local/bin` is on PATH by default. Disable with
`DOTFILES_POST_INSTALL_PATH=0`.

## Directory Structure

```
.dotfiles/
├── init.sh              # Shell entrypoint
├── install              # Main installer
│
├── before/              # Early setup (first to load)
│   ├── env.sh          # Environment variables
│   └── paths.sh        # Path definitions
│
├── lib/                 # Core libraries
│   ├── init.sh         # Main loader
│   ├── loader.sh       # Plugin loading system
│   ├── utils.sh        # Helper functions
│   ├── health.sh       # Health check functions
│   ├── manifest.sh     # Module manifest
│   └── install/        # Install helpers
│       ├── lib.sh
│       ├── link.sh
│       ├── unlink.sh
│       └── post-install.sh
│
├── modules/             # Feature modules (lazy-loaded)
│   ├── mise/           # Runtime version manager
│   ├── fzf/            # Fuzzy finder
│   ├── zoxide/         # Smart cd
│   ├── zimfw/          # Zsh module manager
│   ├── tmux/           # Terminal multiplexer
│   └── arch/           # Arch Linux helpers
│
├── os/                  # Platform-specific
│   ├── helpers/        # Runtime helpers (arch.sh, linux.sh, wsl.sh, macos.sh)
│   └── install/        # OS installers (arch.sh, macos.sh, windows.ps1)
│
├── after/               # Late loading (last)
│   ├── aliases.sh      # Shell aliases
│   └── local.sh        # Machine-specific (gitignored)
│
├── config/              # XDG-linked app configs (nvim, tmux, alacritty, ...)
├── bin/                 # Public scripts -> ~/.local/bin/
└── scripts/             # Internal/dev tools (lint.sh, format.sh)
```

**Load Order**: `before/` → `lib/` → `modules/` (lazy) → `os/` → `after/`

## Installation

### Fresh install (full)

```sh
cd ~/.dotfiles
./install
```

What `./install` does:

- Links configs via `lib/install/link.sh`
- Installs OS packages
- Optionally runs `mise install` and `zimfw install/build`
- Runs post-install setup (default: enabled)

### Fresh install (minimal)

```sh
lib/install/link.sh
./bin/rdotfiles fix --zimfw
```

## Usage

### Daily use

Open a shell (sources `init.sh`).

Note: if `rdotfiles` is not on your PATH yet, run `./bin/rdotfiles ...` from the repo.

### Update (fast)

```sh
rdotfiles update
```

### Update + health + fix

```sh
rdotfiles update --fix
```

### rdotfiles commands

Single entrypoint for dotfiles maintenance:

```sh
rdotfiles setup
rdotfiles link
rdotfiles health
rdotfiles fix --zimfw
rdotfiles update --health
rdotfiles update --fix
rdotfiles unlink
```

Aliases: `df` → `rdotfiles`, `dotreload` → `rdotfiles reload`, `dotdoctor` → `rdotfiles health`, `nvcfg` → open Neovim config.

### Uninstall

Remove dotfiles symlinks:

```sh
rdotfiles unlink
```

## Documentation

Detailed documentation is available in the [`docs/`](docs/) directory:

For component-specific documentation, see the README files in each directory:

- [`bin/README.md`](bin/README.md) - User scripts and utilities
- [`config/README.md`](config/README.md) - XDG app configs (nvim, tmux, etc.)
- [`docs/reference/install.md`](docs/reference/install.md) - Installation scripts reference
- [`scripts/README.md`](scripts/README.md) - Development scripts (lint, format)

## Knobs

### General

- `DOTFILES_DEBUG=1` - log what `init.sh` sources

### Module Enable/Disable

- `DOTFILES_ENABLE_ZIMFW=0` - disable zimfw module
- `DOTFILES_ENABLE_FZF=0` - disable fzf module
- `DOTFILES_ENABLE_ZOXIDE=0` - disable zoxide module
- `DOTFILES_ENABLE_TMUX=0` - disable tmux module
- `DOTFILES_ENABLE_ARCH=0` - disable Arch-specific OS module

### Install Options

- `DOTFILES_MISE_INSTALL=0` - skip `mise install`
- `DOTFILES_ZIMFW_INSTALL=0` - skip `zimfw install`
- `DOTFILES_ZIMFW_BUILD=0` - skip `zimfw build`
- `DOTFILES_ZIMFW_DOWNLOAD=0` - skip zimfw download fallback
- `DOTFILES_POST_INSTALL=0` - skip post-install setup
- `DOTFILES_ARCH_ASSUME_YES=1` - pacman/paru non-interactive

### Post-Install Options

- `DOTFILES_POST_INSTALL_ZSH=0` - skip setting zsh as default
- `DOTFILES_POST_INSTALL_PATH=0` - skip adding `~/.local/bin` to PATH (init.sh)
- `DOTFILES_POST_INSTALL_XDG_DIRS=0` - skip creating XDG dirs
- `DOTFILES_POST_INSTALL_GIT=0` - skip git defaults (including side-by-side diffs)

### Tmux Options

- `DOTFILES_TMUX_AUTOSTART=0` - disable tmux autostart
- `DOTFILES_TMUX_SESSION=...` - set tmux session name

## Development

### Lint/Format

Run the lint script to check and fix code style:

```sh
./scripts/lint.sh
./scripts/format.sh
```

Exclude paths by editing `before/paths.sh`:

- `DOTFILES_EXCLUDE_DIRS` (space-separated)
- `DOTFILES_EXCLUDE_FILES` (space-separated)

### Testing Changes

After making changes, test with:

```sh
# Syntax check
sh -n init.sh
sh -n lib/loader.sh

# Reload in current shell
source "$HOME/.dotfiles/init.sh"
```

## License

MIT
