#!/bin/sh
# Phase: Check - Validate system readiness before installation

run_phase_direct "$0"

_check_shell() {
  log_info "checking shell availability..."

  if ! command -v bash >/dev/null 2>&1 && ! command -v zsh >/dev/null 2>&1; then
    log_error "no supported shell found (bash or zsh required)"
    return 1
  fi

  log_info "shell: ok"
  return 0
}

_check_required_commands() {
  log_info "checking required commands..."
  require_command "git" "git is required for cloning repositories"
  return 0
}

_check_dotfiles_structure() {
  log_info "checking dotfiles structure..."
  require_file "$DOTFILES_DIR/init.sh" "init.sh not found"
  require_file "$DOTFILES_DIR/config/runtime.sh" "runtime.sh not found"
  require_file "$DOTFILES_DIR/config/aliases" "aliases not found"
  return 0
}

_check_os_support() {
  log_info "checking OS support..."

  OS=$(detect_os)

  case "$OS" in
    arch)
      log_info "Arch-based system detected"
      ;;
    macos)
      log_info "macOS detected"
      ;;
    debian | fedora)
      log_warn "Limited support for $OS"
      ;;
    windows)
      log_warn "Windows requires manual installation"
      ;;
    *)
      log_error "unsupported OS: $OS"
      return 1
      ;;
  esac

  return 0
}

_show_summary() {
  log_info "system check complete"
  log_info ""
  log_info "Summary:"
  log_info "  OS: $(detect_os)"
  log_info "  Dotfiles: $DOTFILES_DIR"
  log_info "  Config: ${XDG_CONFIG_HOME:-$HOME/.config}"
  log_info ""
  log_info "Ready to proceed with installation"
}

run_phase() {
  log_info "validating system..."
  _check_shell || return 1
  _check_required_commands || return 1
  _check_dotfiles_structure || return 1
  _check_os_support || return 1
  _show_summary
  log_info "check complete"
  return 0
}
