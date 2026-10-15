# AGENTS.md — dotfiles

Notes for anyone changing this repo: what it is, what each part owns, where a
change goes, and the rules that keep it simple.

## What this project is

A personal dotfiles repo. Clone it and run `./setup`; that is the whole
installation story. There is no build step, no test suite, no CI, and no
linter. `setup` and `init.sh` are the only tooling, by design.

`setup` wires one machine:

1. installs the packages listed in `packages/`
2. stows `dotconfigs/` into `$HOME`
3. links `bin/` scripts into `~/.local/bin`
4. writes a marker block into `~/.zshrc` and `~/.bashrc`

`init.sh` is the runtime those rc files source on every shell start.

## What each part owns

| Path | Responsibility |
| --- | --- |
| `setup` | wiring a machine — the only entry point (run · uninstall · configure) |
| `init.sh` | the shell runtime: environment, aliases, tool init, prompt, zimfw |
| `dotconfigs/` | the GNU Stow tree; it mirrors `$HOME` one level deep (`.config/…`) |
| `packages/` | package lists, one file per profile and OS |
| `bin/` | scripts we own; linked into `~/.local/bin` |
| `zimfw/` | the vendored zsh framework used by `init.sh` |

## Folder structure

```
setup                   # entry script: run · uninstall · configure
init.sh                 # shell runtime, sourced by the rc block
packages/
  base-pacman           # every Arch machine
  base-aur              # AUR packages (Arch)
  base-apt              # Debian/Ubuntu
  base-macos            # Homebrew Brewfile
  personal-pacman       # lists for one profile
  work-macos
bin/
  base/                 # scripts on every machine
  personal/             # scripts for one profile
dotconfigs/.config/     # stow tree: alacritty · ghostty · mise · nvim · tmux
zimfw/                  # vendored modules and .zimrc
```

## Where a change goes

- New app config: add `dotconfigs/.config/<app>/`, then run `./setup --links`.
- New package: add it to the file for each profile and OS that needs it. Keep
  the `base-*` lists minimal.
- New script: put it in `bin/base/` or `bin/<profile>/`; the next
  `./setup --links` links it.
- New profile: create `packages/<profile>-<os>` files. A profile selects
  packages and bin scripts only; the config tree is shared.
- Machine-local setting: put it in `env.local` at the repo root. `init.sh`
  sources that file; it is gitignored and never committed.

## Rules

- Keep it simple. Prefer removing code over adding an abstraction, and do not
  add tooling, CI, or tests to this repo.
- The clone location must not matter. Nothing may assume the repo lives at
  `~/.dotfiles`.
- Commit shared config, not machine state. Ignore caches and generated files in
  the closest `.gitignore`, such as `dotconfigs/.config/tmux/.gitignore` for
  `plugins/`; keep the root `.gitignore` for repo-wide patterns only.
- `setup` reads no environment variables. Every option is a switch, so a run is
  repeatable and nothing hidden changes it.
- Never remove a file the repo does not own. `setup` backs up conflicts as
  `*.bak` and `setup uninstall` restores them.
- Assume a fresh machine. Every package the runtime needs must appear in a
  `base-*` list.

## Check a change

```sh
sh -n setup && sh -n init.sh
./setup -n --profile personal
stow --dir="$DOTFILES_DIR" --target="$HOME" --simulate --restow dotconfigs
```
