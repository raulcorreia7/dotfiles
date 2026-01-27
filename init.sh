#!/bin/sh
# Entrypoint: load config and shell helpers.

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/config"
DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"
DOTFILES_SHELL_DIR="$DOTFILES_CONFIG_DIR/shell"
DOTFILES_PLUGINS_DIR="$DOTFILES_CONFIG_DIR/plugins"
DOTFILES_LOADERS_DIR="$DOTFILES_CONFIG_DIR/loaders"

# -----------------------------------------------------------------------------
# Internal helpers
# -----------------------------------------------------------------------------

__dot_log() {
  printf '%s\n' "$*" >&2
}

__dot_debug() {
  [ "${DOTFILES_DEBUG:-0}" = "1" ] && __dot_log "$@"
}

__dot_source() {
  [ -r "$1" ] || return 0
  __dot_debug "dotfiles: source $1"
  . "$1"
}

# -----------------------------------------------------------------------------
# Load config and core (runtime-only)
# -----------------------------------------------------------------------------

# Optional config overrides (variables only).
__dot_source "$DOTFILES_CONFIG_DIR/env"

__dot_source "$DOTFILES_SHELL_DIR/core.sh"
__dot_source "$DOTFILES_LOADERS_DIR/manifest.sh"

# -----------------------------------------------------------------------------
# Zimfw (zsh only, no downloads)
# -----------------------------------------------------------------------------

if [ -n "${ZSH_VERSION:-}" ]; then
  # Set zimfw environment to use dotfiles config
  export ZIM_HOME="${ZIM_HOME:-$DOTFILES_CONFIG_DIR/zimfw}"
  export ZIM_CONFIG_FILE="${ZIM_CONFIG_FILE:-$DOTFILES_CONFIG_DIR/.zimrc}"

  if [ -r "$HOME/.zim/init.zsh" ]; then
    . "$HOME/.zim/init.zsh"
  elif [ -r "$DOTFILES_CONFIG_DIR/zimfw/init.zsh" ]; then
    . "$DOTFILES_CONFIG_DIR/zimfw/init.zsh"
  fi
fi

# -----------------------------------------------------------------------------
# Public commands
# -----------------------------------------------------------------------------

dot_reload() {
  # Reload config and functions without restarting shell.
  . "$DOTFILES_DIR/init.sh"
}

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# Aliases are last so they bind to loaded functions.
__dot_source "$DOTFILES_CONFIG_DIR/aliases"
