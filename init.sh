#!/bin/sh
# Entrypoint: load config and shell helpers.

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/config"
DOTFILES_SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# -----------------------------------------------------------------------------
# Internal helpers
# -----------------------------------------------------------------------------

__dot_log() {
	printf '%s\n' "$*" >&2
}

__dot_debug() {
	[ "${DOTFILES_DEBUG:-0}" = "1" ] && __dot_log "$@"
}

__dot_source() {
	[ -r "$1" ] || return 0
	__dot_debug "dotfiles: source $1"
	. "$1"
}

__dot_random_session_name() {
	adjectives="cosmic happy brave calm dreamy eager fresh grand lucky neon quick rapid swift vivid wild zesty amber bronze coral fuchsia gold indigo jade lavender olive plum salmon teal azure beige crimson emerald ivory magenta ochre scarlet violet"
	nouns="comet drake eagle falcon goose hawk ibex jaguar kiwi lark moose nightingale oriole pheasant quail raven sparrow tiger vulture whale yak zebra aurora canyon desert forest galaxy horizon island jungle mountain nebula oasis peninsula river savanna tundra valley volcano canyon dune glacier mesa oasis plateau summit valley canyon crater geyser lagoon marsh prairie"

	adj=$(echo "$adjectives" | tr ' ' '\n' | shuf -n 1)
	noun=$(echo "$nouns" | tr ' ' '\n' | shuf -n 1)

	printf '%s-%s\n' "$adj" "$noun"
}

# -----------------------------------------------------------------------------
# Load config and scripts (runtime-only)
# -----------------------------------------------------------------------------

# Optional config overrides (variables only).
__dot_source "$DOTFILES_CONFIG_DIR/env"

for script in "$DOTFILES_SCRIPTS_DIR"/*.sh; do
	[ -r "$script" ] || continue
	. "$script"
done

# -----------------------------------------------------------------------------
# Zimfw (zsh only, no downloads)
# -----------------------------------------------------------------------------

if [ -n "${ZSH_VERSION:-}" ]; then
	if [ -r "$HOME/.zim/init.zsh" ]; then
		. "$HOME/.zim/init.zsh"
	elif [ -r "$DOTFILES_CONFIG_DIR/zimfw/init.zsh" ]; then
		. "$DOTFILES_CONFIG_DIR/zimfw/init.zsh"
	fi
fi

# -----------------------------------------------------------------------------
# Tmux auto-start (interactive shells only)
# -----------------------------------------------------------------------------

__dot_tmux_autostart() {
	[ "${DOTFILES_TMUX_AUTOSTART:-1}" = "1" ] || return 0
	case "$-" in
	*i*) ;;
	*) return 0 ;;
	esac
	[ -z "${TMUX:-}" ] || return 0
	command -v tmux >/dev/null 2>&1 || return 0

	# Use friendly random session names (like zellij)
	# Set DOTFILES_TMUX_SESSION env var for custom name
	session="${DOTFILES_TMUX_SESSION:-$(__dot_random_session_name)}"
	tmux new-session -s "$session"
}

__dot_tmux_autostart

# -----------------------------------------------------------------------------
# Public commands
# -----------------------------------------------------------------------------

dot_reload() {
	# Reload config and functions without restarting shell.
	. "$DOTFILES_DIR/init.sh"
}

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# Aliases are last so they bind to loaded functions.
__dot_source "$DOTFILES_CONFIG_DIR/aliases"
