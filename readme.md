# dotfiles

Personal dotfiles for zsh, focusing on modern tooling and efficient workflows.

## Layout

```
dotfiles/
├── config/          # XDG configuration files
│   ├── aliases      # Command aliases
│   ├── env          # Environment variables
│   ├── .zimrc       # Zim configuration
│   ├── zimfw/       # Zim framework (generated + modules)
│   ├── tmux/        # Tmux configuration
│   ├── nvim/        # Neovim configuration
│   ├── mise/        # Mise (version manager) configuration
│   ├── kitty/       # Kitty terminal configuration
│   └── gh/          # GitHub CLI configuration
├── scripts/         # Runtime shell helpers (sourced by init.sh)
│   ├── fzf.sh       # FZF integration
│   ├── fzf-bindings.sh
│   ├── fzfs_callbacks.sh
│   ├── os-arch.sh   # Arch runtime helpers
│   ├── tools.sh     # Utilities
│   └── zoxide.sh
├── install/         # OS installers + linker
│   ├── install.sh
│   ├── install-linux.sh
│   ├── install-macos.sh
│   ├── install-windows.ps1
│   ├── config.sh
│   └── link.sh
├── packages/        # OS-specific package lists
│   ├── macos/       # Homebrew packages (base/cli/development/gui)
│   ├── arch/        # pacman/AUR packages (base/cli/development/gui)
│   └── windows/     # choco/scoop/winget packages (base/cli/development/gui)
├── bin/             # Optional executables (linked to ~/.local/bin)
├── init.sh          # Entrypoint (sourced by shell)
└── install.sh       # Symlink to install/install.sh
```

## Installation

1. Clone repository:
```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
```

2. Run OS-aware installer:

**macOS:**
```sh
cd ~/.dotfiles
./install.sh
```
- Auto-detects macOS
- Installs packages from packages/macos/ (base → cli → development → gui)

**Arch/CachyOS:**
```sh
cd ~/.dotfiles
./install.sh
```
- Auto-detects Linux
- Installs pacman packages from packages/arch/ (Arch/CachyOS only)
- Bootstraps paru AUR helper
- Installs AUR packages

**Windows:**
```pwsh
pwsh -ExecutionPolicy Bypass -File install/install-windows.ps1
```
- Supports choco, scoop, or winget package managers
- Installs packages from packages/windows/

3. Source init.sh from your shell config:

**For zsh:** Add to `~/.zshrc`
**For bash:** Add to `~/.bashrc`

```sh
[ -r "$HOME/.dotfiles/init.sh" ] && . "$HOME/.dotfiles/init.sh"
```

## Usage

Reload shell configuration:
```sh
exec zsh
```

Check tool availability:
```sh
dotdoctor
```
