#!/bin/sh
# WSL-specific helpers for Windows interoperability.

# Note: The wsl_* functions below are utilities for WSL users.
# They are not called internally but available for interactive use.

# Re-entrancy guard
[ -n "${__DOTFILES_WSL_LOADED:-}" ] && return 0
__DOTFILES_WSL_LOADED=1

# Source lib/utils.sh for base detection functions
if [ -r "${DOTFILES_DIR:-$HOME/.dotfiles}/lib/utils.sh" ]; then
  # shellcheck source=../lib/utils.sh
  . "${DOTFILES_DIR:-$HOME/.dotfiles}/lib/utils.sh"
fi

# ------------------------------------------------------------------------------
# SECTION 1: Public API
# ------------------------------------------------------------------------------

# Get Windows user home directory
# Uses wslpath to convert Windows path
# Output: Windows home directory in WSL path format (e.g., /mnt/c/Users/username)
wsl_windows_home() {
  _wsl_windows_home() {
    _win_home=""

    # Try to get from wslpath and USERPROFILE
    if command -v wslpath >/dev/null 2>&1 && [ -n "${USERPROFILE:-}" ]; then
      wslpath -u "$USERPROFILE" 2>/dev/null && return 0
    fi

    # Try WINDOWS_HOME environment variable
    if [ -n "${WINDOWS_HOME:-}" ]; then
      printf '%s' "$WINDOWS_HOME"
      return 0
    fi

    # Fallback: construct from /mnt/c/Users/$USER
    if [ -d "/mnt/c/Users" ]; then
      # Try current USER first
      if [ -n "${USER:-}" ] && [ -d "/mnt/c/Users/${USER}" ]; then
        printf '/mnt/c/Users/%s' "$USER"
        return 0
      fi

      # Try to find the directory owned by the current user
      for _dir in /mnt/c/Users/*; do
        if [ -d "$_dir" ] && [ ! "$_dir" = "/mnt/c/Users/Public" ] && [ ! "$_dir" = "/mnt/c/Users/Default" ]; then
          printf '%s' "$_dir"
          return 0
        fi
      done
    fi

    return 1
  }

  _wsl_windows_home
  unset -f _wsl_windows_home
}

# Copy to Windows clipboard
# Usage: echo "text" | wsl_clipboard_copy
# Falls back to xclip/xsel for native Linux
wsl_clipboard_copy() {
  if is_wsl; then
    # Use Windows clip.exe
    if command -v clip.exe >/dev/null 2>&1; then
      clip.exe
      return 0
    fi
  fi

  # Fallback to native Linux clipboard tools
  if command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
    return 0
  fi

  if command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
    return 0
  fi

  printf '%s\n' "wsl_clipboard_copy: no clipboard tool available (clip.exe, xclip, or xsel)" >&2
  return 1
}

# Open files with Windows default applications
# Usage: wsl_open <file_or_url>
wsl_open() {
  _wsl_open() {
    [ $# -eq 0 ] && { printf '%s\n' "wsl_open: no file or URL specified" >&2; return 1; }

    _target="$1"

    # Use wslview if available (from wslu package)
    if command -v wslview >/dev/null 2>&1; then
      wslview "$_target"
      return 0
    fi

    # Use cmd.exe /c start for WSL
    if is_wsl && command -v cmd.exe >/dev/null 2>&1; then
      # Convert path to Windows format if it's a file
      if [ -e "$_target" ]; then
        _win_path=$(wslpath -w "$_target" 2>/dev/null) || _win_path="$_target"
      else
        _win_path="$_target"
      fi

      # Use start command via cmd.exe
      cmd.exe /c start "" "$_win_path" 2>/dev/null
      return 0
    fi

    # Fallback to xdg-open for native Linux
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$_target"
      return 0
    fi

    printf '%s\n' "wsl_open: no open tool available (wslview, cmd.exe, or xdg-open)" >&2
    return 1
  }

  _wsl_open "$@"
  unset -f _wsl_open
}

# Convert WSL path to Windows path
# Usage: wsl_path_to_win <wsl_path>
# Output: Windows path format (e.g., C:\Users\name)
wsl_path_to_win() {
  _wsl_path_to_win() {
    [ $# -eq 0 ] && { printf '%s\n' "wsl_path_to_win: no path specified" >&2; return 1; }

    _path="$1"

    if command -v wslpath >/dev/null 2>&1; then
      wslpath -w "$_path"
      return 0
    fi

    # Manual conversion fallback
    # Convert /mnt/c/... to C:\... format
    case "$_path" in
      /mnt/?/*)
        _drive=$(printf '%s' "$_path" | cut -d'/' -f3 | tr '[:lower:]' '[:upper:]')
        _rest=$(printf '%s' "$_path" | cut -d'/' -f4-)
        # Replace slashes with backslashes
        _rest=$(printf '%s' "/$_rest" | tr '/' '\\')
        printf '%s:%s' "$_drive" "$_rest"
        return 0
        ;;
      *)
        printf '%s' "$_path"
        return 0
        ;;
    esac
  }

  _wsl_path_to_win "$@"
  unset -f _wsl_path_to_win
}

# Convert Windows path to WSL path
# Usage: wsl_path_from_win <windows_path>
# Output: WSL path format (e.g., /mnt/c/Users/name)
wsl_path_from_win() {
  _wsl_path_from_win() {
    [ $# -eq 0 ] && { printf '%s\n' "wsl_path_from_win: no path specified" >&2; return 1; }

    _path="$1"

    if command -v wslpath >/dev/null 2>&1; then
      wslpath -u "$_path"
      return 0
    fi

    # Manual conversion fallback
    # Convert C:\... to /mnt/c/... format
    case "$_path" in
      [A-Za-z]:\\*)
        _drive=$(printf '%s' "$_path" | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')
        _rest=$(printf '%s' "$_path" | cut -d':' -f2-)
        # Replace backslashes with slashes
        _rest=$(printf '%s' "$_rest" | tr '\\' '/')
        printf '/mnt/%s%s' "$_drive" "$_rest"
        return 0
        ;;
      *)
        printf '%s' "$_path"
        return 0
        ;;
    esac
  }

  _wsl_path_from_win "$@"
  unset -f _wsl_path_from_win
}
