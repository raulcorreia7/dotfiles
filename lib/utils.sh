#!/bin/sh
# Platform detection utilities.

# ------------------------------------------------------------------------------
# SECTION 1: WSL Detection
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
# SECTION 2: macOS Detection
# ------------------------------------------------------------------------------

# Check if running on macOS (Darwin).
# Returns 0 (true) if on macOS, 1 (false) otherwise.
is_darwin() {
  [ "$(uname -s)" = "Darwin" ]
}

# Alias for is_darwin().
# Check if running on macOS.
# Returns 0 (true) if on macOS, 1 (false) otherwise.
is_macos() {
  is_darwin
}

# ------------------------------------------------------------------------------
# SECTION 3: Linux Detection
# ------------------------------------------------------------------------------

# Check if running on Linux (not WSL, not macOS).
# Returns 0 (true) if on Linux, 1 (false) otherwise.
is_linux() {
  # Must be Linux kernel
  [ "$(uname -s)" = "Linux" ] || return 1

  # Must not be WSL
  is_wsl && return 1

  return 0
}

# ------------------------------------------------------------------------------
# SECTION 4: Distribution Detection
# ------------------------------------------------------------------------------

# Get the Linux distribution ID.
# Reads /etc/os-release and outputs the ID field.
# Returns empty string if not on Linux or os-release not found.
get_distro() {
  if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    printf '%s\n' "${ID:-}"
  fi
}

# Check if running on Arch Linux or derivatives (Manjaro).
# Returns 0 (true) if on Arch, 1 (false) otherwise.
is_arch() {
  case "$(get_distro)" in
    arch | manjaro*) return 0 ;;
    *) return 1 ;;
  esac
}
