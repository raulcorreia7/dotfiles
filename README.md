# dotfiles

Modular, XDG-first dotfiles with strict separation between installer and runtime.

## Quickstart

```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
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
make check     # Run lint (CI)
make test      # Dry-run installer
make install   # Run full installation
```

---

## RDF Command

The `rdf` command is the main interface for dotfiles management.

| Command | Description |
|---------|-------------|
| `rdf reload` | Reload dotfiles configuration |
| `rdf edit` | Edit dotfiles in `$EDITOR` |
| `rdf doctor` | Check tool status |
| `rdf cd` | Go to dotfiles directory |
| `rdf update` | System update (Arch) |
| `rdf update --full` | Full maintenance (Arch) |
| `rdf orphans` | List orphan packages (Arch) |
| `rdf orphans --remove` | Remove orphan packages (Arch) |
| `rdf cache` | Show pacman cache size (Arch) |
| `rdf cache --clean` | Clean pacman cache (Arch) |

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

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTFILES_DEBUG` | 0 | Enable debug logging |
| `DOTFILES_ENABLE_MISE` | 1 | Install mise tools |
| `DOTFILES_ENABLE_ZIMFW` | 1 | Build zimfw |
| `DOTFILES_ENABLE_NVIM` | 1 | Install nvim plugins |
| `DOTFILES_ARCH_ASSUME_YES` | 0 | Non-interactive pacman |

---

## Supported Systems

| System | Support |
|--------|---------|
| Arch / EndeavourOS / CachyOS | Full |
| macOS | Via Homebrew |
| Windows | Manual |

---

## Troubleshooting

```bash
DOTFILES_DEBUG=1 source ~/.zshrc   # Debug loading
rdf doctor                          # Check tools
make test                           # Dry run
```

---

See [ARCHITECTURE.md](ARCHITECTURE.md) for internal details, naming conventions, and adding plugins/packages.
