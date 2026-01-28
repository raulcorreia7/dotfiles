#!/bin/sh
# Zimfw plugin: zsh module manager integration.
#
# Disable: DOTFILES_ENABLE_ZIMFW=0

# Only for zsh
[ -n "${ZSH_VERSION:-}" ] || return 0

# Check if zimfw is available (bundled or user-installed)
_zimfw_init=""
if [ -r "$DOTFILES_CONFIG_DIR/zimfw/init.zsh" ]; then
  _zimfw_init="$DOTFILES_CONFIG_DIR/zimfw/init.zsh"
elif [ -r "$HOME/.zim/init.zsh" ]; then
  _zimfw_init="$HOME/.zim/init.zsh"
fi

[ -r "$_zimfw_init" ] || return 0

# Set zimfw environment to use dotfiles config
export ZIM_HOME="${ZIM_HOME:-$DOTFILES_CONFIG_DIR/zimfw}"
export ZIM_CONFIG_FILE="${ZIM_CONFIG_FILE:-$DOTFILES_CONFIG_DIR/.zimrc}"

# Load zimfw
. "$_zimfw_init" || return 0

unset _zimfw_init
