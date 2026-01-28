#!/bin/sh
# Tmux autostart helpers.
#
# Disable: DOTFILES_ENABLE_TMUX=0

# ------------------------------------------------------------------------------
# SECTION 1: Guard/Checks
# ------------------------------------------------------------------------------

__dot_has tmux || return 0

# Only run autostart once per shell session (prevents re-running on reload)
[ -n "${__DOT_TMUX_RAN:-}" ] && return 0
__DOT_TMUX_RAN=1

# ------------------------------------------------------------------------------
# SECTION 2: Helper Functions
# ------------------------------------------------------------------------------

__dot_random_session_name() {
  # Generate random session name: adjective-noun pairs
  awk -v pid="$$" -v r="${RANDOM:-0}" 'BEGIN{
    srand(systime() + pid + r)
    a="pixel neon brisk mellow nimble lucid tidy cozy sunny steady lively spicy crispy turbo sneaky chaotic legendary glitchy caffeinated"
    b="mage wizard rogue ranger paladin bard cleric druid barbarian tavern guild dungeon tower crypt library forge quest questline boss checkpoint respawn speedrun loot drop potion mana stamina relic scroll"
    n=split(a,A," "); m=split(b,B," ")
    print A[int(rand()*n)+1] "-" B[int(rand()*m)+1]
  }'
}

__dot_unique_session_name() {
  # Generate a unique session name, appending counter if base name exists
  _base_name="${1:-$(__dot_random_session_name)}"
  _name="$_base_name"
  _counter=2

  while tmux has-session -t "$_name" 2>/dev/null; do
    _name="${_base_name}-${_counter}"
    _counter=$((_counter + 1))
  done

  printf '%s\n' "$_name"
}

# ------------------------------------------------------------------------------
# SECTION 3: Autostart Logic
# ------------------------------------------------------------------------------

_tmux_autostart() {
  [ "${DOTFILES_TMUX_AUTOSTART:-1}" = "1" ] || return 0
  case "$-" in
  *i*) ;;
  *) return 0 ;;
  esac
  [ -z "${TMUX:-}" ] || return 0
  command -v tmux >/dev/null 2>&1 || return 0

  session="${DOTFILES_TMUX_SESSION:-$(__dot_unique_session_name)}"
  tmux new-session -s "$session"
}

# ------------------------------------------------------------------------------
# SECTION 4: Execution
# ------------------------------------------------------------------------------

_tmux_autostart
