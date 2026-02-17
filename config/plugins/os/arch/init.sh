#!/bin/sh
# Arch Linux system maintenance helpers.

dot_has pacman || return 0

DOTFILES_OS_ARCH_ASSUME_YES="${DOTFILES_OS_ARCH_ASSUME_YES:-${DOTFILES_ARCH_ASSUME_YES:-0}}"

_arch_assume_yes_flag() {
  [ "$DOTFILES_OS_ARCH_ASSUME_YES" = "1" ] && printf '%s\n' "--noconfirm"
}

_arch_confirm() {
  prompt="$1"
  [ "$DOTFILES_OS_ARCH_ASSUME_YES" = "1" ] && return 0
  printf '%s [y/N] ' "$prompt"
  read -r response
  case "$response" in
    [yY][eE][sS] | [yY]) return 0 ;;
    *) return 1 ;;
  esac
}

__rdf_arch_orphans() {
  case "${1:-}" in
    --remove | -r)
      orphans=$(pacman -Qdtq 2>/dev/null)
      [ -n "$orphans" ] || {
        echo "No orphans found"
        return 0
      }
      printf 'Orphan packages:\n%s\n' "$orphans"
      _arch_confirm "Remove?" && printf '%s\n' "$orphans" | sudo pacman -Rns - $(_arch_assume_yes_flag)
      ;;
    "")
      pacman -Qdtq 2>/dev/null || echo "No orphans found"
      ;;
    *)
      echo "Usage: rdf orphans [--remove|-r]"
      return 1
      ;;
  esac
}

__rdf_arch_cache() {
  case "${1:-}" in
    --clean | -c)
      du -sh /var/cache/pacman/pkg/ 2>/dev/null
      _arch_confirm "Clean?" && sudo pacman -Sc $(_arch_assume_yes_flag)
      ;;
    "")
      du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1
      ;;
    *)
      echo "Usage: rdf cache [--clean|-c]"
      return 1
      ;;
  esac
}

__rdf_arch_update() {
  case "${1:-}" in
    --full | -f)
      echo "=== Full System Maintenance ==="
      echo ""

      orphans=$(pacman -Qdtq 2>/dev/null)
      if [ -n "$orphans" ]; then
        echo "Orphans:"
        echo "$orphans"
        _arch_confirm "Remove?" && printf '%s\n' "$orphans" | sudo pacman -Rns - $(_arch_assume_yes_flag)
        echo ""
      fi

      echo "Cache: $(du -sh /var/cache/pacman/pkg/ 2>/dev/null | cut -f1)"
      _arch_confirm "Clean?" && sudo pacman -Sc $(_arch_assume_yes_flag)
      echo ""

      echo "Updating..."
      sudo pacman -Syu $(_arch_assume_yes_flag)
      dot_has paru && paru -Syu $(_arch_assume_yes_flag)

      echo ""
      echo "=== Done ==="
      ;;
    "")
      sudo pacman -Syu $(_arch_assume_yes_flag)
      dot_has paru && paru -Syu $(_arch_assume_yes_flag)
      ;;
    *)
      echo "Usage: rdf update [--full|-f]"
      return 1
      ;;
  esac
}
