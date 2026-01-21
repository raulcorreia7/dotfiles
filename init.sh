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

	session="${DOTFILES_TMUX_SESSION:-main}-$(date +%s)"
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
