#!/bin/sh
# Aliases for common dotfiles commands.

alias rdf='rdotfiles'
alias nvcfg="${EDITOR:-nvim} ${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
alias nv='nvim'

# Arch Linux (only define aliases if functions exist)
if command -v arch_pacman_update >/dev/null 2>&1; then
  alias pacmanupdate='arch_pacman_update'
  alias paruupdate='arch_paru_update'
  alias sysupdate='arch_sys_update'
fi
