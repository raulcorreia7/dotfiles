#!/bin/sh
# Legacy loader (for compatibility).

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

if ! command -v __dot_source >/dev/null 2>&1; then
  __dot_source() {
    [ -r "$1" ] || return 0
    . "$1"
  }
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$SCRIPT_DIR")}"
DOTFILES_SCRIPTS_DIR="${DOTFILES_SCRIPTS_DIR:-$DOTFILES_DIR/scripts}"
DOTFILES_CONFIG_DIR="${DOTFILES_CONFIG_DIR:-$DOTFILES_DIR/config}"
DOTFILES_SHELL_DIR="${DOTFILES_SHELL_DIR:-$DOTFILES_CONFIG_DIR/shell}"
DOTFILES_PLUGINS_DIR="${DOTFILES_PLUGINS_DIR:-$DOTFILES_CONFIG_DIR/plugins}"
DOTFILES_LOADERS_DIR="${DOTFILES_LOADERS_DIR:-$DOTFILES_CONFIG_DIR/loaders}"

# ------------------------------------------------------------------------------
# SECTION 2: Loading
# ------------------------------------------------------------------------------

__dot_source "$DOTFILES_SHELL_DIR/core.sh"
__dot_source "$DOTFILES_LOADERS_DIR/manifest.sh"
