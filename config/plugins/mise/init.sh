#!/bin/sh
# Mise: runtime manager init

dot_has mise || return 0

dot_mise_shims_dir="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"

case ":$PATH:" in
  *":$dot_mise_shims_dir:"*) ;;
  *)
    [ -d "$dot_mise_shims_dir" ] && PATH="$dot_mise_shims_dir:$PATH"
    ;;
esac

case "$-" in
  *i*)
    [ -t 0 ] && [ -t 1 ] && eval "$(mise activate "$(dot_shell_type)" 2>/dev/null)"
    ;;
esac
