#!/bin/sh
# Dotfiles runtime entrypoint
# Sourced by .zshrc/.bashrc

[ -n "${_DOTFILES_INIT:-}" ] && return 0
_DOTFILES_INIT=1

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

. "$DOTFILES_DIR/config/runtime.sh"

[ -r "$DOTFILES_DIR/config/env" ] && . "$DOTFILES_DIR/config/env"

__dot_init_zimfw() {
  [ -n "${ZSH_VERSION:-}" ] || return 0

  export ZIM_HOME="${ZIM_HOME:-$DOTFILES_DIR/config/zimfw}"
  export ZIM_CONFIG_FILE="${ZIM_CONFIG_FILE:-$DOTFILES_DIR/config/.zimrc}"

  for zim_init in "$HOME/.zim/init.zsh" "$ZIM_HOME/init.zsh"; do
    [ -r "$zim_init" ] && {
      . "$zim_init"
      return
    }
  done
}

__dot_init_zimfw

[ -r "$DOTFILES_DIR/config/aliases" ] && . "$DOTFILES_DIR/config/aliases"
[ -r "$DOTFILES_DIR/config/manifest.sh" ] && . "$DOTFILES_DIR/config/manifest.sh"
