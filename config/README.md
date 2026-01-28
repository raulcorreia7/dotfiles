# config/

Configuration files and shell modules.

## Structure

```
config/
├── aliases           # Shell aliases (sourced by init.sh)
├── env               # Environment variables (sourced first)
├── paths.sh          # Centralized path definitions
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

1. `before/paths.sh` - Centralized path definitions
2. `before/env.sh` - Environment variables
3. `lib/loader.sh` - Core functions
4. `lib/manifest.sh` - Loads enabled modules
5. Ensure `~/.local/bin` is on PATH (opt-out: `DOTFILES_POST_INSTALL_PATH=0`)
6. `after/aliases.sh` - Command aliases

## App Configs

Application configs are linked to `~/.config/<app>/` by `lib/install/link.sh`.

## Adding Shell Functions

Add to `lib/loader.sh` or create new files in `lib/`.

## Adding Plugins

Create a directory in `modules/` with an `init.sh` entrypoint.
Enable in `lib/manifest.sh`.

Plugins can be disabled via environment variables:
- `DOTFILES_ENABLE_ZIMFW=0` - disable zimfw
- `DOTFILES_ENABLE_FZF=0` - disable fzf
- `DOTFILES_ENABLE_ZOXIDE=0` - disable zoxide
- `DOTFILES_ENABLE_TMUX=0` - disable tmux
- `DOTFILES_ENABLE_ARCH=0` - disable arch helpers
