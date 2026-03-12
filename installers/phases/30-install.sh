#!/bin/sh
# Phase: Install - Install OS packages

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
INSTALL_DIR="${INSTALL_DIR:-$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)}"

. "$INSTALL_DIR/lib.sh"
. "$INSTALL_DIR/config.sh"

run_phase() {
  OS=$(detect_os)

  log_info "detecting OS..."

  case "$OS" in
  arch)
    require_file "$INSTALL_DIR/install-arch.sh" "Arch installer not found"
    log_info "installing Arch packages..."
    "$INSTALL_DIR/install-arch.sh" || return 1
    ;;
  macos)
    require_file "$INSTALL_DIR/install-macos.sh" "macOS installer not found"
    log_info "installing macOS packages..."
    "$INSTALL_DIR/install-macos.sh" || return 1
    ;;
  *)
    log_error "unsupported OS: $OS (supported: arch, macos)"
    return 1
    ;;
  esac

  log_info "install complete"
  return 0
}

run_phase_direct "$0"
