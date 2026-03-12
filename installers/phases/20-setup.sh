#!/bin/sh
# Phase: Setup - Create directories and link configs

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
INSTALL_DIR="${INSTALL_DIR:-$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)}"

. "$INSTALL_DIR/lib.sh"
. "$INSTALL_DIR/config.sh"

run_phase() {
  log_info "running setup..."

  if ! sh "$INSTALL_DIR/link.sh"; then
    log_error "setup failed"
    return 1
  fi

  log_info "setup complete"
  return 0
}

run_phase_direct "$0"
