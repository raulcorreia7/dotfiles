#!/bin/sh
set -euo pipefail
# Arch Linux package installer (pacman + AUR via paru).
#
# Usage:
#   ./install-arch.sh [options]
#
# Options:
#   --dry-run     Preview what would be installed without installing
#   --no-aur      Skip AUR packages
#   --help        Show this help message

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

# ------------------------------------------------------------------------------
# SECTION 2: Configuration
# ------------------------------------------------------------------------------

DRY_RUN=0
SKIP_AUR=0
INSTALLED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

# ------------------------------------------------------------------------------
# SECTION 3: Helper Functions
# ------------------------------------------------------------------------------

show_help() {
  grep '^# ' "$0" | cut -c3-
  exit 0
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --no-aur)
        SKIP_AUR=1
        shift
        ;;
      --help | -h)
        show_help
        ;;
      *)
        error "Unknown option: $1"
        ;;
    esac
  done
}

check_sudo_access() {
  if ! command -v sudo >/dev/null 2>&1; then
    error 'sudo is required but not found'
  fi
  sudo -v 2>/dev/null || log "Note: sudo access will be required"
}

is_arch_based() {
  [ -f /etc/arch-release ] || [ -f /etc/cachyos-release ]
}

is_arch_from_os_release() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    [ "${ID:-}" = "arch" ] || [ "${ID:-}" = "cachyos" ]
  else
    return 1
  fi
}

install_pacman() {
  _pkg_file="$PKGS_ARCH_PACMAN_FILE"
  [ -f "$_pkg_file" ] || return 0

  _packages=$(read_packages "$_pkg_file")
  [ -n "$_packages" ] || return 0

  _total=$(printf '%s\n' "$_packages" | wc -l)
  info "Found $_total pacman packages"

  if [ "$DRY_RUN" -eq 1 ]; then
    for pkg in $_packages; do
      if pacman -Q "$pkg" >/dev/null 2>&1; then
        log "  [skip] $pkg (already installed)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      else
        log "  [install] $pkg"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      fi
    done
    return 0
  fi

  _to_install=""
  for pkg in $_packages; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    else
      _to_install="$_to_install $pkg"
    fi
  done

  if [ -n "$_to_install" ]; then
    info "Installing pacman packages..."
    # shellcheck disable=SC2086
    printf '%s\n' $_to_install | xargs -r sudo pacman -S --needed --noconfirm -- \
      && INSTALLED_COUNT=$((INSTALLED_COUNT + $(printf '%s\n' $_to_install | wc -w))) \
      || FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
}

install_paru() {
  __dot_has paru && return 0

  if [ "$DRY_RUN" -eq 1 ]; then
    log "[dry-run] Would bootstrap paru"
    return 0
  fi

  info "Installing paru..."

  if sudo pacman -Ss '^paru$' >/dev/null 2>&1; then
    sudo pacman -S --noconfirm paru
    return 0
  fi

  for pkg in git base-devel; do
    pacman -Q "$pkg" >/dev/null 2>&1 || sudo pacman -S --needed --noconfirm "$pkg"
  done

  _build_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/build/paru"
  rm -rf "$_build_dir"
  git clone "${AUR_BASE_URL}/paru.git" "$_build_dir"
  (cd "$_build_dir" && makepkg -si --noconfirm)
  rm -rf "$_build_dir"

  info "paru installed"
}

install_aur() {
  _pkg_file="$PKGS_ARCH_AUR_FILE"
  [ -f "$_pkg_file" ] || return 0

  _packages=$(read_packages "$_pkg_file")
  [ -n "$_packages" ] || return 0

  _total=$(printf '%s\n' "$_packages" | wc -l)
  info "Found $_total AUR packages"

  if [ "$DRY_RUN" -eq 1 ]; then
    for pkg in $_packages; do
      if paru -Q "$pkg" >/dev/null 2>&1; then
        log "  [skip] $pkg (already installed)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      else
        log "  [install] $pkg"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      fi
    done
    return 0
  fi

  _to_install=""
  for pkg in $_packages; do
    if paru -Q "$pkg" >/dev/null 2>&1; then
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    else
      _to_install="$_to_install $pkg"
    fi
  done

  if [ -n "$_to_install" ]; then
    info "Installing AUR packages..."
    # shellcheck disable=SC2086
    printf '%s\n' $_to_install | xargs -r paru -S --needed --noconfirm -- \
      && INSTALLED_COUNT=$((INSTALLED_COUNT + $(printf '%s\n' $_to_install | wc -w))) \
      || FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
}

show_summary() {
  log ""
  log "=== Summary ==="
  [ "$DRY_RUN" -eq 1 ] && log "Mode: DRY RUN"
  log "Installed: $INSTALLED_COUNT"
  log "Skipped: $SKIPPED_COUNT"
  [ "$FAILED_COUNT" -gt 0 ] && log "Failed: $FAILED_COUNT"
}

# ------------------------------------------------------------------------------
# SECTION 4: Main
# ------------------------------------------------------------------------------

main() {
  parse_args "$@"

  log "=== Arch Linux Package Installer ==="
  [ "$DRY_RUN" -eq 1 ] && log "Mode: DRY RUN"
  log ""

  check_sudo_access

  if ! is_arch_based && ! is_arch_from_os_release; then
    error "Unsupported distro. Arch/CachyOS only."
  fi

  install_pacman

  if [ "$SKIP_AUR" -eq 0 ]; then
    install_paru
    install_aur
  else
    log "Skipping AUR packages (--no-aur)"
  fi

  show_summary
}

main "$@"
