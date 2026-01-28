# AGENTS.md — Dotfiles Development Contract

Authoritative, minimal contract for autonomous work on this dotfiles repository. Optimize for simple, clean, modular, maintainable shell code. Prefer proven patterns; avoid over-engineering.

---

## Repository Context

**Type**: Personal dotfiles (shell configs, app configs, installers)
**Languages**: Shell (POSIX sh, zsh), some PowerShell
**Entry Point**: `init.sh` — sourced by shell config

**Structure**:

```
.dotfiles/
├── config/          # App configs + shell modules
│   ├── paths.sh     # Centralized path definitions
│   ├── shell/
│   ├── plugins/     # Shell plugins (fzf, zoxide, tmux, zimfw, arch)
│   └── ...
├── installers/      # link.sh + OS installers
├── bin/             # User scripts → ~/.local/bin
├── scripts/         # Legacy loader (compat)
├── packages/        # OS package lists
└── init.sh          # Shell entrypoint
```

---

## Workflows

### RESTATE

Rephrase the task in one paragraph. List objectives, constraints, non-goals. Note assumptions and risks.

### REVIEW

Before changes, survey relevant files:

- Read existing code in target area
- Check for patterns to follow
- Identify risks or breaking changes

### PLAN

Deterministic plan with atomic steps:

- No file modifications during planning
- Define acceptance criteria
- Note if breaking changes required
- Represent as checklist

### BUILD

Minimal, reversible diffs:

- Execute plan steps in order
- Update docs with code changes
- Use batch edits when available
- Keep edits scoped; no opportunistic refactors

### VERIFY

Pre-completion gates:

- Shell syntax check: `sh -n <file>`
- Run `./scripts/lint.sh` to check style
- No dead code or stale comments
- Follows existing conventions

---

## Coding Standards

### Philosophy

- **KISS / YAGNI / Goldilocks** — balanced, pragmatic approach
- Prefer simple, composable, "boring" patterns
- Add abstraction only when it reduces net complexity
- Favor composition over inheritance
- Low cognitive complexity; intuitive naming

### Shell Code

- `#!/bin/sh` for POSIX, `#!/bin/zsh` for zsh-specific
- `set -euo pipefail` for strict mode
- Use functions; keep logic minimal
- Function prefixes (see Naming Conventions below)

### Naming Conventions

| Prefix | Usage | Example |
|--------|-------|---------|
| `__dot_*` | Core internal (init.sh, core.sh) | `__dot_log`, `__dot_debug` |
| `dot_*` | Core public API | `dot_reload`, `dot_status` |
| `_plugin_*` | Plugin private functions | `_tmux_autostart`, `_arch_assume_yes_flag` |
| `plugin_*` | Plugin public functions | `arch_pacman_update` |
| `install_*` | Installer functions | `install_pacman`, `install_paru` |

### Config Management

- XDG-first: configs in `config/<app>/`, linked to `~/.config/<app>/`
- No hardcoded personal paths or secrets
- One package per line in package lists; `#` for comments

### File Organization

Use section headers for multi-section files:

```sh
# ------------------------------------------------------------------------------
# SECTION 1: Setup/Guard
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# SECTION 2: Helper Functions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# SECTION 3: Main Logic
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# SECTION 4: Public API
# ------------------------------------------------------------------------------
```

### Prose

- Professional, concise, human
- No emojis or decorative styling

---

## Tooling

### Primary (Agentic)

- Use agentic tools for batch edits and refactoring
- Prefer built-in file editing over shell pipelines when available

### Fallback (System)

- `rg` (ripgrep): fast, gitignore-aware search
- `fd`: friendly `find`
- `sed`, `awk` for stream processing
- `jq` / `yq` for JSON/YAML

### Lint/Format

```bash
# Run full lint suite
./scripts/lint.sh

# Individual checks
sh -n <file>                    # Syntax check
shfmt -w -i 2 -bn -ci <file>    # Format shell script
editorconfig-checker .          # Check editorconfig compliance
```

### Reference Patterns

```bash
# Enumerate TODOs
rg -n 'TODO|FIXME|HACK|XXX'

# Safe batch edit
rg -l 'old_pattern' | xargs -r sed -i 's/old/new/g'
```

---

## Change Management

- Small, single-concern commits
- Conventional commit messages: `type(scope): description`
- No breaking changes to existing user configs
- Respect `DOTFILES_*` feature flags pattern

---

## Dotfiles-Specific Conventions

### Adding Aliases

Edit `config/aliases` — follow existing section structure

### Adding Functions

Add to `config/shell/` or `config/plugins/` — use appropriate prefix from Naming Conventions

### Adding Plugins

1. Create directory `config/plugins/<name>/`
2. Add `init.sh` with plugin logic
3. Add to `config/loaders/manifest.sh`
4. Use `DOTFILES_ENABLE_<PLUGIN>` for optional disable

### Adding Packages

**Arch**: Edit `packages/arch/pacman` (official) or `packages/arch/aur` (AUR)

**macOS**: Edit appropriate file in `packages/macos/` (base, cli, development, gui)

**Windows**: Edit `packages/windows/packages`

### Adding Scripts

Place executable in `bin/` — gets linked to `~/.local/bin/`

### Feature Flags

Pattern: `DOTFILES_ENABLE_<FEATURE>=0` to disable, `DOTFILES_<FEATURE>_INSTALL=0` to skip install steps

---

## Third-Party Code

The following directories contain third-party code and should **not** be modified:

- `config/tmux/plugins/*` — Tmux plugins (tpm, tmux-resurrect, etc.)
- `config/zimfw/modules/*` — Zimfw modules

These are excluded from linting via `.editorconfig-checker.json`.

---

## Security

- No network writes without explicit approval
- Validate/sanitize external inputs
- Guard file paths
- Prefer non-root execution for scripts
