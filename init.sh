#!/bin/sh
# Dotfiles runtime — the single file every interactive shell sources.
# The rc block written by ./setup exports DOTFILES_DIR and sources this file.
# Read top to bottom: PATH · helpers · env · zimfw · aliases · tool inits.

# Prevent double-loading.
[ -n "${_DOTFILES_INIT:-}" ] && return 0
_DOTFILES_INIT=1

# DOTFILES_DIR comes from the rc block (no ~/.dotfiles assumption).
if [ -z "${DOTFILES_DIR:-}" ]; then
  printf 'dotfiles: DOTFILES_DIR is not set — re-run ./setup in the dotfiles clone\n' >&2
  return 0
fi

# --- PATH: keep ~/.local/bin available (bin scripts land there)
if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi

# --- helpers
dot_has() { command -v "$1" >/dev/null 2>&1; }
dot_interactive() { case "$-" in *i*) return 0 ;; *) return 1 ;; esac; }
dot_shell_type() {
  if [ -n "${ZSH_VERSION:-}" ]; then
    echo zsh
  elif [ -n "${BASH_VERSION:-}" ]; then
    echo bash
  else
    echo sh
  fi
}
dot_eval_init() {
  dot_has "$1" || return 1
  eval "$($1 init "$(dot_shell_type)" 2>/dev/null)"
}

# --- environment (committed defaults; machine-local overrides in env.local)
export EDITOR=nvim
export VISUAL=code
export DOTFILES_PROMPT_IDENTITY=always
export LIGHTPANDA_DISABLE_TELEMETRY=true
[ -r "$DOTFILES_DIR/env.local" ] && . "$DOTFILES_DIR/env.local"

# --- zimfw (zsh only): the vendored zsh framework
if [ -n "${ZSH_VERSION:-}" ]; then
  export ZIM_HOME="$DOTFILES_DIR/zimfw"
  export ZIM_CONFIG_FILE="$ZIM_HOME/.zimrc"
  [ -r "$ZIM_HOME/init.zsh" ] && . "$ZIM_HOME/init.zsh"
fi

# --- aliases
alias nvcfg='${EDITOR:-nvim} ~/.config/nvim'
dot_has eza && alias ls='eza'

# ssh + tmux: attach to (or start) the "main" session on a remote host
sta() {
  if [ -z "${1:-}" ]; then
    echo "Usage: sta <host>" >&2
    return 1
  fi
  ssh -t "$1" "tmux attach -d 2>/dev/null || tmux new-session -s main"
}

# --- fzf (default key bindings)
if dot_has fzf; then
  case "$(dot_shell_type)" in
    zsh) eval "$(fzf --zsh)" ;;
    bash) eval "$(fzf --bash)" ;;
  esac
fi

# --- mise (runtime manager): shims on PATH, activation in interactive shells
if dot_has mise; then
  _dot_mise_shims_dir="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"
  case ":$PATH:" in
    *":$_dot_mise_shims_dir:"*) ;;
    *) [ -d "$_dot_mise_shims_dir" ] && PATH="$_dot_mise_shims_dir:$PATH" ;;
  esac
  if dot_interactive && [ -t 0 ] && [ -t 1 ]; then
    eval "$(mise activate "$(dot_shell_type)" 2>/dev/null)"
  fi
fi

# --- zoxide (smarter cd)
dot_has zoxide && dot_eval_init zoxide

# --- prompt identity (zsh + asciiship theme): user@host segment
if [ -n "${ZSH_VERSION:-}" ] && dot_has _prompt_asciiship_vimode; then
  _dot_prompt_identity_mode="${DOTFILES_PROMPT_IDENTITY:-always}"

  _dot_prompt_identity_segment() {
    case "${_dot_prompt_identity_mode}" in
      always)
        print -n '%B%F{yellow}%n%f%b@%B%F{green}%m%f%b '
        ;;
      auto)
        if [ -n "${SSH_TTY:-}" ]; then
          print -n '%B%F{yellow}%n%f%b@%B%F{green}%m%f%b '
        elif [ "${EUID:-$(id -u)}" -eq 0 ]; then
          print -n '%B%F{red}%n%f%b@%B%F{green}%m%f%b '
        fi
        ;;
      never) ;;
      *)
        print -n '%B%F{yellow}%n%f%b@%B%F{green}%m%f%b '
        ;;
    esac
  }

  PS1='
