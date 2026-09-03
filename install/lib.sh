#!/bin/sh
# Installer library - shared by install/ and packages/
# Provides: logging, path helpers, user context, dependency guards, OS detection

if [ -n "${_DOTFILES_INSTALL_LIB:-}" ]; then
  return 0
fi
_DOTFILES_INSTALL_LIB=1


log() {
  printf '%s\n' "$*" >&2
}

log_debug() {
  [ "${DOTFILES_DEBUG:-0}" = "1" ] || return 0
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


ensure_dir() {
  [ -d "$1" ] || mkdir -p "$1"
}


run_as_user() {
  if [ -n "${SUDO_USER:-}" ]; then
    sudo -u "$SUDO_USER" -H sh -c "$1"
  else
    sh -c "$1"
  fi
}


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

