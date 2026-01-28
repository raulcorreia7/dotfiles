#!/bin/sh
# Environment variables - early setup.
# This file is loaded before all other modules.

# Default editor settings
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-code}"

# Plugin toggles (1=enabled, 0=disabled)
DOTFILES_ENABLE_FZF="${DOTFILES_ENABLE_FZF:-1}"
DOTFILES_ENABLE_ZOXIDE="${DOTFILES_ENABLE_ZOXIDE:-1}"
DOTFILES_ENABLE_TMUX="${DOTFILES_ENABLE_TMUX:-1}"

# OS-specific settings
DOTFILES_ARCH_ASSUME_YES="${DOTFILES_ARCH_ASSUME_YES:-0}"
