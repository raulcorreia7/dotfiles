#!/bin/sh
# Phase: Configure - Run post-install configuration

run_phase_direct "$0"

DOTFILES_ENABLE_CONFIGURE="${DOTFILES_ENABLE_CONFIGURE:-1}"

run_phase() {
  [ "$DOTFILES_ENABLE_CONFIGURE" = "1" ] || {
    log_info "configure disabled"
    return 0
  }

  if [ ! -x "$INSTALL_DIR/post-install.sh" ]; then
    log_info "post-install script not found, skipping"
    return 0
  fi

  log_info "running configuration..."
  "$INSTALL_DIR/post-install.sh" || return 1

  log_info "configure complete"
  return 0
}
