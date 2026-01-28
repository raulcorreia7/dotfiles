#!/bin/sh
# Linux distribution and package manager utilities.

# Source lib/utils.sh for base detection functions
if [ -r "${DOTFILES_DIR:-$HOME/.dotfiles}/lib/utils.sh" ]; then
  # shellcheck source=../lib/utils.sh
  . "${DOTFILES_DIR:-$HOME/.dotfiles}/lib/utils.sh"
fi

# ------------------------------------------------------------------------------
# SECTION 1: Distribution Detection
# ------------------------------------------------------------------------------

# Note: get_distro() is provided by lib/utils.sh
# It reads /etc/os-release and outputs the ID field.

# Get the Linux distribution family.
# Maps distro IDs to their family (debian, rhel, arch, suse, alpine).
# Outputs the family name or empty string if unknown.
linux_get_distro_family() {
  _distro=$(get_distro)

  case "$_distro" in
    # Arch family
    arch | manjaro | endeavouros | garuda | cachyos)
      printf '%s' "arch"
      ;;
    # Debian family
    debian | ubuntu | linuxmint | pop | elementary | zorin | kali | raspbian)
      printf '%s' "debian"
      ;;
    # RHEL family
    fedora | rhel | centos | rocky | alma | oracle)
      printf '%s' "rhel"
      ;;
    # SUSE family
    opensuse* | suse* | sles)
      printf '%s' "suse"
      ;;
    # Alpine family
    alpine)
      printf '%s' "alpine"
      ;;
    *)
      # Unknown family
      return 1
      ;;
  esac
}

# ------------------------------------------------------------------------------
# SECTION 2: Package Manager Detection
# ------------------------------------------------------------------------------

# Check if apt package manager is available.
# Returns 0 (true) if apt is found, 1 (false) otherwise.
linux_has_apt() {
  command -v apt-get >/dev/null 2>&1 || command -v apt >/dev/null 2>&1
}

# Check if pacman package manager is available.
# Returns 0 (true) if pacman is found, 1 (false) otherwise.
linux_has_pacman() {
  command -v pacman >/dev/null 2>&1
}

# Check if dnf/yum package manager is available.
# Returns 0 (true) if dnf or yum is found, 1 (false) otherwise.
linux_has_dnf() {
  command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# SECTION 3: Package Management Helpers
# ------------------------------------------------------------------------------

# Show the appropriate install command for the current distribution.
# This is a dry-run helper - it only prints what command to run.
# Usage: linux_pkg_install <package_name>
linux_pkg_install() {
  _pkg="${1:-}"

  if [ -z "$_pkg" ]; then
    printf '%s\n' "Usage: linux_pkg_install <package_name>" >&2
    return 1
  fi

  _family=$(linux_get_distro_family)

  case "$_family" in
    arch)
      if linux_has_pacman; then
        printf '%s\n' "sudo pacman -S $_pkg"
      else
        printf '%s\n' "No package manager found for Arch family" >&2
        return 1
      fi
      ;;
    debian)
      if command -v apt >/dev/null 2>&1; then
        printf '%s\n' "sudo apt install $_pkg"
      else
        printf '%s\n' "sudo apt-get install $_pkg"
      fi
      ;;
    rhel)
      if command -v dnf >/dev/null 2>&1; then
        printf '%s\n' "sudo dnf install $_pkg"
      else
        printf '%s\n' "sudo yum install $_pkg"
      fi
      ;;
    suse)
      printf '%s\n' "sudo zypper install $_pkg"
      ;;
    alpine)
      printf '%s\n' "sudo apk add $_pkg"
      ;;
    *)
      printf '%s\n' "Unknown distribution family. Install manually: $_pkg" >&2
      return 1
      ;;
  esac
}
