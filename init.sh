#!/bin/sh
# Entrypoint: load config and shell helpers.

# Re-entrancy guard
[ -n "${__DOTFILES_INIT:-}" ] && return 0
__DOTFILES_INIT=1

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

# Setup paths
# Source centralized paths (required)
_dotfiles_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_DIR="${DOTFILES_DIR:-$_dotfiles_root}"
unset _dotfiles_root

[ -r "$DOTFILES_DIR/before/paths.sh" ] || {
  __dot_log "dotfiles: ERROR: paths.sh not found"
  return 1
}
. "$DOTFILES_DIR/before/paths.sh" || {
  __dot_log "dotfiles: ERROR: failed to load paths.sh"
  return 1
}

# ------------------------------------------------------------------------------
# SECTION 2: Utility Functions (alphabetically ordered)
# ------------------------------------------------------------------------------

# Log message to stderr
__dot_log() { printf '%s\n' "$*" >&2; }

# Debug logging (controlled by DOTFILES_DEBUG)
__dot_debug() { [ "${DOTFILES_DEBUG:-0}" = "1" ] && __dot_log "$@"; }

# Source file if readable
__dot_source() {
  [ -r "$1" ] || return 0
  __dot_debug "dotfiles: source $1"
  . "$1"
}

# Source required file
__dot_source_required() {
  [ -r "$1" ] || {
    __dot_log "dotfiles: ERROR: required file not found: $1"
    return 1
  }
  __dot_debug "dotfiles: source $1"
  . "$1" || {
    __dot_log "dotfiles: ERROR: failed to load: $1"
    return 1
  }
}

# ------------------------------------------------------------------------------
# SECTION 3: Main Loading
# ------------------------------------------------------------------------------

__dot_source "$DOTFILES_BEFORE_DIR/env"
__dot_source_required "$DOTFILES_LIB_DIR/loader.sh" || return 1
__dot_source "$DOTFILES_LIB_DIR/manifest.sh"

# ------------------------------------------------------------------------------
# SECTION 4: PATH
# ------------------------------------------------------------------------------

if [ "${DOTFILES_POST_INSTALL_PATH:-1}" != "0" ]; then
  case ":${PATH}:" in
    *":${USER_BIN_DIR}:"*) : ;;
    *) export PATH="${USER_BIN_DIR}:${PATH}" ;;
  esac
fi

# ------------------------------------------------------------------------------
# SECTION 5: Final Loading
# ------------------------------------------------------------------------------

__dot_source "$DOTFILES_AFTER_DIR/aliases.sh"
