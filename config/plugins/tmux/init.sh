#!/bin/sh
# Tmux autostart helpers.

# -----------------------------------------------------------------------------
# Session naming
# -----------------------------------------------------------------------------

__dot_random_session_name() {
  # Seed includes PID to avoid collisions when multiple shells start in the same second.
  # $RANDOM is available in zsh/bash; falls back to 0 in plain /bin/sh.
  awk -v pid="$$" -v r="${RANDOM:-0}" 'BEGIN{
    srand(systime() + pid + r)
    # 2-part, screen-share-safe-ish codenames: prefix-suffix.
    # prefix = tone ∪ retro ∪ spice ; suffix = fantasy/classes ∪ places ∪ objectives ∪ loot/magic
    a="pixel neon brisk mellow nimble lucid tidy cozy sunny steady lively spicy crispy turbo sneaky chaotic legendary glitchy caffeinated"
    b="mage wizard rogue ranger paladin bard cleric druid barbarian tavern guild dungeon tower crypt library forge quest questline boss checkpoint respawn speedrun loot drop potion mana stamina relic scroll"
    n=split(a,A," "); m=split(b,B," ")
    print A[int(rand()*n)+1] "-" B[int(rand()*m)+1]
  }'
}

# -----------------------------------------------------------------------------
# Autostart
# -----------------------------------------------------------------------------

__dot_tmux_autostart() {
  [ "${DOTFILES_TMUX_AUTOSTART:-1}" = "1" ] || return 0
  case "$-" in
    *i*) ;;
    *) return 0 ;;
  esac
  [ -z "${TMUX:-}" ] || return 0
  command -v tmux >/dev/null 2>&1 || return 0

  session="${DOTFILES_TMUX_SESSION:-$(__dot_random_session_name)}"
  tmux new-session -s "$session"
}

# -----------------------------------------------------------------------------
# Run
# -----------------------------------------------------------------------------

__dot_tmux_autostart
