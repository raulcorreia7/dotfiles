#!/bin/sh
# Shared install helpers (POSIX sh).

# ------------------------------------------------------------------------------
# SECTION 1: Base Helpers
# ------------------------------------------------------------------------------

# Use __dot_has from lib/loader.sh if available, otherwise define fallback
if ! command -v __dot_has >/dev/null 2>&1; then
  __dot_has() { command -v "$1" >/dev/null 2>&1; }
fi

# ------------------------------------------------------------------------------
# SECTION 2: Logging Utilities
# ------------------------------------------------------------------------------

log() {
  printf '%s\n' "$*" >&2
}

warn() {
  printf 'WARNING: %s\n' "$1" >&2
}

error() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

# ------------------------------------------------------------------------------
# SECTION 3: Platform Detection
# ------------------------------------------------------------------------------

# Check if running in Windows Subsystem for Linux.
# Returns 0 (true) if in WSL, 1 (false) otherwise.
is_wsl() {
  # Check for WSLInterop file
  if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    return 0
  fi

  # Check for Windows C: drive mount
  if [ -d /mnt/c/Windows ]; then
    return 0
  fi

  # Check kernel release string for Microsoft/WSL indicators
  case "$(uname -r)" in
    *[Mm]icrosoft* | *[Ww][Ss][Ll]*) return 0 ;;
  esac

  return 1
}

# ------------------------------------------------------------------------------
# SECTION 4: Path Resolution
# ------------------------------------------------------------------------------

# Get the user's home directory, accounting for sudo usage.
# Output: Full path to user's home directory.
get_user_home() {
  if [ -n "${SUDO_USER:-}" ]; then
    # Validate SUDO_USER is a valid username (alphanumeric, underscores, hyphens)
    case "$SUDO_USER" in
      *[!a-zA-Z0-9_-]*)
        printf '%s\n' "$HOME"
        return 0
        ;;
    esac

    _user_home=""
    if command -v getent >/dev/null 2>&1; then
      _user_home=$(getent passwd "$SUDO_USER" 2>/dev/null | cut -d: -f6)
    fi
    if [ -z "$_user_home" ]; then
      # Fallback: check user's home directory directly
      if [ -d "/home/$SUDO_USER" ]; then
        _user_home="/home/$SUDO_USER"
      elif [ -n "${HOME:-}" ]; then
        _user_home="$HOME"
      fi
    fi
    [ -n "$_user_home" ] || _user_home="$HOME"
  else
    _user_home="$HOME"
  fi
  printf '%s\n' "$_user_home"
}

# Get the XDG cache home directory.
# Output: Full path to cache directory.
get_cache_home() {
  _user_home=$(get_user_home)
  if [ -n "${SUDO_USER:-}" ]; then
    printf '%s\n' "$_user_home/.cache"
  else
    printf '%s\n' "${XDG_CACHE_HOME:-$_user_home/.cache}"
  fi
}

# Get the XDG state home directory.
# Output: Full path to state directory.
get_state_home() {
  _user_home=$(get_user_home)
  if [ -n "${SUDO_USER:-}" ]; then
    printf '%s\n' "$_user_home/.local/state"
  else
    printf '%s\n' "${XDG_STATE_HOME:-$_user_home/.local/state}"
  fi
}

# ------------------------------------------------------------------------------
# SECTION 5: Higher-Level Helpers
# ------------------------------------------------------------------------------

info() {
  printf '==> %s\n' "$1"
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
# SECTION 6: Package List Parsing
# ------------------------------------------------------------------------------

read_packages() {
  if [ -f "$1" ]; then
    grep -v '^[[:space:]]*$' "$1" | grep -v '^#' || true
  fi
}
