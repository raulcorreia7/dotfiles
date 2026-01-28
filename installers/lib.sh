#!/bin/sh
# Shared install helpers (POSIX sh).

# ------------------------------------------------------------------------------
# SECTION 1: Logging Utilities
# ------------------------------------------------------------------------------

log() {
  printf '%s\n' "$*" >&2
}

info() {
  printf '==> %s\n' "$1"
}

error() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

ensure_dir() {
  [ -d "$1" ] || mkdir -p "$1"
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

run_as_user() {
  if [ -n "${SUDO_USER:-}" ]; then
    sudo -u "$SUDO_USER" -H "$@"
  else
    "$@"
  fi
}

# ------------------------------------------------------------------------------
# SECTION 2: Package List Parsing
# ------------------------------------------------------------------------------

read_packages() {
  if [ -f "$1" ]; then
    grep -v '^[[:space:]]*$' "$1" | grep -v '^#' || true
  fi
}
