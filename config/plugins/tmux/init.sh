#!/bin/sh
# Tmux autostart

dot_has tmux || return 0

[ "${DOTFILES_TMUX_AUTOSTART:-1}" = "1" ] || return 0
case "$-" in *i*) ;; *) return 0 ;; esac
[ -z "${TMUX:-}" ] || return 0

dot_tmux_session_name() {
  awk -v pid="$$" -v r="${RANDOM:-0}" 'BEGIN{
    srand(systime() + pid + r)
    a="pixel neon brisk mellow nimble lucid tidy cozy sunny steady lively spicy crispy turbo sneaky chaotic legendary glitchy caffeinated"
    b="mage wizard rogue ranger paladin bard cleric druid barbarian tavern guild dungeon tower crypt library forge quest questline boss checkpoint respawn speedrun loot drop potion mana stamina relic scroll"
    n=split(a,A," "); m=split(b,B," ")
    print A[int(rand()*n)+1] "-" B[int(rand()*m)+1]
  }'
}

tmux new-session -s "${DOTFILES_TMUX_SESSION:-$(dot_tmux_session_name)}"
