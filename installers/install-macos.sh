#!/bin/sh
set -e
# macOS package installer via Homebrew

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

installed_count=0
failed_count=0
failed_categories=""
CATEGORIES="${DOTFILES_MACOS_CATEGORIES:-base cli development gui}"

check_brew() {
  command -v brew >/dev/null 2>&1 || {
    log_error "Homebrew is not installed"
    exit 1
  }
  log "Homebrew found: $(brew --version | head -n1)"
}

install_category() {
  category="$1"
  file="$PKGS_MACOS/$category"

  [ -f "$file" ] || {
    log "Skipping $category: file not found"
    return
  }

  log_info "Installing $category..."

  if brew bundle --file="$file" --no-lock 2>&1; then
    log "$category installed successfully"
    installed_count=$((installed_count + 1))
  else
    log_error "$category installation failed"
    failed_count=$((failed_count + 1))
    failed_categories="${failed_categories:+$failed_categories, }$category"
  fi
}

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
  [ "$failed_count" -gt 0 ] && log "Failed categories: $failed_categories"

  if [ "$failed_count" -gt 0 ]; then
    return 1
  fi
}

main "$@"
