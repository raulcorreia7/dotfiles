# dotfiles

Minimal, XDG‑first dotfiles with a single shell entrypoint, explicit linking, and optional package install.

## What it does

- Keeps app configs in `~/.dotfiles/config` and links them into `~/.config`.
- Loads shell helpers from `~/.dotfiles/config` via `init.sh`.
- Optionally installs OS packages with `./install` (Arch/macOS).

## Clone + setup

```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
~/.dotfiles/installers/link.sh
```

Wire the shell (zsh example):

```sh
[ -r "$HOME/.dotfiles/init.sh" ] && . "$HOME/.dotfiles/init.sh"
```

## Install (full)

```sh
cd ~/.dotfiles
./install
```

`./install` runs `installers/link.sh` and then OS‑specific package installs:
- Arch/CachyOS: `installers/install-arch.sh`
- macOS: `installers/install-macos.sh`
- Windows: prints the PowerShell command to run

## Layout (relevant)

```
.dotfiles/
├── config/          # app configs + shell modules/plugins
├── scripts/         # legacy loader (compat)
├── installers/      # install + link helpers
├── bin/             # personal scripts -> ~/.local/bin
└── init.sh          # shell entrypoint
```

## Shell init flow (init.sh)

```
~/.zshrc
  └─ source ~/.dotfiles/init.sh
       ├─ config/env
       ├─ config/shell/core.sh
       ├─ config/loaders/manifest.sh
       │    └─ config/plugins/* (mise, fzf, zoxide, tmux, os/arch)
       ├─ zimfw init (if zsh)
       └─ config/aliases
```

## Link flow (installers/link.sh)

```
link.sh
  ├─ ensure dirs (~/.config, ~/.local/bin)
  ├─ for each app config: nvim, tmux, mise, zimfw
  │    ├─ if dest exists and is not a symlink -> backup with timestamp
  │    └─ symlink src -> ~/.config/<app>
  └─ for each file in bin/ -> ~/.local/bin/<file>
```

## Install flow (./install)

```
install
  ├─ detect OS
  ├─ run installers/link.sh
  ├─ run OS installer
  │    ├─ Arch/CachyOS -> installers/install-arch.sh
  │    └─ macOS        -> installers/install-macos.sh
  └─ print reload note
```

## Additional knobs

- `DOTFILES_DEBUG=1` to log what `init.sh` sources.
- `DOTFILES_ENABLE_FZF=0`, `DOTFILES_ENABLE_ZOXIDE=0`, `DOTFILES_ENABLE_TMUX=0`, `DOTFILES_ENABLE_OS_ARCH=0` to disable plugins.
- `DOTFILES_MISE_INSTALL=0` to skip `mise install` during `./install`.
- `DOTFILES_ZIMFW_BUILD=0` to skip `zimfw build` during `./install`.
- `DOTFILES_ARCH_ASSUME_YES=1` to run Arch updates without confirmation prompts.
- `DOTFILES_TMUX_AUTOSTART=0` to disable tmux autostart.
- `DOTFILES_TMUX_SESSION=...` to force a tmux session name.
