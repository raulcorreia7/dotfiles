#!/bin/sh
# FZF plugin: fuzzy finder integration.
#
# Disable: DOTFILES_ENABLE_FZF=0

# Skip if fzf not available
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
unset _shell

# Set up fzf defaults (if not already configured)
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 80% --layout=reverse --border}"

# Load built-in fzf bindings for the current shell
if [ "$_shell" != "sh" ] && fzf --"$_shell" >/dev/null 2>&1; then
  eval "$(fzf --"$_shell")"
fi
