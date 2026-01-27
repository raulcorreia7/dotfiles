#!/bin/sh
# FZF key bindings.

# -----------------------------------------------------------------------------
# Shell integration
# -----------------------------------------------------------------------------
__dot_has fzf || return 0

if [ -n "${ZSH_VERSION:-}" ]; then
  eval "$(fzf --zsh)"
elif [ -n "${BASH_VERSION:-}" ]; then
  eval "$(fzf --bash)"
fi
