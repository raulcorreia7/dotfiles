#!/bin/sh
# Mise: runtime manager init.

if ! __dot_has mise; then
  return 0
fi

if [ -n "${ZSH_VERSION:-}" ]; then
  eval "$(mise activate zsh)"
elif [ -n "${BASH_VERSION:-}" ]; then
  eval "$(mise activate bash)"
else
  eval "$(mise activate sh)"
fi
