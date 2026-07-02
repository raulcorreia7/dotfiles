# dotfiles

Modular, XDG-first dotfiles with strict separation between installer and runtime.
Shared agent guidance lives in `config/agents`, with OpenCode and Codex
consuming the same `AGENTS.md`.

## Quickstart

Minimum prerequisites:

- `git`
- `stow` (GNU Stow is required for setup phase)

### Required Dependencies by OS

Required for install/setup:

- `git`, `stow`, and one supported shell (`bash` or `zsh`)

Required for local quality checks (`make check`):

- `shellcheck`, `shfmt`, `fd`/`fdfind`, `node` + `npx`

Optional for local test execution:

- `bats` (used by `make test-bats`; CI runs this regardless)

Arch / EndeavourOS / CachyOS:

```sh
sudo pacman -S --needed git stow bash zsh shellcheck shfmt fd nodejs npm bats
```

macOS (Homebrew):

```sh
brew install git stow bash zsh shellcheck shfmt fd node bats-core
```

```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install

# Optional but recommended: install local git hooks
make hooks-install
```

Reload your shell:

```sh
source ~/.zshrc
```

---

## Make Commands

```bash
make help      # Show available commands
make fmt       # Format all shell scripts
make lint      # Lint all shell scripts
make markdown-lint # Lint README markdown
make check     # Run lint (CI)
make test      # Dry-run installer + bats smoke tests
make test-bats # Run bats smoke tests only
make hooks-install # Install native pre-commit hook
make hooks-run # Run native pre-commit checks
make install   # Run full installation
```

Required local tooling for `make check`: `shellcheck`, `shfmt`, `fd`/`fdfind`, and `npx` (Node.js).

`make check` uses `npx` to fetch the latest `markdownlint-cli2` on each run.
If `npx` is unavailable, install `markdownlint-cli2` globally as a fallback.

---

## RDF Command

The `rdf` command is the main interface for dotfiles management.

| Command | Description |
|---------|-------------|
| `rdf sync` | Pull and apply latest dotfiles changes |
| `rdf refresh` | Apply local dotfiles changes |
| `rdf reload` | Reload dotfiles configuration |
| `rdf edit` | Edit dotfiles in `$EDITOR` |
| `rdf health [scope]` | Check tools, directories, links, and Git status |
| `rdf update` | System update (Arch) |
| `rdf update --full` | Full maintenance (Arch) |
| `rdf orphans` | List orphan packages (Arch) |
| `rdf orphans --remove` | Prompt to remove orphan packages (Arch) |
| `rdf cache` | Show pacman cache size (Arch) |
| `rdf cache --clean` | Prompt to clean pacman cache (Arch) |

---

## Install Phases

```bash
./install                        # Run all phases
./install setup                  # Run single phase
./install --only setup,tools     # Run specific phases
./install --skip install         # Skip package installation
./install -n                     # Dry run
```

| Phase | Description |
|-------|-------------|
| `check` | Validate system readiness |
| `setup` | Create directories, link configs |
| `install` | Install OS packages |
| `tools` | Install mise, zimfw, nvim plugins |
| `configure` | Post-install configuration |

---

## Agent Guidance

- `config/agents` is the shared source for global guidance, skills, shared references, templates, and the skill catalog.
- The installer links `~/.agents` to `~/.config/agents`; tools discover skills from `~/.agents/skills/*/SKILL.md`.
- OpenCode is intentionally minimal and loads only `~/.config/agents/AGENTS.md` from `config/opencode/opencode.json`.
- Codex consumes `~/.codex/AGENTS.md`, `~/.codex/config.toml`, `~/.codex/rules/*.rules`, and `~/.codex/agents/*.toml`.
- Codex command-approval policies live in `config/codex/rules`; custom Codex agents live in `config/codex/agents`.

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTFILES_DEBUG` | 0 | Enable debug logging |
| `DOTFILES_ENABLE_MISE` | 1 | Install mise tools |
| `DOTFILES_ENABLE_ZIMFW` | 1 | Build zimfw |
| `DOTFILES_ENABLE_NVIM` | 1 | Install nvim plugins |
| `DOTFILES_OS_ARCH_ASSUME_YES` | 0 | Non-interactive pacman |
| `DOTFILES_MACOS_CATEGORIES` | `base cli development gui` | Homebrew category install order |
| `DOTFILES_POST_INSTALL_DESKTOP` | 1 | Apply KDE shortcuts and preferred applications |
| `DOTFILES_POST_INSTALL_LOGIN_DISPLAY` | 1 | Apply the current KDE display layout to the login screen |

---

## Neovim Theme Browser

`theme-browser.nvim` is configured in two layers:

- [config/nvim/lua/plugins/theme-browser.lua](config/nvim/lua/plugins/theme-browser.lua): minimal `lazy.nvim` spec
- [config/nvim/lua/config/theme-browser.lua](config/nvim/lua/config/theme-browser.lua): runtime options and local dev toggle

Default behavior uses the published plugin:

```sh
unset THEME_BROWSER_DEV
```

Local plugin development is enabled explicitly:

```sh
export THEME_BROWSER_DEV=1
```

When dev mode is enabled, the dotfiles config:

- loads the plugin from `~/projects/theme-browser-monorepo/packages/plugin` if present
- passes a `development` block to `theme-browser.nvim`
- points registry development at `~/projects/theme-browser-monorepo/packages/registry/artifacts/themes.json`
- prefers local theme repos from `~/projects`

This keeps the checked-in default portable while still making local plugin work fast.

---

## Supported Systems

| System | Support |
|--------|---------|
| Arch / EndeavourOS / CachyOS | Full |
| macOS | Via Homebrew |

---

## Troubleshooting

```bash
DOTFILES_DEBUG=1 source ~/.zshrc   # Debug loading
rdf health                          # Check dotfiles health
make test                           # Dry run
```

---

See [ARCHITECTURE.md](ARCHITECTURE.md) for internal details, naming conventions, and adding plugins/packages.