%(2L.%B%F{yellow}(%L)%f%b .)$(_dot_prompt_identity_segment)%B%F{cyan}%~%f%b${(e)git_info[prompt]}${VIRTUAL_ENV:+" via %B%F{yellow}${VIRTUAL_ENV:t}%f%b"}${duration_info}
%B%(1j.%F{blue}*%f .)%(?.%F{green}.%F{red}%? )$(_prompt_asciiship_vimode)%f%b '
fi

# --- tmux autostart: fresh random session in interactive, non-remote shells
if dot_has tmux && [ "${DOTFILES_TMUX_AUTOSTART:-1}" = "1" ] &&
  dot_interactive && [ -z "${TMUX:-}" ] && [ -z "${SSH_CONNECTION:-}${SSH_TTY:-}" ]; then

  dot_tmux_count() { printf '%s\n' "$1" | awk 'END { print NR }'; }
  dot_tmux_pick() { printf '%s\n' "$1" | awk -v n="$2" 'NR == n { print; exit }'; }

  dot_tmux_rand() {
    if dot_has uuidgen; then
      uuidgen | cksum | awk '{ print $1 }'
      return 0
    fi
    _dot_tmux_seed="${1:-0}-$(date +%s 2>/dev/null)-$$-${PPID:-0}-$(hostname 2>/dev/null)"
    printf '%s\n' "$_dot_tmux_seed" | cksum | awk '{ print $1 }'
  }

  dot_tmux_session_exists() { tmux has-session -t "$1" >/dev/null 2>&1; }

  dot_tmux_session_name() {
    _dot_tmux_adjectives='bonkers
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

    _dot_tmux_nouns='arcade
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

    _dot_tmux_adjective_count=$(dot_tmux_count "$_dot_tmux_adjectives")
    _dot_tmux_noun_count=$(dot_tmux_count "$_dot_tmux_nouns")
    _dot_tmux_tries=0

    while [ "$_dot_tmux_tries" -lt 64 ]; do
      _dot_tmux_adjective_index=$(($(dot_tmux_rand "$_dot_tmux_tries-a") % _dot_tmux_adjective_count + 1))
      _dot_tmux_noun_index=$(($(dot_tmux_rand "$_dot_tmux_tries-b") % _dot_tmux_noun_count + 1))
      _dot_tmux_name="$(dot_tmux_pick "$_dot_tmux_adjectives" "$_dot_tmux_adjective_index")-$(dot_tmux_pick "$_dot_tmux_nouns" "$_dot_tmux_noun_index")"

      if ! dot_tmux_session_exists "$_dot_tmux_name"; then
        printf '%s\n' "$_dot_tmux_name"
        return 0
      fi

      _dot_tmux_tries=$((_dot_tmux_tries + 1))
    done

    _dot_tmux_adjective_index=1
    while [ "$_dot_tmux_adjective_index" -le "$_dot_tmux_adjective_count" ]; do
      _dot_tmux_noun_index=1
      while [ "$_dot_tmux_noun_index" -le "$_dot_tmux_noun_count" ]; do
        _dot_tmux_name="$(dot_tmux_pick "$_dot_tmux_adjectives" "$_dot_tmux_adjective_index")-$(dot_tmux_pick "$_dot_tmux_nouns" "$_dot_tmux_noun_index")"

        if ! dot_tmux_session_exists "$_dot_tmux_name"; then
          printf '%s\n' "$_dot_tmux_name"
          return 0
        fi

        _dot_tmux_noun_index=$((_dot_tmux_noun_index + 1))
      done

      _dot_tmux_adjective_index=$((_dot_tmux_adjective_index + 1))
    done

    return 1
  }

  _dot_tmux_session="${DOTFILES_TMUX_SESSION:-$(dot_tmux_session_name)}"

  if [ -n "$_dot_tmux_session" ]; then
    tmux new-session -s "$_dot_tmux_session"
  else
    tmux new-session
  fi
fi
