# dotfiles

Personal dotfiles, kept small and clone-and-run:

- `setup` — the one entry script (packages → links → rc)
- `dotconfigs/` — the GNU Stow tree; it mirrors `$HOME`
- `packages/` — flat package lists, one file per profile and OS
- `bin/` — scripts we own, linked into `~/.local/bin`
- `init.sh` — the one shell runtime file (sourced by the rc block)
- `zimfw/` — vendored zsh framework used by the runtime

## Quick start

```sh
git clone https://github.com/raulcorreia7/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./setup            # asks for a profile, installs packages, links configs, writes rc
exec zsh
```

Requirements are minimal by design: `git` and a shell. The base package
lists carry `git`, `stow`, and `zsh`; on macOS install Homebrew first
(<https://brew.sh> — `setup` stops and prints the one-liner if it is missing).

## What `setup` does

1. resolves its own path — clone it anywhere, nothing assumes `~/.dotfiles`
2. reads `packages/base-<os>` + `packages/<profile>-<os>` and installs them
3. stows `dotconfigs/` into `$HOME` (conflicting real files are backed up to `*.bak`)
4. links `bin/base/` + `bin/<profile>/` into `~/.local/bin`
5. writes a marker block into `~/.zshrc` (and `~/.bashrc` if present)

| Command | Effect |
|---|---|
| `./setup` | full run: packages → links → rc |
| `./setup --packages` | packages only |
| `./setup --links` | links + rc only |
| `./setup uninstall` | removes links/rc block, restores backups |
| `./setup configure` | opt-in desktop/git defaults (XDG dirs, git, KDE) |

Flags: `-n`/`--dry-run`, `-p`/`--profile <name>`, `-h`/`--help`.

## Layout

```
setup                # entry script: run · uninstall · configure
init.sh              # shell runtime (env, aliases, tool inits, zimfw)
packages/            # base-pacman · personal-macos · work-pacman · …
bin/base/            # scripts on every machine (→ ~/.local/bin)
bin/<profile>/       # profile-only scripts
dotconfigs/.config/  # stow tree: alacritty · ghostty · mise · nvim · tmux
zimfw/               # vendored zsh framework (modules + .zimrc)
```

## Profiles

A profile is a machine class (`personal`, `work`, …). It selects packages and
bin scripts only — the config tree is shared. Add one by creating
`packages/<profile>-<os>` files for the OSes that class uses; missing files
are skipped.

## Maintenance

```sh
git pull                                  # sync the clone
./setup --links                           # re-link after adding/removing configs or bin scripts
exec zsh                                  # reload the shell
stow --dir="$DOTFILES_DIR" --target="$HOME" --simulate --restow dotconfigs   # check links without changing anything
```

`setup` is switches-only — no environment knobs. Machine-local shell settings
(what `init.sh` sources at startup) go in `env.local` at the repo root
(gitignored).
Add an app: drop `dotconfigs/.config/<app>/` in place and run `./setup --links`.

## Notes

- Stow uses folding: if `~/.config/<app>` does not exist yet, it becomes one
  symlink to the repo dir; generated app state (nvim locks, alacritty themes,
  tmux plugins) may land in the clone but is gitignored.
- Moved the clone? Run `./setup` again — the rc block is rewritten with the
  new path.
