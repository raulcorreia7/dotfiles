# AGENTS.md

Dotfiles managed with chezmoi. `.chezmoiroot` points at `home/`; chezmoi copies it
into `$HOME`. `install.sh` bootstraps. README.md has the layout and commands.

## Where a change goes

- App config: `home/private_dot_config/<app>/`; `chezmoi re-add` for edits made on a machine.
- Package: `home/.chezmoidata/packages.yaml`, under the right manager and profile; one
  machine only: `hosts.yaml`. Keep `base` minimal; everything the runtime needs is in `base`.
- Tools: the OS package manager first. Add upstream's official apt repo under `repos` when it
  beats the distro. Only if a manager has no package: `packages.mise.<manager>`. Runtimes:
  the mise config. One owner per tool, never two.
- SSH hosts, git identity, any secret: never in the repo. They stay on the machine.
- Script: `home/private_dot_local/bin/executable_<name>`; skip profiles in `.chezmoiignore`.
- Third-party code and fonts: `.chezmoiexternal.toml.tmpl` or a `zmodule` in `zimrc`, tracking
  latest. Never copy it in or pin it without a reason.
- Shell runtime: `home/private_dot_config/shell/`. Machine-local values: `~/.config/shell/env.local`.

## Rules

- Prefer the latest upstream version of everything; pin only with a reason, written next to the pin.
- Keep it simple; delete before adding. Use an existing tool or upstream config before writing one.
- Nothing may depend on where the repo is cloned.
- Commit shared config only. Generated and downloaded files stay out of the repo.
- Executable scripts are POSIX `sh`: `set -eu`, small single-purpose functions, and a
  `main` called last. Sourced files define functions only.
- Scripts must be safe to re-run. Never overwrite a machine's files without `chezmoi diff` first.
- No tests, CI or linters.

## Check a change

```sh
chezmoi diff
```

To test without touching your home (scripts excluded, so nothing runs `sudo`):

```sh
export HOME=$(mktemp -d)
chezmoi init --source "$PWD" --promptString "Host name (key in .chezmoidata/hosts.yaml)=talos,Git name=Test,Git email=t@example.com" --promptChoice "Machine profile=personal"
chezmoi apply --exclude=scripts && chezmoi verify --exclude=scripts
```

`--exclude` takes one value; repeating it keeps only the last, so list kinds with commas.
