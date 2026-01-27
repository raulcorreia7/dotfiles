#!/bin/sh

set -e

# -----------------------------------------------------------------------------
# Paths and config
# -----------------------------------------------------------------------------

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

installed_count=0
failed_count=0
failed_categories=""

# -----------------------------------------------------------------------------
# Homebrew
# -----------------------------------------------------------------------------
check_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    error "Homebrew is not installed"
  fi
  log "Homebrew found: $(brew --version | head -n1)"
}

install_category() {
  category="$1"
  file="$PKGS_MACOS/$category"

  if [ ! -f "$file" ]; then
    log "Skipping $category: file not found"
    return
  fi

  info "Installing $category..."

  if brew bundle --file="$file" --no-lock 2>&1; then
    log "✓ $category installed successfully"
    installed_count=$((installed_count + 1))
  else
    log "✗ $category installation failed"
    failed_count=$((failed_count + 1))
    if [ -z "$failed_categories" ]; then
      failed_categories="$category"
    else
      failed_categories="$failed_categories, $category"
    fi
  fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  log "=== macOS Package Installer ==="
  log ""

  check_brew
  log ""

  for category in $CATEGORIES; do
    install_category "$category"
    log ""
  done

  log "=== Summary ==="
  log "Installed: $installed_count"
  log "Failed: $failed_count"
  if [ "$failed_count" -gt 0 ]; then
    log "Failed categories: $failed_categories"
  fi
}

main "$@"
