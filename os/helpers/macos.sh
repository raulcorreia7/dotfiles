#!/bin/sh
# macOS system helpers and Homebrew utilities.
# Works as both sourceable library and standalone script.

# -----------------------------------------------------------------------------
# SECTION 1: Platform Detection Guards
# -----------------------------------------------------------------------------

# Detect if running on macOS (Darwin)
# Returns 0 if on macOS, 1 otherwise
_macos_detect() {
  case "$(uname -s)" in
    Darwin) return 0 ;;
    *) return 1 ;;
  esac
}

# Skip all definitions if not on macOS
if ! _macos_detect; then
  # When sourced: silently return
  # When executed: exit with error
  case "$0" in
    -* | */sh | */bash | */zsh | */dash | */ksh)
      return 0 2>/dev/null || exit 0
      ;;
    *)
      printf '%s\n' "Error: This script is for macOS only." >&2
      exit 1
      ;;
  esac
fi

# Source lib/utils.sh for base detection functions
if [ -r "${DOTFILES_DIR:-$HOME/.dotfiles}/lib/utils.sh" ]; then
  # shellcheck source=../lib/utils.sh
  . "${DOTFILES_DIR:-$HOME/.dotfiles}/lib/utils.sh"
fi

# -----------------------------------------------------------------------------
# SECTION 2: Platform-specific Helpers
# -----------------------------------------------------------------------------

# Get the macOS architecture.
# Outputs: arm64 (Apple Silicon) or x86_64 (Intel)
# Returns 1 if unable to determine architecture.
macos_get_arch() {
  _arch="$(uname -m)"
  case "$_arch" in
    arm64 | x86_64)
      printf '%s' "$_arch"
      ;;
    *)
      printf '%s\n' "Unknown architecture: $_arch" >&2
      return 1
      ;;
  esac
}

# -----------------------------------------------------------------------------
# SECTION 3: Homebrew Detection
# -----------------------------------------------------------------------------

# Check if Homebrew is installed.
# Returns 0 (true) if brew is found, 1 (false) otherwise.
macos_has_brew() {
  command -v brew >/dev/null 2>&1
}

# Get the Homebrew prefix path.
# Outputs: /opt/homebrew (Apple Silicon) or /usr/local (Intel)
# Returns 1 if Homebrew is not installed.
macos_brew_prefix() {
  if macos_has_brew; then
    brew --prefix
  else
    printf '%s\n' "Homebrew not installed" >&2
    return 1
  fi
}

# -----------------------------------------------------------------------------
# SECTION 4: Homebrew Operations (Public API)
# -----------------------------------------------------------------------------

# Update Homebrew and upgrade all packages.
# Runs: brew update && brew upgrade
# Returns 1 if Homebrew is not installed.
macos_brew_update() {
  case "$1" in
    -h | --help)
      printf 'Usage: macos_brew_update\nUpdate Homebrew and upgrade all packages.\n'
      return 0
      ;;
  esac

  if ! macos_has_brew; then
    printf '%s\n' "Error: Homebrew is not installed." >&2
    printf '%s\n' "Install from: https://brew.sh" >&2
    return 1
  fi

  printf '%s\n' "=== Updating Homebrew ==="
  brew update
  printf '%s\n' "=== Upgrading packages ==="
  brew upgrade
}

# Install packages via Homebrew.
# Usage: macos_brew_install <package> [package...]
# Returns 1 if no packages specified or Homebrew not installed.
macos_brew_install() {
  case "$1" in
    -h | --help)
      printf 'Usage: macos_brew_install <package> [package...]\nInstall packages via Homebrew.\n'
      return 0
      ;;
  esac

  if [ $# -eq 0 ]; then
    printf '%s\n' "Usage: macos_brew_install <package> [package...]" >&2
    return 1
  fi

  if ! macos_has_brew; then
    printf '%s\n' "Error: Homebrew is not installed." >&2
    printf '%s\n' "Install from: https://brew.sh" >&2
    return 1
  fi

  for _pkg in "$@"; do
    if brew list "$_pkg" >/dev/null 2>&1; then
      printf '%s\n' "  ✓ $_pkg already installed"
    else
      printf '%s\n' "  → Installing $_pkg..."
      brew install "$_pkg" || {
        printf '%s\n' "  ✗ Failed to install $_pkg" >&2
      }
    fi
  done
}
