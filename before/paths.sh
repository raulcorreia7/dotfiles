#!/bin/sh
# Centralized path definitions for dotfiles.
# Source this file to ensure consistent paths across runtime and install-time.

# Base directory (can be overridden by environment)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# -----------------------------------------------------------------------------
# Core Path Variables
# -----------------------------------------------------------------------------

DOTFILES_BEFORE_DIR="${DOTFILES_BEFORE_DIR:-$DOTFILES_DIR/before}"
DOTFILES_LIB_DIR="${DOTFILES_LIB_DIR:-$DOTFILES_DIR/lib}"
DOTFILES_MODULES_DIR="${DOTFILES_MODULES_DIR:-$DOTFILES_DIR/modules}"
DOTFILES_AFTER_DIR="${DOTFILES_AFTER_DIR:-$DOTFILES_DIR/after}"
DOTFILES_OS_DIR="${DOTFILES_OS_DIR:-$DOTFILES_DIR/os}"
DOTFILES_CONFIG_DIR="${DOTFILES_CONFIG_DIR:-$DOTFILES_DIR/config}"

# App configs linked to ~/.config
DOTFILES_APP_CONFIGS="${DOTFILES_APP_CONFIGS:-alacritty ghostty nvim tmux mise}"

# Exclude paths for tooling (relative to repo root)
DOTFILES_EXCLUDE_DIRS="${DOTFILES_EXCLUDE_DIRS:-config/tmux/plugins config/zimfw/modules config/kimi .git .sisyphus}"
DOTFILES_EXCLUDE_FILES="${DOTFILES_EXCLUDE_FILES:-config/zimfw/init.zsh config/zimfw/login_init.zsh}"

# Zimfw native paths
ZDOTDIR_DEFAULT="${ZDOTDIR:-$HOME}"
DOTFILES_ZIM_HOME="${DOTFILES_ZIM_HOME:-$ZDOTDIR_DEFAULT/.zim}"
DOTFILES_ZIM_CONFIG="${DOTFILES_ZIM_CONFIG:-$ZDOTDIR_DEFAULT/.zimrc}"
DOTFILES_ZIMFW_CANDIDATES="${DOTFILES_ZIMFW_CANDIDATES:-$DOTFILES_ZIM_HOME/zimfw.zsh /usr/share/zimfw/zimfw.zsh /opt/homebrew/opt/zimfw/share/zimfw/zimfw.zsh /usr/local/opt/zimfw/share/zimfw/zimfw.zsh}"

# User paths (install targets)
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
USER_BIN_DIR="${USER_BIN_DIR:-$HOME/.local/bin}"
