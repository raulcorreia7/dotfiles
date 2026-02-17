#!/bin/sh
# Phase: Setup - Create directories and link configs

run_phase_direct "$0"

run_phase() {
  log_info "running setup..."

  if ! sh "$INSTALL_DIR/link.sh"; then
    log_error "setup failed"
    return 1
  fi

  log_info "setup complete"
  return 0
}
