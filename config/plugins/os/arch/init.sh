#!/bin/sh
# Arch Linux system maintenance helpers.
# Loaded by rdf command when pacman is available.

dot_has pacman || return 0

# Configuration: Set DOTFILES_OS_ARCH_ASSUME_YES=1 to skip all prompts
DOTFILES_OS_ARCH_ASSUME_YES="${DOTFILES_OS_ARCH_ASSUME_YES:-0}"

# Get --noconfirm flag if auto-yes is enabled
# Usage: _arch_noconfirm_flag [force]
# If force is "force", always return --noconfirm (for after manual confirmation)
_arch_noconfirm_flag() {
  if [ "$DOTFILES_OS_ARCH_ASSUME_YES" = "1" ] || [ "${1:-}" = "force" ]; then
    printf '%s\n' "--noconfirm"
  fi
}

# Prompt for confirmation (respects DOTFILES_OS_ARCH_ASSUME_YES and tty status)
# Returns: 0 if yes/approved, 1 if no/declined
_arch_confirm() {
  confirm_message="$1"

  # Auto-accept if environment says to assume yes
  [ "$DOTFILES_OS_ARCH_ASSUME_YES" = "1" ] && return 0

  # Auto-decline if not running in a terminal (non-interactive)
  [ -t 0 ] || return 1

  printf '%s [y/N] ' "$confirm_message"
  IFS= read -r arch_confirm_response
  case "$arch_confirm_response" in
    [yY][eE][sS] | [yY]) return 0 ;;
    *) return 1 ;;
  esac
}

# Remove pacman's temporary download directories before cache cleanup.
# These can be left behind after interrupted operations and break pacman -Sc.
_arch_remove_stale_download_dirs() {
  sudo find /var/cache/pacman/pkg/ -mindepth 1 -maxdepth 1 -type d -name 'download-*' -exec rm -rf -- {} +
}

# Clean package cache safely.
# Prefer paccache because it is purpose-built for cache pruning.
_arch_clean_cache() {
  _arch_remove_stale_download_dirs

  if dot_has paccache; then
    sudo paccache -r
  else
    sudo pacman -Sc $(_arch_noconfirm_flag force)
  fi
}

# List or remove orphaned packages
# Usage: rdf orphans [--remove|-r]
dot_arch_orphans() {
  case "${1:-}" in
    --remove | -r)
      arch_orphan_packages=$(pacman -Qdtq 2>/dev/null)
      [ -n "$arch_orphan_packages" ] || {
        echo "No orphaned packages found"
        return 0
      }
      printf 'Orphaned packages:\n%s\n' "$arch_orphan_packages"
      if _arch_confirm "Remove these packages?"; then
        printf '%s\n' "$arch_orphan_packages" | sudo pacman -Rns - $(_arch_noconfirm_flag force)
      else
        echo "Cancelled"
      fi
      ;;
    "")
      arch_orphan_packages=$(pacman -Qdtq 2>/dev/null)
      if [ -n "$arch_orphan_packages" ]; then
        printf '%s\n' "$arch_orphan_packages"
      else
        echo "No orphaned packages found"
      fi
      ;;
    *)
      echo "Usage: rdf orphans [--remove|-r]"
      echo ""
      echo "List or remove orphaned packages (packages no longer needed)."
      echo ""
      echo "Options:"
      echo "  (no args)    List orphaned packages"
      echo "  --remove, -r List and prompt to remove orphaned packages"
      return 1
      ;;
  esac
}

# Show or clean package cache
# Usage: rdf cache [--clean|-c]
dot_arch_cache() {
  case "${1:-}" in
    --clean | -c)
      arch_cache_size=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
      echo "Cache size: $arch_cache_size"
      if _arch_confirm "Clean package cache?"; then
        _arch_clean_cache
        echo "Cache cleaned"
      else
        echo "Cancelled"
      fi
      ;;
    "")
      du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1
      ;;
    *)
      echo "Usage: rdf cache [--clean|-c]"
      echo ""
      echo "Show or clean pacman package cache."
      echo ""
      echo "Options:"
      echo "  (no args)   Show cache size"
      echo "  --clean, -c Show size and prompt to clean cache"
      return 1
      ;;
  esac
}

# Update system packages
# Usage: rdf update [--full|-f]
#
# Default: Updates packages with pacman/paru only
# --full:   Also removes orphans and cleans cache (no prompts in full mode)
dot_arch_update() {
  case "${1:-}" in
    --full | -f)
      echo "=== Full System Maintenance ==="
      echo ""

      # Remove orphans
      arch_orphan_packages=$(pacman -Qdtq 2>/dev/null)
      if [ -n "$arch_orphan_packages" ]; then
        echo "Found orphaned packages:"
        echo "$arch_orphan_packages"
        if _arch_confirm "Remove orphaned packages?"; then
          printf '%s\n' "$arch_orphan_packages" | sudo pacman -Rns - $(_arch_noconfirm_flag force)
          echo "Orphans removed"
        else
          echo "Skipping orphan removal"
        fi
        echo ""
      fi

      # Clean cache (automatic in full mode, no prompt)
      arch_cache_size=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)
      echo "Cleaning cache ($arch_cache_size)..."
      _arch_clean_cache
      echo ""

      # Update packages
      echo "Updating system packages..."
      sudo pacman -Syu $(_arch_noconfirm_flag)
      dot_has paru && paru -Syu $(_arch_noconfirm_flag)

      echo ""
      echo "=== System maintenance complete ==="
      ;;
    "")
      echo "Updating system packages..."
      sudo pacman -Syu $(_arch_noconfirm_flag)
      dot_has paru && paru -Syu $(_arch_noconfirm_flag)
      echo "Update complete"
      ;;
    *)
      echo "Usage: rdf update [--full|-f]"
      echo ""
      echo "Update system packages."
      echo ""
      echo "Options:"
      echo "  (no args)    Update packages only (pacman/paru -Syu)"
      echo "  --full, -f   Full maintenance: update + remove orphans + clean cache"
      echo ""
      echo "Examples:"
      echo "  rdf update        # Quick update"
      echo "  rdf update --full # Complete maintenance"
      return 1
      ;;
  esac
}
