# dotfiles

Personal dotfiles for zsh, focusing on modern tooling and efficient workflows.

## Layout

```
dotfiles/
├── config/          # Configuration files
│   ├── aliases      # Command aliases
│   └── env          # Environment variables
├── scripts/         # Helper functions
│   ├── bootstrap.sh # Bootstraps package managers (Homebrew, paru)
│   ├── fzf.sh       # FZF integration
│   ├── git.sh       # Git helpers
│   └── tools.sh     # Utilities
├── packages/        # OS-specific package lists
│   ├── macos/       # Homebrew packages (base/cli/development/gui)
│   ├── arch/        # pacman/AUR packages (base/cli/development/gui)
│   └── windows/     # choco/scoop/winget packages (base/cli/development/gui)
├── bin/             # Optional executables
├── init.sh          # Entrypoint (sourced by shell)
└── install.sh       # OS-aware installer dispatcher
```

## Installation

1. Clone repository:
```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
```

2. Run the OS-aware installer:

**macOS:**
```sh
cd ~/.dotfiles
./install.sh
```
- Auto-detects macOS
- Bootstraps Homebrew (if missing)
- Installs packages from packages/macos/ (base → cli → development → gui)

**Arch/CachyOS:**
```sh
cd ~/.dotfiles
./install.sh
```
- Auto-detects Arch/CachyOS
- Installs pacman packages from packages/arch/
- Bootstraps paru AUR helper
- Installs AUR packages

**Windows:**
```pwsh
pwsh -ExecutionPolicy Bypass -File scripts/install-windows.ps1
```
- Supports choco, scoop, or winget package managers
- Installs packages from packages/windows/

3. Source init.sh from your shell config:

**For zsh:** Add to `~/.zshrc`
**For bash:** Add to `~/.bashrc`

```sh
[ -r "$HOME/.dotfiles/init.sh" ] && . "$HOME/.dotfiles/init.sh"
```

## What it Links
The install script creates:
- `config/` → `~/.config/.dotfiles/`
- `bin/*` → `~/.local/bin`

## Scripts

**FZF Snacks (fzf.sh)**
- Unified fuzzy finder for files, git, projects, and content search
- Supports multiple modes with live preview
- See `fzfs --help` for usage

**Git Helpers (git.sh)**
- Safe git cleanup with confirmation
- Prevents accidental destructive operations

**Utilities (tools.sh)**
- Tool availability diagnostics
- Config helpers

## Configuration

Edit `config/env` for environment variables:

```sh
# Editor
export EDITOR=nvim

# FZF options
export FZFS_PROJECT_ROOTS="$HOME/personal"
export FZFS_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/fzfs"
```

## Recommended Tools

Modern tools are installed automatically via the OS-specific installers. Package lists are organized by category:

- **base:** Core system tools
- **cli:** Command-line utilities
- **development:** Development environments
- **gui:** Desktop applications

See packages/{macos,arch,windows}/ for package details.

**Why modern tools?**
- **fd** - Faster than `find`
- **ripgrep (rg)** - Faster than `grep`
- **bat** - Syntax highlighting
- **eza** - Enhanced `ls`
- **delta** - Better git diffs

## Usage

Reload dotfiles after changes:
```sh
dotreload
```

Check tool availability:
```sh
dotdoctor
```
