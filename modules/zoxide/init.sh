#!/bin/sh
# Zoxide plugin: smarter cd command integration - lazy loaded for performance.
#
# Disable: DOTFILES_ENABLE_ZOXIDE=0

# ------------------------------------------------------------------------------
# SECTION 1: Guard/Checks
# ------------------------------------------------------------------------------

__dot_has zoxide || return 0
[ -t 0 ] || return 0

# ------------------------------------------------------------------------------
# SECTION 2: Lazy Loading Function
# ------------------------------------------------------------------------------

# Create wrapper function that loads zoxide on first call.
# This avoids ~3ms startup impact from `eval "$(zoxide init)"`.
z() {
  # Remove this wrapper function
  unset -f z 2>/dev/null || unset z 2>/dev/null

  # Also remove zi wrapper if it exists (zoxide provides both)
  unset -f zi 2>/dev/null || unset zi 2>/dev/null || true

  # Load zoxide shell integration
  _shell=$(__dot_shell_type)
  eval "$(zoxide init "$_shell" 2>/dev/null)" || true
  unset _shell

  # Mark as loaded to prevent duplicate loading from precmd hook
  __DOT_ZOXIDE_LOADED=1

  # Call the real z function with original arguments
  z "$@"
}

# Wrapper for zi (zoxide interactive mode)
zi() {
  # Remove both wrapper functions
  unset -f z 2>/dev/null || unset z 2>/dev/null || true
  unset -f zi 2>/dev/null || unset zi 2>/dev/null

  # Load zoxide shell integration
  _shell=$(__dot_shell_type)
  eval "$(zoxide init "$_shell" 2>/dev/null)" || true
  unset _shell

  # Mark as loaded
  __DOT_ZOXIDE_LOADED=1

  # Call the real zi function with original arguments
  zi "$@"
}

# ------------------------------------------------------------------------------
# SECTION 3: Optional Precmd Hook (zsh only)
# ------------------------------------------------------------------------------

# For zsh, also defer loading until first prompt using precmd hook.
# This ensures zoxide is available without needing the wrapper.
if [ -n "${ZSH_VERSION:-}" ]; then
  _zoxide_precmd() {
    # Remove this hook after first execution
    precmd_functions=(${precmd_functions:#_zoxide_precmd})
    unset -f _zoxide_precmd 2>/dev/null || true

    # Load zoxide if not already loaded (wrapper was never called)
    if __dot_has zoxide && [ -z "${__DOT_ZOXIDE_LOADED:-}" ]; then
      __dot_debug "dotfiles: zoxide loading via precmd"
      _shell=$(__dot_shell_type)
      eval "$(zoxide init "$_shell" 2>/dev/null)" || true
      unset _shell
      __DOT_ZOXIDE_LOADED=1
    fi
  }
  # Add to precmd_functions array for zsh
  precmd_functions+=(_zoxide_precmd)
fi
