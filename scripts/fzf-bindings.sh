#!/bin/sh
# FZF key bindings
if [ -n "${ZSH_VERSION:-}" ]; then
	eval "$(fzf --zsh)"
elif [ -n "${BASH_VERSION:-}" ]; then
	eval "$(fzf --bash)"
fi
