#!/bin/sh
# Dotfiles Configuration Installer
# Pure configuration setup: check -> setup -> tools -> configure.
# OS package installation is separate: ./packages/install.sh
#
# Usage: ./install/install.sh [OPTIONS]
#
# Options:
#   -h, --help     Show this help message
#   -n, --dry-run  Show what would be done without executing
#
# Stages (in order):
#   check      Validate system readiness
#   setup      Create directories and link configs (GNU Stow)
#   tools      Install mise tools, zimfw modules, and neovim plugins
#   configure  Run post-install configuration
#
# Environment:
#   DOTFILES_ENABLE_MISE=1       Install mise tools (default)
#   DOTFILES_ENABLE_ZIMFW=1      Build zimfw (default)
#   DOTFILES_ENABLE_NVIM=1       Install nvim plugins (default)
#   DOTFILES_ENABLE_RTK=1        Install rtk (default)
#   DOTFILES_ENABLE_CONFIGURE=1  Run post-install configuration (default)
#   DOTFILES_DEBUG=1             Enable debug logging

set -e

DOTFILES_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
INSTALL_DIR="$DOTFILES_DIR/install"

. "$INSTALL_DIR/lib.sh"
. "$INSTALL_DIR/config.sh"

DRY_RUN=0

DOTFILES_ENABLE_MISE="${DOTFILES_ENABLE_MISE:-1}"
DOTFILES_ENABLE_ZIMFW="${DOTFILES_ENABLE_ZIMFW:-1}"
DOTFILES_ENABLE_NVIM="${DOTFILES_ENABLE_NVIM:-1}"
DOTFILES_ENABLE_RTK="${DOTFILES_ENABLE_RTK:-1}"
DOTFILES_ENABLE_CONFIGURE="${DOTFILES_ENABLE_CONFIGURE:-1}"

show_help() {
  sed -n '/^#!/,/^$/p' "$0" | sed '1d;$d'
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
      show_help
      exit 0
      ;;
    -n | --dry-run)
      DRY_RUN=1
      shift
      ;;
    -*)
      log_error "Unknown option: $1"
      exit 1
      ;;
    *)
      log_error "Unexpected argument: $1"
      exit 1
      ;;
    esac
  done
}

do_check() {
  log_info "validating system..."

  if ! command -v bash >/dev/null 2>&1 && ! command -v zsh >/dev/null 2>&1; then
    log_error "no supported shell found (bash or zsh required)"
    return 1
  fi
  log_info "shell: ok"

  require_command "git" "git is required for cloning repositories"
  require_command "stow" "GNU Stow is required for setup phase"

  require_file "$DOTFILES_DIR/init.sh" "init.sh not found"
  require_file "$DOTFILES_DIR/config/runtime.sh" "runtime.sh not found"
  require_file "$DOTFILES_DIR/config/aliases" "aliases not found"

  log_info "Summary:"
  log_info "  Dotfiles: $DOTFILES_DIR"
  log_info "  Config: ${XDG_CONFIG_HOME:-$HOME/.config}"
  log_info "check complete"
}

do_setup() {
  log_info "running setup..."
  sh "$INSTALL_DIR/link.sh" || {
    log_error "setup failed"
    return 1
  }
  log_info "setup complete"
}

_run_mise() {
  [ "$DOTFILES_ENABLE_MISE" = "1" ] || {
    log_info "mise disabled"
    return 0
  }
  command -v mise >/dev/null 2>&1 || {
    log_warn "mise not found, skipping"
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
    log_warn "zsh not found, skipping zimfw"
    return 0
  }

  zimfw_zsh=""
  for candidate in "$HOME/.zim/zimfw.zsh" "/usr/share/zimfw/zimfw.zsh"; do
    [ -r "$candidate" ] && zimfw_zsh="$candidate" && break
  done

  [ -n "$zimfw_zsh" ] || {
    log_warn "zimfw.zsh not found, skipping zimfw"
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
    log_warn "rtk not found, skipping"
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

do_tools() {
  log_info "installing tools..."
  _run_mise || return 1
  _run_zimfw || return 1
  _run_nvim || return 1
  _run_rtk || return 1
  log_info "tools complete"
}

do_configure() {
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
}

main() {
  parse_args "$@"

  export DOTFILES_DIR
  export INSTALL_DIR
  export DOTFILES_ZIM_HOME
  export DOTFILES_ZIM_CONFIG

  log "Starting configuration installation..."
  [ "$DRY_RUN" -eq 1 ] && log "=== DRY RUN MODE ==="

  for stage in do_check do_setup do_tools do_configure; do
    if [ "$DRY_RUN" -eq 1 ]; then
      log "[dry-run] would run: $stage"
      continue
    fi
    "$stage" || {
      log ""
      log_error "Stage failed: $stage"
      exit 1
    }
  done

  log ""
  log "Installation complete!"
  log "Reload your shell: source ~/.zshrc or restart your terminal"
}

main "$@"
