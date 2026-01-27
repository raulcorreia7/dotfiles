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
├── config/          # app configs + shell modules/plugins
├── installers/      # link + OS installers
├── scripts/         # legacy loader (compat)
├── bin/             # user scripts -> ~/.local/bin
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
│  └─ plugins/* (mise, fzf, zoxide, tmux, os/arch)
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
       ├─ config/env
       ├─ config/shell/core.sh
       ├─ config/loaders/manifest.sh
       │    └─ config/plugins/*
       ├─ zimfw init (zsh)
       └─ config/aliases
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

## Knobs

- `DOTFILES_DEBUG=1` log what `init.sh` sources
- `DOTFILES_ENABLE_FZF=0` disable fzf plugin (same for ZOXIDE, TMUX, OS_ARCH)
- `DOTFILES_MISE_INSTALL=0` skip `mise install`
- `DOTFILES_ZIMFW_BUILD=0` skip `zimfw build`
- `DOTFILES_POST_INSTALL=0` skip post-install setup
- `DOTFILES_POST_INSTALL_ZSH=0` skip setting zsh as default
- `DOTFILES_POST_INSTALL_PATH=0` skip adding `~/.local/bin` to PATH
- `DOTFILES_POST_INSTALL_XDG_DIRS=0` skip creating XDG dirs
- `DOTFILES_POST_INSTALL_GIT=0` skip git defaults (including side-by-side diffs)
- `DOTFILES_ARCH_ASSUME_YES=1` pacman/paru non-interactive
- `DOTFILES_TMUX_AUTOSTART=0` disable tmux autostart
- `DOTFILES_TMUX_SESSION=...` set tmux session name
