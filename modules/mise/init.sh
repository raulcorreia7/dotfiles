#!/bin/sh
# Runtime version manager integration - lazy loaded for performance.
#
# Disable: DOTFILES_ENABLE_MISE=0

# ------------------------------------------------------------------------------
# SECTION 1: Guard/Checks
# ------------------------------------------------------------------------------

__dot_has mise || return 0
[ -t 0 ] || return 0

# ------------------------------------------------------------------------------
# SECTION 2: Lazy Loading Function
# ------------------------------------------------------------------------------

# Create wrapper function that loads mise on first call.
# This avoids ~40-45ms startup impact from `eval "$(mise activate)"`.
mise() {
  # Remove this wrapper function
  unset -f mise 2>/dev/null || unset mise 2>/dev/null

  # Load mise shell integration
  _shell=$(__dot_shell_type)
  eval "$(mise activate "$_shell" 2>/dev/null)" || true
  unset _shell

  # Call the real mise command with original arguments
  command mise "$@"
}

# ------------------------------------------------------------------------------
# SECTION 3: Optional Precmd Hook (zsh only)
# ------------------------------------------------------------------------------

# For zsh, also defer loading until first prompt using precmd hook.
# This ensures mise is available for the first command without the wrapper.
if [ -n "${ZSH_VERSION:-}" ]; then
  _mise_precmd() {
    # Remove this hook after first execution
    precmd_functions=(${precmd_functions:#_mise_precmd})
    unset -f _mise_precmd 2>/dev/null || true

    # Load mise if not already loaded (wrapper was never called)
    if __dot_has mise && [ -z "${__DOT_MISE_LOADED:-}" ]; then
      __dot_debug "dotfiles: mise loading via precmd"
      _shell=$(__dot_shell_type)
      eval "$(mise activate "$_shell" 2>/dev/null)" || true
      unset _shell
      __DOT_MISE_LOADED=1
    fi
  }
  # Add to precmd_functions array for zsh
  precmd_functions+=(_mise_precmd)
fi
