#!/bin/sh
# Standalone OS package installer. NOT run by install/install.sh.
# Run manually on a new machine, before or after ./install/install.sh.
#
# Usage: ./packages/install.sh [--help]
#
# Supported:
#   arch   pacman + AUR via paru (packages/arch/{pacman,aur})
#   macos  Homebrew bundle (packages/macos/{base,cli,development,gui})
#
# Windows: manual — see packages/install-windows.ps1
#
# Environment:
#   DOTFILES_OS_ARCH_ASSUME_YES=1  Non-interactive pacman/paru
#   DOTFILES_MACOS_CATEGORIES      Homebrew category order (default: base cli development gui)

set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../install/lib.sh"

show_help() {
  sed -n '/^#!/,/^$/p' "$0" | sed '1d;$d'
}

case "${1:-}" in
-h | --help)
  show_help
  exit 0
  ;;
"") ;;
*)
  log_error "Unknown option: $1"
  exit 1
  ;;
esac

case "$(detect_os)" in
arch)
  log_info "installing Arch packages..."
  sh "$SCRIPT_DIR/install-arch.sh"
  ;;
macos)
  log_info "installing macOS packages..."
  sh "$SCRIPT_DIR/install-macos.sh"
  ;;
*)
  log_error "unsupported OS: $(detect_os) (supported: arch, macos; see install-windows.ps1 for manual Windows setup)"
  exit 1
  ;;
esac
