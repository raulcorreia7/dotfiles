# dotfiles

Personal dotfiles, kept small and clone-and-run:

- `setup` — the one entry script (packages → files → rc)
- `dotconfigs/` — config files, laid out as they sit in `$HOME`; copied, not linked
- `packages/` — flat package lists, one file per profile and OS
- `bin/` — scripts we own, copied into `~/.local/bin`
- `init.sh` — the one shell runtime file (sourced by the rc block)
- `zimfw/` — vendored zsh framework used by the runtime

## Quick start

```sh
git clone https://github.com/raulcorreia7/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./setup            # asks for a profile, installs packages, copies configs, writes rc
exec zsh
```

Requirements are minimal by design: `git` and a shell. The base package
lists carry `git` and `zsh`; on macOS install Homebrew first
(<https://brew.sh> — `setup` stops and prints the one-liner if it is missing).

## What `setup` does

1. resolves its own path — clone it anywhere, nothing assumes `~/.dotfiles`
2. reads `packages/base-<os>` + `packages/<profile>-<os>` and installs them
3. copies `dotconfigs/` into `$HOME`: missing files are added, files you changed are kept
4. copies `bin/base/` + `bin/<profile>/` into `~/.local/bin`
5. writes a marker block into `~/.zshrc` (and `~/.bashrc` if present)

| Command | Effect |
|---|---|
| `./setup` | full run: packages → files → rc |
| `./setup --packages` | packages only |
| `./setup --files` | files + rc only |
| `./setup --files --force` | also replace files you changed (backed up to `*.bak`) |
| `./setup diff` | show where this machine differs from the repo |
| `./setup save` | copy this machine's edits into the repo, to review and commit |
| `./setup uninstall` | removes the rc block and old symlinks; copied files stay |
| `./setup configure` | opt-in desktop/git defaults (XDG dirs, git, KDE) |

Flags: `-n`/`--dry-run`, `-p`/`--profile <name>`, `-f`/`--force`, `-h`/`--help`.

## Layout

```
setup                # entry script: run · uninstall · configure
init.sh              # shell runtime (env, aliases, tool inits, zimfw)
packages/            # base-pacman · personal-macos · work-pacman · …
bin/base/            # scripts on every machine (→ ~/.local/bin)
bin/<profile>/       # profile-only scripts
dotconfigs/          # mirrors $HOME: .alias · .config/{alacritty,ghostty,mise,nvim,opencode,tmux} · .omp
zimfw/               # vendored zsh framework (modules + .zimrc)
```

## Profiles

A profile is a machine class (`personal`, `work`, …). It selects packages and
bin scripts only — the config tree is shared. Add one by creating
`packages/<profile>-<os>` files for the OSes that class uses; missing files
are skipped.

## Maintenance

```sh
git pull && ./setup --files     # take new repo files: copies you never edited update, edited ones are kept
./setup diff                    # what differs here
./setup save                    # bring this machine's edits into the repo
git diff && git commit          # share what should be shared; git checkout -- the rest
```

Each machine has its own copies, so one machine can differ (omp models, mise tools) without
affecting the others. Nothing changes until you run `setup`, `save`, or `--force`.

How `setup` tells an old copy from an edited one: a file whose content equals any earlier
committed version of that path is an unedited older copy, so `setup` updates it. Anything else
you changed stays, with a warning. `setup save` skips older copies, so it can never write a stale
file back over a newer one. If you edited a file *and* the repo changed it, `setup` keeps yours:
run `setup diff`, merge by hand, then `save`.

## Aliases

Two files, loaded by `init.sh` in this order, so the machine-local one wins:

| File | Scope | How it gets there |
|---|---|---|
| `~/.alias` | every computer | `dotconfigs/.alias` in this repo; `setup` installs it and updates it after a `git pull` |
| `~/.alias.local` | this computer only | you create it; it is not in the repo and `setup` never touches it |

Both are plain POSIX `sh`, so bash and zsh read them alike. Put an alias in `dotconfigs/.alias` to
share it, in `~/.alias.local` to keep it on one machine. Until `setup` has installed `~/.alias`,
`init.sh` reads the repo's copy, so a freshly pulled alias never goes missing.

`setup` is switches-only — no environment knobs. Machine-local shell settings
(what `init.sh` sources at startup) go in `env.local` at the repo root
(gitignored).
Add an app: drop `dotconfigs/.config/<app>/` in place and run `./setup --files`.

## Notes

- Only files git knows in `dotconfigs/` are copied, not ignored ones; app state
  (plugins, alacritty themes) lives in `$HOME`, never in the clone.
- Coming from the old symlink setup? `./setup --files` replaces links into the
  repo with copies.
- Moved the clone? Run `./setup` again — the rc block is rewritten with the
  new path.
