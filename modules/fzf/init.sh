#!/bin/sh
# FZF plugin: fuzzy finder integration - lazy loaded for performance.
#
# Disable: DOTFILES_ENABLE_FZF=0

# ------------------------------------------------------------------------------
# SECTION 1: Guard/Checks
# ------------------------------------------------------------------------------

__dot_has fzf || return 0

# Only for zsh/bash shells
_shell=$(__dot_shell_type)
case "$_shell" in
zsh | bash) ;;
*)
  unset _shell
  return 0
  ;;
esac

# ------------------------------------------------------------------------------
# SECTION 2: Configuration (Immediate)
# ------------------------------------------------------------------------------

# Set up fzf defaults (if not already configured)
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 80% --layout=reverse --border}"

# ------------------------------------------------------------------------------
# SECTION 3: True Lazy Loading
# ------------------------------------------------------------------------------

# Load fzf bindings only when user presses a bound key.
# This avoids ~3-5ms startup cost until fzf is actually used.

_fzf_load_real_bindings() {
  [ "${__DOT_FZF_LOADED:-0}" = "1" ] && return 0

  __dot_debug "dotfiles: fzf loading key bindings"

  if fzf --"$_shell" >/dev/null 2>&1; then
    eval "$(fzf --"$_shell")"
  fi

  __DOT_FZF_LOADED=1
}

# For zsh: use zle widgets that load fzf on first use, then delegate
case "$_shell" in
zsh)
  # These widgets intercept the key press, load fzf, then re-trigger
  _fzf_lazy_widget() {
    local widget_name="$1"
    shift
    _fzf_load_real_bindings
    # Re-bind the real widget
    case "$widget_name" in
    fzf-file-widget)    bindkey '^T' fzf-file-widget 2>/dev/null ;;
    fzf-history-widget) bindkey '^R' fzf-history-widget 2>/dev/null ;;
    fzf-cd-widget)      bindkey '\ec' fzf-cd-widget 2>/dev/null ;;
    esac
    # Now trigger the real widget
    zle "$widget_name" "$@"
  }

  # Wrapper widgets
  _fzf_file_widget() { _fzf_lazy_widget fzf-file-widget; }
  _fzf_history_widget() { _fzf_lazy_widget fzf-history-widget; }
  _fzf_cd_widget() { _fzf_lazy_widget fzf-cd-widget; }

  # Register wrapper widgets
  zle -N _fzf_file_widget
  zle -N _fzf_history_widget
  zle -N _fzf_cd_widget

  # Bind to lazy wrappers
  bindkey '^T' _fzf_file_widget
  bindkey '^R' _fzf_history_widget
  bindkey '\ec' _fzf_cd_widget
  ;;

bash)
  # For bash: use the builtin key sequence approach
  # but wrapped in functions that load first

  # Create lazy loader functions
  _fzf_bash_ctrl_t() {
    _fzf_load_real_bindings
    # After eval, fzf-file-widget function should exist
    # Call it directly
    fzf-file-widget 2>/dev/null || true
  }
  _fzf_bash_ctrl_r() {
    _fzf_load_real_bindings
    fzf-history-widget 2>/dev/null || true
  }
  _fzf_bash_alt_c() {
    _fzf_load_real_bindings
    fzf-cd-widget 2>/dev/null || true
  }

  # Export for use
  export -f _fzf_bash_ctrl_t _fzf_bash_ctrl_r _fzf_bash_alt_c 2>/dev/null || true

  # Use bind -x for bash to call shell functions
  # This only works in newer bash, so we also use the key sequence fallback
  bind -x '"\C-t": _fzf_bash_ctrl_t' 2>/dev/null || \
    bind '"\C-t": "\C-a\C-k_fzf_bash_ctrl_t\C-m"' 2>/dev/null || true
  bind -x '"\C-r": _fzf_bash_ctrl_r' 2>/dev/null || \
    bind '"\C-r": "\C-a\C-k_fzf_bash_ctrl_r\C-m"' 2>/dev/null || true
  bind -x '"\ec": _fzf_bash_alt_c' 2>/dev/null || \
    bind '"\ec": "\C-a\C-k_fzf_bash_alt_c\C-m"' 2>/dev/null || true
  ;;
esac

unset _shell
