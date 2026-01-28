#!/bin/sh
set -eu
# macOS package installer using Homebrew.
#
# Usage:
#   ./install-macos.sh [options]
#
# Options:
#   --dry-run          Preview what would be installed without installing
#   --category <name>  Install only specific category (base, cli, dev, gui)
#   --no-gui           Skip GUI packages
#   --help             Show this help message

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

# ------------------------------------------------------------------------------
# SECTION 2: Configuration
# ------------------------------------------------------------------------------

CATEGORIES="base cli dev gui"

DRY_RUN=0
SKIP_GUI=0
SELECTED_CATEGORY=""
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
      --category)
        if [ -n "${2:-}" ]; then
          SELECTED_CATEGORY="$2"
          shift 2
        else
          error "--category requires an argument"
        fi
        ;;
      --no-gui)
        SKIP_GUI=1
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

check_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    error "Homebrew is not installed. Install from https://brew.sh"
  fi
  log "Homebrew found: $(brew --version | head -n1)"
}

get_category_file() {
  _category="$1"
  _file="$PKGS_MACOS/$_category"
  if [ -f "$_file" ]; then
    printf '%s' "$_file"
  else
    printf ''
  fi
}

install_category() {
  _category="$1"
  _file=$(get_category_file "$_category")

  if [ -z "$_file" ] || [ ! -f "$_file" ]; then
    log "Note: No Brewfile for category '$_category'"
    return 0
  fi

  # Count packages in file (excluding comments and empty lines)
  _pkg_count=$(grep -v '^#' "$_file" | grep -v '^[[:space:]]*$' | wc -l)
  info "[$_category] Found $_pkg_count packages"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "[dry-run] Would install from $_file"
    _would_install=$(grep -v '^#' "$_file" | grep -v '^[[:space:]]*$' | grep -v '^cask ')
    _would_cask=$(grep '^cask ' "$_file" 2>/dev/null || true)

    printf '%s\n' "$_would_install" | while read -r pkg; do
      [ -n "$pkg" ] || continue
      if brew list "$pkg" >/dev/null 2>&1; then
        log "  [skip] $pkg (already installed)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      else
        log "  [install] $pkg"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      fi
    done

    printf '%s\n' "$_would_cask" | while read -r line; do
      [ -n "$line" ] || continue
      _cask=$(printf '%s' "$line" | sed 's/cask "//; s/"$//')
      if brew list --cask "$_cask" >/dev/null 2>&1; then
        log "  [skip] $_cask (cask, already installed)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      else
        log "  [install] $_cask (cask)"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      fi
    done
    return 0
  fi

  info "Installing $_category..."
  if brew bundle --file="$_file" --no-lock 2>&1; then
    log "✓ $_category installed successfully"
    INSTALLED_COUNT=$((INSTALLED_COUNT + _pkg_count))
  else
    log "✗ $_category installation had errors"
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
}

show_summary() {
  log ""
  log "=== Installation Summary ==="
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Mode: DRY RUN (no changes made)"
  fi
  log "Packages to install/newly installed: $INSTALLED_COUNT"
  log "Skipped (already installed): $SKIPPED_COUNT"
  if [ "$FAILED_COUNT" -gt 0 ]; then
    log "Categories with errors: $FAILED_COUNT"
  fi
}

# ------------------------------------------------------------------------------
# SECTION 4: Main
# ------------------------------------------------------------------------------

main() {
  parse_args "$@"

  log "=== macOS Package Installer ==="
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Mode: DRY RUN (preview only)"
  fi
  log ""

  check_brew
  log ""

  # Determine which categories to install
  _categories_to_install="$CATEGORIES"
  if [ -n "$SELECTED_CATEGORY" ]; then
    _categories_to_install="$SELECTED_CATEGORY"
  fi

  # Install each category
  for _cat in $_categories_to_install; do
    if [ "$_cat" = "gui" ] && [ "$SKIP_GUI" -eq 1 ]; then
      log "Skipping GUI packages (--no-gui)"
      continue
    fi

    install_category "$_cat"
    log ""
  done

  show_summary
}

main "$@"
