# config/

Configuration files and shell modules.

## Structure

```
config/
├── aliases           # Shell aliases (sourced by init.sh)
├── env               # Environment variables (sourced first)
├── paths.sh          # Centralized path definitions
├── shell/
│   └── core.sh       # Core shell functions
├── loaders/
│   └── manifest.sh   # Plugin loader
├── plugins/          # Optional plugin modules
│   ├── fzf/
│   ├── zoxide/
│   ├── tmux/
│   ├── mise/
│   ├── zimfw/        # Zsh framework integration
│   └── arch/         # Arch Linux helpers
└── [app configs]/    # App configurations
    ├── alacritty/
    ├── ghostty/
    ├── nvim/
    ├── tmux/
    ├── zimfw/
    └── mise/
```

## How It Works

The `init.sh` entrypoint sources files in this order:

1. `paths.sh` - Centralized path definitions
2. `env` - Environment variables
3. `shell/core.sh` - Core functions
4. `loaders/manifest.sh` - Loads enabled plugins
5. Ensure `~/.local/bin` is on PATH (opt-out: `DOTFILES_POST_INSTALL_PATH=0`)
6. `aliases` - Command aliases

## App Configs

Application configs are linked to `~/.config/<app>/` by `installers/link.sh`.

## Adding Shell Functions

Add to `shell/core.sh` or create new files in `shell/`.

## Adding Plugins

Create a directory in `plugins/` with an `init.sh` entrypoint.
Enable in `loaders/manifest.sh`.

Plugins can be disabled via environment variables:
- `DOTFILES_ENABLE_ZIMFW=0` - disable zimfw
- `DOTFILES_ENABLE_FZF=0` - disable fzf
- `DOTFILES_ENABLE_ZOXIDE=0` - disable zoxide
- `DOTFILES_ENABLE_TMUX=0` - disable tmux
- `DOTFILES_ENABLE_ARCH=0` - disable arch helpers
