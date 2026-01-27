#!/bin/sh
# Legacy loader (for compatibility).

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

if ! command -v __dot_source >/dev/null 2>&1; then
  __dot_source() {
    [ -r "$1" ] || return 0
    . "$1"
  }
fi

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_SCRIPTS_DIR="${DOTFILES_SCRIPTS_DIR:-$HOME/.dotfiles/scripts}"
DOTFILES_CONFIG_DIR="${DOTFILES_CONFIG_DIR:-$HOME/.dotfiles/config}"
DOTFILES_SHELL_DIR="${DOTFILES_SHELL_DIR:-$DOTFILES_CONFIG_DIR/shell}"
DOTFILES_PLUGINS_DIR="${DOTFILES_PLUGINS_DIR:-$DOTFILES_CONFIG_DIR/plugins}"
DOTFILES_LOADERS_DIR="${DOTFILES_LOADERS_DIR:-$DOTFILES_CONFIG_DIR/loaders}"

# -----------------------------------------------------------------------------
# Script order
# -----------------------------------------------------------------------------

__dot_source "$DOTFILES_SHELL_DIR/core.sh"
__dot_source "$DOTFILES_LOADERS_DIR/manifest.sh"
