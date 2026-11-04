# dotfiles

Personal dotfiles, managed with [chezmoi](https://www.chezmoi.io). Files in `home/`
are copied into `$HOME`; no symlinks.

## Install

```sh
git clone https://github.com/raulcorreia7/dotfiles.git   # anywhere
./dotfiles/install.sh
```

This installs chezmoi if needed, asks once for the host name, profile (`personal` or
`work`) and git identity, installs packages, and copies the files. The answers stay on the
machine, in `~/.config/chezmoi/chezmoi.toml`; edit that file to change one later.

To see what would change before anything is written, install chezmoi yourself, run
`chezmoi init --source ./dotfiles`, then `chezmoi diff` (and `chezmoi apply` when happy).

## Use

| Task | Command |
| --- | --- |
| See how this machine differs from the repo | `chezmoi diff` |
| Update everything to the latest | `dotfiles-update` |
| Install repo changes after `git pull` | `chezmoi apply` |
| Edit a managed file | `chezmoi edit <file>`, then `chezmoi apply` |
| Take an edit made in `$HOME` back into the repo | `chezmoi re-add` |
| Open the repo | `chezmoi cd` |

After `re-add`, review `git diff` and commit what is shared.

## Layout

```
install.sh                      bootstrap
.chezmoiroot                    source state is home/
home/
  .chezmoi.toml.tmpl            the questions asked once per machine
  .chezmoidata/packages.yaml    packages by manager and profile
  .chezmoidata/hosts.yaml       extra packages per host
  .chezmoiexternal.toml.tmpl    zimfw, alacritty themes, tpm: fetched, not stored
  .chezmoiignore                what a profile or OS skips
  .chezmoitemplates/            shared template snippets
  .chezmoiscripts/              packages, runtimes, font cache, KDE defaults
  dot_config/shell/             shell runtime and prompt
  dot_config/<app>/             app configs
  private_dot_ssh/              ssh defaults; no hosts
  dot_local/bin/                our scripts: dotfiles-update, yeti-monitor
```

Names: `dot_x` is `.x`; `private_`, `executable_`, `modify_` and `.tmpl` set how a file is installed.

## Machines

| Host | OS | Profile |
| --- | --- | --- |
| `talos` | Arch | personal |
| `p14s` | Arch | personal |
| `rcorreia-milence-laptop` | Ubuntu | work |

Each machine has what its profile has. To add packages for one machine only, put them under
its name in `home/.chezmoidata/hosts.yaml`.

## SSH

The repo never holds hosts. `~/.ssh/config` gets one line, `Include ~/.ssh/config.d/*`, and
shared defaults live in `config.d/zz-defaults`. Put each machine's own entries in
`~/.ssh/config.d/hosts` yourself; chezmoi leaves that file alone.

## Tools

Use the OS package manager first (`home/.chezmoidata/packages.yaml`). Where upstream runs its
own apt repository and it beats the distro (gh, eza, mise), that repository is added too. Only
where a manager has no package does `mise` supply the tool: today that is neovim, gitui and
difftastic on apt, while Arch and Homebrew install them natively. Runtimes (node, go, python,
rust, ...) always come from `mise` (`home/dot_config/mise/config.toml.tmpl`).

Nothing is pinned. zimfw, its modules, the terminal font, the alacritty themes and tmux
plugins are fetched from upstream's latest (`home/.chezmoiexternal.toml.tmpl`) and refreshed
weekly by `chezmoi apply`, or at once by `dotfiles-update`.

## Changing things

- **App config:** `chezmoi add <file>`.
- **Tool:** add it to `home/.chezmoidata/packages.yaml`, under each manager that has it. If
  apt lacks it, list it under `packages.mise.apt` too.
- **Runtime:** add it to the mise config.
- **Script:** `home/dot_local/bin/executable_<name>`.
- **Machine-local shell setting:** `~/.config/shell/env.local`, which is not managed.
