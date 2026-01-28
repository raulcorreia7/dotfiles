#!/bin/sh
# Aliases for common dotfiles commands.

alias df='rdotfiles'
alias dotreload='rdotfiles reload'
alias dotdoctor='rdotfiles health'
alias nvcfg="${EDITOR:-nvim} ${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
alias nv='nvim'

# Arch Linux
alias pacmanupdate='arch_pacman_update'
alias paruupdate='arch_paru_update'
alias sysupdate='arch_sys_update'
