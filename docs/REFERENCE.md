# Dotfiles Reference

## Commands

| Command | Args | Description |
|---------|------|-------------|
| `rdotfiles setup` | - | Full install (packages + link + tools) |
| `rdotfiles link` | - | Link configs and bin to standard locations |
| `rdotfiles unlink` | - | Remove all dotfiles symlinks |
| `rdotfiles health` | - | Run health check on installation |
| `rdotfiles fix` | `[--all] [--link] [--zimfw]` | Fix common issues |
| `rdotfiles update` | `[--health] [--fix]` | Pull latest dotfiles from git |
| `rdotfiles help` | - | Show help message |

### Aliases

| Alias | Equivalent |
|-------|------------|
| `df` | `rdotfiles` |
| `dotreload` | `rdotfiles reload` |
| `dotdoctor` | `rdotfiles health` |

## Environment Variables

### Core

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_DIR` | `$HOME/.dotfiles` | Base dotfiles directory |
| `DOTFILES_DEBUG` | `0` | Enable debug logging (`1` to enable) |

### Path Overrides

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_BEFORE_DIR` | `$DOTFILES_DIR/before` | Early loading scripts |
| `DOTFILES_LIB_DIR` | `$DOTFILES_DIR/lib` | Core libraries |
| `DOTFILES_MODULES_DIR` | `$DOTFILES_DIR/modules` | Feature modules |
| `DOTFILES_AFTER_DIR` | `$DOTFILES_DIR/after` | Late loading scripts |
| `DOTFILES_OS_DIR` | `$DOTFILES_DIR/os` | OS-specific scripts |
| `DOTFILES_CONFIG_DIR` | `$DOTFILES_DIR/config` | App configurations |

### Feature Toggles (set to `0`/`false`/`no`/`off` to disable)

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_ENABLE_ZIMFW` | `1` | Zsh module manager |
| `DOTFILES_ENABLE_FZF` | `1` | Fuzzy finder integration |
| `DOTFILES_ENABLE_ZOXIDE` | `1` | Smart directory jumping |
| `DOTFILES_ENABLE_TMUX` | `1` | Tmux autostart |
| `DOTFILES_ENABLE_ARCH` | `1` | Arch Linux helpers |

### Install Options

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_MISE_INSTALL` | `1` | Run `mise install` during setup |
| `DOTFILES_ZIMFW_INSTALL` | `1` | Install zimfw modules during setup |
| `DOTFILES_ZIMFW_BUILD` | `1` | Build zimfw init during setup |
| `DOTFILES_POST_INSTALL` | `1` | Run post-install scripts |
| `DOTFILES_ARCH_ASSUME_YES` | `0` | Skip pacman/paru confirmations |
| `DOTFILES_TMUX_AUTOSTART` | `1` | Auto-start tmux in interactive shells |

### Standard Paths

| Variable | Default |
|----------|---------|
| `XDG_CONFIG_HOME` | `$HOME/.config` |
| `XDG_DATA_HOME` | `$HOME/.local/share` |
| `XDG_STATE_HOME` | `$HOME/.local/state` |
| `USER_BIN_DIR` | `$HOME/.local/bin` |
| `ZDOTDIR` | `$HOME` |
| `ZIM_HOME` | `$ZDOTDIR/.zim` |

---

## File Locations

### Core Files

| Component | Path |
|-----------|------|
| Entry point | `init.sh` |
| Main installer | `install` |
| CLI tool | `bin/rdotfiles` |
| Path definitions | `before/paths.sh` |
| Environment | `before/env.sh` |
| Aliases | `after/aliases.sh` |
| Local overrides | `after/local.sh` (gitignored) |

### Directories

| Component | Path |
|-----------|------|
| User scripts | `bin/` → `~/.local/bin/` |
| App configs | `config/<app>/` → `~/.config/<app>/` |
| Core libraries | `lib/` |
| Feature modules | `modules/` |
| OS-specific | `os/` |
| Install scripts | `lib/install/` |
| Dev scripts | `scripts/` |

### Linked App Configs

| App | Source | Destination |
|-----|--------|-------------|
| Alacritty | `config/alacritty/` | `~/.config/alacritty/` |
| Ghostty | `config/ghostty/` | `~/.config/ghostty/` |
| Neovim | `config/nvim/` | `~/.config/nvim/` |
| Tmux | `config/tmux/` | `~/.config/tmux/` |
| mise | `config/mise/` | `~/.config/mise/` |
| Zimfw | `config/.zimrc` | `~/.zimrc` |

### Module Loading Order

From `lib/manifest.sh`: `tmux` → `zimfw` → `mise` → `fzf` → `zoxide` → `arch`

## Quick Examples

```bash
# Full setup
rdotfiles setup

# Quick health check and fix
dotdoctor && rdotfiles fix --all

# Update with auto-fix
rdotfiles update --fix

# Debug mode
DOTFILES_DEBUG=1 rdotfiles health

# Disable tmux autostart
export DOTFILES_TMUX_AUTOSTART=0

# Reload shell config
dotreload
```

## See Also

- `README.md` - Main documentation
- `docs/development/AGENTS.md` - Development guide
- `bin/rdotfiles --help` - CLI help