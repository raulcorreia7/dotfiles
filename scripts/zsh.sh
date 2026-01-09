#!/bin/sh
# zsh-only helpers.

# -----------------------------------------------------------------------------
# Guard
# -----------------------------------------------------------------------------

[ -n "${ZSH_VERSION:-}" ] || return 0

# -----------------------------------------------------------------------------
# Public commands
# -----------------------------------------------------------------------------

dot_zreload() {
	case "$1" in
	-h | --help)
		printf 'Usage: zreload\nReload your zsh configuration.\n'
		return 0
		;;
	esac

	# Resolve .zshrc path using ZDOTDIR if set.
	zshrc="${ZDOTDIR:-$HOME}/.zshrc"
	[ -r "$zshrc" ] || {
		printf 'zreload: %s not found\n' "$zshrc" >&2
		return 1
	}
	. "$zshrc"
}
