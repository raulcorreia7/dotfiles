#!/bin/sh
# Phase: Tools - Install mise tools, zimfw modules, and neovim plugins

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
INSTALL_DIR="${INSTALL_DIR:-$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)}"

. "$INSTALL_DIR/lib.sh"
. "$INSTALL_DIR/config.sh"

DOTFILES_ENABLE_MISE="${DOTFILES_ENABLE_MISE:-1}"
DOTFILES_ENABLE_ZIMFW="${DOTFILES_ENABLE_ZIMFW:-1}"
DOTFILES_ENABLE_NVIM="${DOTFILES_ENABLE_NVIM:-1}"
DOTFILES_ENABLE_RTK="${DOTFILES_ENABLE_RTK:-1}"

_run_mise() {
  [ "$DOTFILES_ENABLE_MISE" = "1" ] || {
    log_info "mise disabled"
    return 0
  }
  command -v mise >/dev/null 2>&1 || {
    log_info "mise not found, skipping"
    return 0
  }

  log_info "installing mise tools..."
  run_as_user "mise install" || return 1
  return 0
}

_run_zimfw() {
  [ "$DOTFILES_ENABLE_ZIMFW" = "1" ] || {
    log_info "zimfw disabled"
    return 0
  }
  command -v zsh >/dev/null 2>&1 || {
    log_info "zsh not found, skipping zimfw"
    return 0
  }

  zimfw_zsh=""
  for candidate in "$HOME/.zim/zimfw.zsh" "/usr/share/zimfw/zimfw.zsh"; do
    [ -r "$candidate" ] && zimfw_zsh="$candidate" && break
  done

  [ -n "$zimfw_zsh" ] || {
    log_info "zimfw not found, skipping"
    return 0
  }

  modules_dir="${DOTFILES_ZIM_HOME:-$DOTFILES_DIR/config/zimfw}/modules"
  if [ -d "$modules_dir" ]; then
    empty_modules=$(find "$modules_dir" -maxdepth 1 -type d -empty 2>/dev/null | wc -l)
    if [ "$empty_modules" -gt 0 ]; then
      log_debug "cleaning $empty_modules empty module directories"
      find "$modules_dir" -maxdepth 1 -type d -empty -delete
    fi
  fi

  log_info "installing zimfw modules..."
  run_as_user "ZIM_HOME=\"$DOTFILES_ZIM_HOME\" ZIM_CONFIG_FILE=\"$DOTFILES_ZIM_CONFIG\" zsh -c '. \"$zimfw_zsh\" install'" || return 1

  log_info "building zimfw init..."
  run_as_user "ZIM_HOME=\"$DOTFILES_ZIM_HOME\" ZIM_CONFIG_FILE=\"$DOTFILES_ZIM_CONFIG\" zsh -c '. \"$zimfw_zsh\" build'" || return 1

  return 0
}

_run_nvim() {
  [ "$DOTFILES_ENABLE_NVIM" = "1" ] || {
    log_info "neovim plugin install disabled"
    return 0
  }
  command -v nvim >/dev/null 2>&1 || {
    log_info "neovim not found, skipping"
    return 0
  }

  log_info "syncing neovim plugins..."
  nvim --headless -c 'Lazy! sync' -c 'qa' >/dev/null 2>&1 && log_info "neovim plugins synced" ||
    log_warn "neovim plugin sync may have failed"

  return 0
}

_run_rtk() {
  [ "$DOTFILES_ENABLE_RTK" = "1" ] || {
    log_info "rtk disabled"
    return 0
  }
  command -v rtk >/dev/null 2>&1 || {
    log_info "rtk not found, skipping"
    return 0
  }

  log_info "configuring rtk opencode plugin..."
  if rtk init -g --opencode --auto-patch >/dev/null 2>&1; then
    log_info "rtk opencode plugin configured"
  else
    log_warn "rtk init failed (may already be configured)"
  fi

  return 0
}

run_phase() {
  log_info "running tool setup..."
  _run_mise || return 1
  _run_zimfw || return 1
  _run_nvim || return 1
  _run_rtk || return 1
  log_info "tools complete"
  return 0
}

run_phase_direct "$0"
