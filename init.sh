#!/bin/sh
# Dotfiles runtime entrypoint
# Sourced by ~/.zshrc or ~/.bashrc to initialize the dotfiles environment

# Prevent double-loading
[ -n "${_DOTFILES_INIT:-}" ] && return 0
_DOTFILES_INIT=1

# Base directory (override with DOTFILES_DIR env var)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Load core runtime (provides: rdf command, shell helpers, plugin system)
. "$DOTFILES_DIR/config/runtime.sh"

# Load environment variables if present
[ -r "$DOTFILES_DIR/config/env" ] && . "$DOTFILES_DIR/config/env"

# Initialize zimfw (zsh plugin manager) if running zsh
init_zimfw() {
  [ -n "${ZSH_VERSION:-}" ] || return 0

  export ZIM_HOME="${ZIM_HOME:-$DOTFILES_DIR/config/zimfw}"
  export ZIM_CONFIG_FILE="${ZIM_CONFIG_FILE:-$DOTFILES_DIR/config/.zimrc}"

  for dot_zim_init_file in "$HOME/.zim/init.zsh" "$ZIM_HOME/init.zsh"; do
    [ -r "$dot_zim_init_file" ] && {
      . "$dot_zim_init_file"
      return
    }
  done
}

init_zimfw

# Load aliases and plugin manifest
[ -r "$DOTFILES_DIR/config/aliases" ] && . "$DOTFILES_DIR/config/aliases"
[ -r "$DOTFILES_DIR/config/manifest.sh" ] && . "$DOTFILES_DIR/config/manifest.sh"
