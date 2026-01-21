#!/bin/sh
# Zoxide: smarter cd command
if [ -n "${ZSH_VERSION:-}" ]; then
	eval "$(zoxide init zsh)"
elif [ -n "${BASH_VERSION:-}" ]; then
	eval "$(zoxide init bash)"
else
	eval "$(zoxide init zsh)"
fi
