#!/bin/sh
# FZF: fuzzy finder - default key bindings

dot_has fzf || return 0

case "$(dot_shell_type)" in
zsh) source <(fzf --zsh) ;;
bash) eval "$(fzf --bash)" ;;
esac
