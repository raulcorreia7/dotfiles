#!/bin/sh
# Entrypoint: load config and shell helpers.

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/config"
DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"

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
# Load config and scripts
# -----------------------------------------------------------------------------

# Optional config overrides (variables only).
__dot_source "$DOTFILES_CONFIG_DIR/env"
# Core helpers.
__dot_source "$DOTFILES_SCRIPTS_DIR/tools.sh"
__dot_source "$DOTFILES_SCRIPTS_DIR/git.sh"
__dot_source "$DOTFILES_SCRIPTS_DIR/fzf.sh"

# -----------------------------------------------------------------------------
# Public commands
# -----------------------------------------------------------------------------

dot_reload() {
  # Reload config and functions without restarting shell.
  __dot_debug "dotfiles: reload"
  . "$DOTFILES_DIR/init.sh"
}

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# Aliases are last so they bind to loaded functions.
__dot_source "$DOTFILES_CONFIG_DIR/aliases"
