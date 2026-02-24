#!/bin/sh
# Installer library - used only by installers/
# Provides: logging, package helpers, OS detection, phase loader

if [ -n "${_DOTFILES_INSTALL_LIB:-}" ]; then
  return 0
fi
_DOTFILES_INSTALL_LIB=1

# =============================================================================
# LOGGING
# =============================================================================

DOTFILES_LOG_LEVEL="${DOTFILES_LOG_LEVEL:-INFO}"

_install_log_level() {
  case "$1" in
  DEBUG) echo 0 ;;
  INFO) echo 1 ;;
  WARN) echo 2 ;;
  ERROR) echo 3 ;;
  *) echo 1 ;;
  esac
}

_install_should_log() {
  current=$(_install_log_level "$DOTFILES_LOG_LEVEL")
  check=$(_install_log_level "$1")
  [ "$check" -ge "$current" ]
}

log() {
  printf '%s\n' "$*" >&2
}

log_debug() {
  [ "${DOTFILES_DEBUG:-0}" = "1" ] || _install_should_log DEBUG || return 0
  printf '[DEBUG] %s\n' "$*" >&2
}

log_info() {
  printf '[INFO] %s\n' "$*"
}

log_warn() {
  printf '[WARN] %s\n' "$*" >&2
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

# =============================================================================
# PATH HELPERS
# =============================================================================

script_dir() {
  CDPATH='' cd -- "$(dirname -- "$0")" && pwd
}

ensure_dir() {
  [ -d "$1" ] || mkdir -p "$1"
}

# =============================================================================
# USER CONTEXT
# =============================================================================

run_as_user() {
  if [ -n "${SUDO_USER:-}" ]; then
    sudo -u "$SUDO_USER" -H sh -c "$1"
  else
    sh -c "$1"
  fi
}

# =============================================================================
# PACKAGE HELPERS
# =============================================================================

read_packages() {
  [ -f "$1" ] || return 0
  grep -v '^[[:space:]]*$' "$1" | grep -v '^#' || true
}

# =============================================================================
# DEPENDENCY GUARDS
# =============================================================================

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_error "${2:-$1 is required but not installed}"
    exit 1
  fi
}

require_file() {
  if [ ! -r "$1" ]; then
    log_error "${2:-Required file not found: $1}"
    exit 1
  fi
}

# =============================================================================
# OS DETECTION
# =============================================================================

detect_os() {
  case "$(uname -s | tr '[:upper:]' '[:lower:]')" in
  linux)
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "${ID_LIKE:-${ID:-}}" in
      *arch*) echo "arch" ;;
      *) echo "linux" ;;
      esac
    else
      echo "linux"
    fi
    ;;
  darwin)
    echo "macos"
    ;;
  *)
    echo "unknown"
    ;;
  esac
}

# =============================================================================
# PHASE LOADER
# =============================================================================

run_phase_direct() {
  phase_name="$1"
  phase_script="${phase_name##*/}"
  current_script="${0##*/}"

  [ "$current_script" = "$phase_script" ] || return 0

  SCRIPT_DIR=$(script_dir)
  . "$SCRIPT_DIR/../lib.sh"
  . "$SCRIPT_DIR/../config.sh"

  if type run_phase >/dev/null 2>&1; then
    run_phase
    exit $?
  else
    log_error "Phase file missing run_phase function"
    exit 1
  fi
}
