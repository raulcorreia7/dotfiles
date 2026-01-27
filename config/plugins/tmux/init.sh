#!/bin/sh
# Tmux autostart helpers.

# -----------------------------------------------------------------------------
# Session naming
# -----------------------------------------------------------------------------

__dot_random_session_name() {
  awk 'BEGIN{
		srand()
		a="spicy crispy turbo sneaky chaotic legendary glitchy pixelated neon caffeinated tactical loot goblin sweaty salty cracked blessed cursed stealthy flashy pog champ retro 8bit arcade cartridge scanline chiptune"
		b="speedrun lag spike headshot crit combo respawn checkpoint dungeon raid boss quest loot drop questline buff nerf potion mana stamina rogue wizard paladin ranger barbarian quickscope"
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
