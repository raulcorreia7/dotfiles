#!/bin/sh
# Arch Linux system maintenance helpers.

# -----------------------------------------------------------------------------
# Package Updates
# -----------------------------------------------------------------------------

__dot_has pacman || return 0

__arch_assume_yes_flag() {
  # Set DOTFILES_ARCH_ASSUME_YES=1 to skip prompts for pacman/paru.
  if [ "${DOTFILES_ARCH_ASSUME_YES:-0}" = "1" ]; then
    printf '%s\n' "--noconfirm"
  fi
}

arch_pacmanupdate() {
  case "$1" in
    -h | --help)
      printf 'Usage: arch_pacmanupdate\nUpdate system packages via pacman.\n'
      return 0
      ;;
  esac
  sudo pacman -Syu "$(__arch_assume_yes_flag)"
}

arch_paruupdate() {
  case "$1" in
    -h | --help)
      printf 'Usage: arch_paruupdate\nUpdate AUR packages via paru.\n'
      return 0
      ;;
  esac
  __dot_has paru || {
    printf '%s\n' 'paru not found; skipping AUR updates.'
    return 0
  }
  paru -Syu "$(__arch_assume_yes_flag)"
}

arch_sysupdate() {
  case "$1" in
    -h | --help)
      printf 'Usage: arch_sysupdate\nUpdate system and AUR packages.\n'
      return 0
      ;;
  esac
  arch_pacmanupdate && arch_paruupdate
}

# -----------------------------------------------------------------------------
# System Maintenance
# -----------------------------------------------------------------------------

arch_sysupdatefull() {
  case "$1" in
    -h | --help)
      printf 'Usage: arch_sysupdatefull\nInteractive system maintenance workflow.\n'
      return 0
      ;;
  esac

  (
    set -e

    printf '%s\n' '=== Arch Linux System Maintenance ==='

    orphans=$(pacman -Qdtq)
    if [ -n "$orphans" ]; then
      printf '%s\n' 'Orphan packages found:'
      printf '%s\n' "$orphans"
      printf '%s' 'Remove orphans? [y/N] '
      read -r response
      case "$response" in
        [yY][eE][sS] | [yY])
          pacman -Qdtq | sudo pacman -Rns -
          ;;
      esac
    fi

    if pacman -Qk 2>&1 | grep -qE '[1-9][0-9]* missing files$'; then
      printf '%s\n' 'Broken packages detected. Aborting.'
      exit 1
    fi

    cache_size=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
    if [ -n "$cache_size" ]; then
      printf '%s\n' "Package cache size: $cache_size"
    else
      printf '%s\n' "Package cache size: unknown"
    fi
    printf '%s' 'Clean package cache? [y/N] '
    read -r response
    case "$response" in
      [yY][eE][sS] | [yY])
        sudo pacman -Sc
        ;;
    esac

    arch_pacmanupdate && arch_paruupdate

    printf '%s\n' '=== System maintenance complete ==='
  )
}
