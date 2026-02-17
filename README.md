# dotfiles

Modular, XDG-first dotfiles with strict separation between installer and runtime.

## Quickstart

```sh
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install
```

Reload your shell:
```sh
source ~/.zshrc
```

---

## RDF Command

The `rdf` command is the main interface for dotfiles management.

```bash
rdf <command>
```

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

### Examples

```bash
rdf reload           # Reload shell config
rdf doctor           # Check installed tools
rdf edit             # Open dotfiles in editor
rdf cd               # cd to ~/.dotfiles
rdf update           # pacman + paru update
rdf update --full    # orphans + cache + update
rdf orphans          # list orphans
rdf orphans --remove # remove orphans
rdf cache            # show cache size
rdf cache --clean    # clean cache
```

---

## Install Command

```bash
./install [OPTIONS] [PHASE...]
```

### Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-l, --list` | List available phases |
| `-v, --verbose` | Enable verbose output |
| `-n, --dry-run` | Show what would be done |
| `-s, --skip PHASES` | Skip phases (comma-separated) |
| `-o, --only PHASES` | Run only these phases |

### Phases

| Phase | Description |
|-------|-------------|
| `check` | Validate system readiness |
| `setup` | Create directories, link configs |
| `install` | Install OS packages |
| `tools` | Install mise, zimfw, nvim plugins |
| `configure` | Post-install configuration |

### Examples

```bash
./install                        # Run all phases
./install setup                  # Run single phase
./install --only setup,tools     # Run specific phases
./install --skip install         # Skip package installation
./install -n                     # Dry run
./install --list                 # List phases
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTFILES_DEBUG` | 0 | Enable debug logging |
| `DOTFILES_ENABLE_MISE` | 1 | Enable mise plugin |
| `DOTFILES_ENABLE_FZF` | 1 | Enable fzf plugin |
| `DOTFILES_ENABLE_ZOXIDE` | 1 | Enable zoxide plugin |
| `DOTFILES_ENABLE_TMUX` | 1 | Enable tmux autostart |
| `DOTFILES_ENABLE_NVIM` | 1 | Install nvim plugins |
| `DOTFILES_ARCH_ASSUME_YES` | 1 | Non-interactive pacman |

---

## Alias

| Alias | Command | Description |
|-------|---------|-------------|
| `nvcfg` | `$EDITOR ~/.config/nvim` | Edit neovim config |

---

## Adding Packages

Edit `packages/arch/pacman` for official repos:
```
ripgrep
fd
bat
```

Edit `packages/arch/aur` for AUR:
```
mise-bin
delta
```

---

## Adding Plugins

1. Create `config/plugins/my-plugin/init.sh`:
```sh
#!/bin/sh
dot_has mytool || return 0
dot_eval_init mytool
```

2. Add to `config/manifest.sh`:
```sh
__dot_load_plugin "my-plugin"
```

---

## Sync to Remote

```bash
rsync -avz --delete ~/.dotfiles/ talos:~/.dotfiles/
```

---

## Supported Systems

| System | Support |
|--------|---------|
| Arch / EndeavourOS / CachyOS | Full |
| macOS | Via Homebrew |
| Windows | Manual |

---

## Directory Structure

```
.dotfiles/
├── install              # Installer entrypoint
├── init.sh              # Runtime entrypoint
├── installers/          # Installer layer
│   ├── lib.sh
│   ├── phases/
│   └── install-arch.sh
├── config/              # Runtime layer
│   ├── runtime.sh       # rdf command, dot_*
│   ├── manifest.sh
│   ├── env
│   ├── aliases
│   └── plugins/
└── packages/arch/
    ├── pacman
    └── aur
```

---

## Troubleshooting

```bash
DOTFILES_DEBUG=1 source ~/.zshrc   # Debug loading
rdf doctor                          # Check tools
./install -n                        # Dry run
```
