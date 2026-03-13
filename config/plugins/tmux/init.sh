#!/bin/sh
# Tmux autostart

dot_has tmux || return 0

[ "${DOTFILES_TMUX_AUTOSTART:-1}" = "1" ] || return 0
case "$-" in *i*) ;; *) return 0 ;; esac
[ -z "${TMUX:-}" ] || return 0
[ -z "${SSH_CONNECTION:-}${SSH_TTY:-}" ] || return 0

dot_tmux_count() {
  printf '%s\n' "$1" | awk 'END { print NR }'
}

dot_tmux_pick() {
  printf '%s\n' "$1" | awk -v n="$2" 'NR == n { print; exit }'
}

dot_tmux_rand() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | cksum | awk '{ print $1 }'
    return 0
  fi

  seed="${1:-0}-$(date +%s 2>/dev/null)-$$-${PPID:-0}-$(hostname 2>/dev/null)"
  printf '%s\n' "$seed" | cksum | awk '{ print $1 }'
}

dot_tmux_session_exists() {
  tmux has-session -t "$1" >/dev/null 2>&1
}

dot_tmux_session_name() {
  adjectives='bonkers
bouncy
breezy
cheeky
chirpy
chunky
cozy
crispy
cursed
dizzy
feral
fizzy
giddy
glitchy
goofy
jazzy
jolly
loopy
nimble
noisy
peppy
rowdy
scrappy
shiny
sneaky
spicy
spry
toasty
turbo
wily
wobbly
wonky
zesty'

  nouns='arcade
bazaar
beacon
bunker
burrow
camp
castle
cavern
checkpoint
citadel
contraption
crypt
dungeon
forge
goblin
hideout
hoard
kettle
lair
labyrinth
loot
market
meadow
mushroom
outpost
palace
potion
portal
rat
relic
sanctum
scroll
shrine
tavern
temple
toaster
tower
trapdoor
treasure
vault
wagon
workshop'

  adjective_count=$(dot_tmux_count "$adjectives")
  noun_count=$(dot_tmux_count "$nouns")
  tries=0

  while [ "$tries" -lt 64 ]; do
    adjective_index=$(( $(dot_tmux_rand "$tries-a") % adjective_count + 1 ))
    noun_index=$(( $(dot_tmux_rand "$tries-b") % noun_count + 1 ))
    name="$(dot_tmux_pick "$adjectives" "$adjective_index")-$(dot_tmux_pick "$nouns" "$noun_index")"

    if ! dot_tmux_session_exists "$name"; then
      printf '%s\n' "$name"
      return 0
    fi

    tries=$((tries + 1))
  done

  adjective_index=1
  while [ "$adjective_index" -le "$adjective_count" ]; do
    noun_index=1
    while [ "$noun_index" -le "$noun_count" ]; do
      name="$(dot_tmux_pick "$adjectives" "$adjective_index")-$(dot_tmux_pick "$nouns" "$noun_index")"

      if ! dot_tmux_session_exists "$name"; then
        printf '%s\n' "$name"
        return 0
      fi

      noun_index=$((noun_index + 1))
    done

    adjective_index=$((adjective_index + 1))
  done

  return 1
}

tmux_session_name="${DOTFILES_TMUX_SESSION:-$(dot_tmux_session_name)}"

if [ -n "$tmux_session_name" ]; then
  tmux new-session -s "$tmux_session_name"
else
  tmux new-session
fi
