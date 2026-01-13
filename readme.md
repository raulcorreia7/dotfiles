# dotfiles

Personal dotfiles for zsh, focusing on modern tooling and efficient workflows.

## Layout

```
dotfiles/
├── config/          # Configuration files
│   ├── aliases      # Command aliases
│   └── env          # Environment variables
├── scripts/         # Helper functions
│   ├── fzf.sh       # FZF integration
│   ├── git.sh       # Git helpers
│   └── tools.sh     # Utilities
├── bin/             # Optional executables
├── init.sh          # Entrypoint (sourced by shell)
└── install.sh       # Symlink helper
```

## Installation

1. Clone repository:
```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
```

2. Install dependencies:

**For minimal setup (dotfiles only):**
```sh
brew bundle --file=packages/brew/Brewfile.base
```

**For complete development system:**
```sh
brew bundle --file=packages/brew/Brewfile
```

See `packages/brew/README.md` for modular installation options.

3. Run the install script:
```sh
cd ~/.dotfiles
./install.sh
```

4. Source init.sh from your shell config:

**For zsh:** Add to `~/.zshrc`
**For bash:** Add to `~/.bashrc`

```sh
[ -r "$HOME/.dotfiles/init.sh" ] && . "$HOME/.dotfiles/init.sh"
```

## What it Links
The install script creates:
- `config/` → `~/.config/dotfiles/`
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

For optimal performance, install modern replacements:

```sh
# macOS
brew install fzf fd ripgrep bat eza delta

# Linux
# Check package manager for these tools
```

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
