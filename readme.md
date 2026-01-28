# dotfiles

Minimal, XDG-first dotfiles with one shell entrypoint, explicit linking, and optional package installs.

## Quickstart

```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
~/.dotfiles/installers/link.sh
```

Add to your shell config:

```sh
[ -r "$HOME/.dotfiles/init.sh" ] && . "$HOME/.dotfiles/init.sh"
```

## Install

```sh
cd ~/.dotfiles
./install
```

What `./install` does:

- Links configs via `installers/link.sh`
- Installs OS packages
- Optionally runs `mise install` and `zimfw build`
- Runs post-install setup (default: enabled)

## Layout

```
.dotfiles/
├── config/          # app configs + shell modules/plugins ([README](config/README.md))
├── installers/      # link + OS installers ([README](installers/README.md))
├── installers/      # Link + OS installers + package lists ([README](installers/README.md))
├── scripts/         # legacy loader (compat) ([README](scripts/README.md))
├── bin/             # user scripts -> ~/.local/bin ([README](bin/README.md))
└── init.sh          # shell entrypoint
```

## Mindmap: Structure

```
.dotfiles
├─ config
│  ├─ alacritty, ghostty, nvim, tmux, mise, zimfw
│  ├─ env
│  ├─ shell/core.sh
│  ├─ loaders/manifest.sh
│  ├─ plugins/* (mise, fzf, zoxide, tmux, zimfw, arch)
│  └─ paths.sh       # centralized path definitions
├─ installers
│  ├─ link.sh
│  ├─ install-arch.sh
│  ├─ install-macos.sh
│  └─ install-windows.ps1

├─ bin
└─ init.sh
```

## Mindmap: Flows

Shell init:

```
~/.zshrc
  └─ source ~/.dotfiles/init.sh
       ├─ config/paths.sh       # load centralized paths
       ├─ config/env            # user environment overrides
       ├─ config/shell/core.sh  # core functions + plugin loader
       ├─ config/loaders/manifest.sh
       │    └─ config/plugins/* # load enabled plugins
       └─ config/aliases        # shell aliases
```

Linking:

```
installers/link.sh
  ├─ ensure ~/.config + ~/.local/bin
  ├─ link app configs -> ~/.config/<app>
  └─ link bin/* -> ~/.local/bin/*
```

Install:

```
./install
  ├─ detect OS
  ├─ run installers/link.sh
  ├─ run OS installer
  ├─ run mise install (optional)
  ├─ run zimfw build (optional)
  └─ run post-install (optional)
```

## Documentation

Detailed documentation for specific components:

- [`bin/README.md`](bin/README.md) - User scripts and utilities
- [`config/README.md`](config/README.md) - App configs, shell modules, and plugins
- [`installers/README.md`](installers/README.md) - Link and OS installers

- [`scripts/README.md`](scripts/README.md) - Legacy loader and development scripts

## Commands

### dot_reload

Reload dotfiles configuration without restarting shell:

```sh
dot_reload
```

### dot_status

Show dotfiles loading status (paths, shell type, loaded plugins):

```sh
dot_status
```

### dot_doctor

Check if required tools are installed:

```sh
dot_doctor
```

## Knobs

### General

- `DOTFILES_DEBUG=1` - log what `init.sh` sources

### Plugin Enable/Disable

- `DOTFILES_ENABLE_ZIMFW=0` - disable zimfw plugin
- `DOTFILES_ENABLE_FZF=0` - disable fzf plugin
- `DOTFILES_ENABLE_ZOXIDE=0` - disable zoxide plugin
- `DOTFILES_ENABLE_TMUX=0` - disable tmux plugin
- `DOTFILES_ENABLE_ARCH=0` - disable Arch-specific OS plugin

### Install Options

- `DOTFILES_MISE_INSTALL=0` - skip `mise install`
- `DOTFILES_ZIMFW_BUILD=0` - skip `zimfw build`
- `DOTFILES_POST_INSTALL=0` - skip post-install setup
- `DOTFILES_ARCH_ASSUME_YES=1` - pacman/paru non-interactive

### Post-Install Options

- `DOTFILES_POST_INSTALL_ZSH=0` - skip setting zsh as default
- `DOTFILES_POST_INSTALL_PATH=0` - skip adding `~/.local/bin` to PATH
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
```

### Testing Changes

After making changes, test with:

```sh
# Syntax check
sh -n init.sh
sh -n config/shell/core.sh

# Reload in current shell
dot_reload

# Check status
dot_status
```
