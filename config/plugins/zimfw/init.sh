#!/bin/sh
# Zimfw plugin: zsh module manager integration.
#
# Disable: DOTFILES_ENABLE_ZIMFW=0

# Only for zsh
[ -n "${ZSH_VERSION:-}" ] || return 0

ZDOTDIR="${ZDOTDIR:-$HOME}"
export ZIM_HOME="${ZIM_HOME:-${DOTFILES_ZIM_HOME:-$ZDOTDIR/.zim}}"
export ZIM_CONFIG_FILE="${ZIM_CONFIG_FILE:-${DOTFILES_ZIM_CONFIG:-$ZDOTDIR/.zimrc}}"

_zimfw_init="$ZIM_HOME/init.zsh"

if [ ! -r "$_zimfw_init" ]; then
  __dot_debug "dotfiles: zimfw init missing (run: rdotfiles fix --zimfw)"
  unset _zimfw_init
  return 0
fi

if [ -r "$ZIM_CONFIG_FILE" ] && [ "$_zimfw_init" -ot "$ZIM_CONFIG_FILE" ]; then
  __dot_debug "dotfiles: zimfw init stale (run: rdotfiles fix --zimfw)"
  unset _zimfw_init
  return 0
fi

. "$_zimfw_init" || return 0
unset _zimfw_init
