#!/bin/sh
# FZF key bindings - minimal shell integration

# Only set up in interactive shells
[ -t 0 ] || return 0

# Skip if fzf not available
__dot_has fzf || return 0

# -----------------------------------------------------------------------------
# Try modern fzf built-in shell integration first
# -----------------------------------------------------------------------------

_shell=$(__dot_shell_type)

if [ "$_shell" != "sh" ]; then
  # try --zsh or --bash flag first (fzf 0.48+)
  if fzf --"$_shell" >/dev/null 2>&1; then
    eval "$(fzf --"$_shell")"
    unset _shell
    return 0
  fi
fi
unset _shell

# -----------------------------------------------------------------------------
# Fallback: try system-installed key binding files
# -----------------------------------------------------------------------------

_shell=$(__dot_shell_type)
_fzf_bindings=""

if [ "$_shell" != "sh" ]; then
  _ext="$_shell"
  for _path in \
    "/usr/share/fzf/shell/key-bindings.$_ext" \
    "/usr/share/fzf/key-bindings.$_ext" \
    "/usr/share/doc/fzf/examples/key-bindings.$_ext" \
    "/etc/fzf/key-bindings.$_ext" \
    "/usr/local/share/fzf/shell/key-bindings.$_ext" \
    "/opt/homebrew/opt/fzf/shell/key-bindings.$_ext" \
    "/usr/local/opt/fzf/shell/key-bindings.$_ext" \
    "$HOME/.fzf/shell/key-bindings.$_ext"
  do
    if [ -r "$_path" ]; then
      _fzf_bindings="$_path"
      break
    fi
  done
  unset _ext
fi

if [ -n "$_fzf_bindings" ]; then
  . "$_fzf_bindings"
  unset _fzf_bindings _path
  return 0
fi

unset _fzf_bindings _path

# -----------------------------------------------------------------------------
# Minimal fallback: basic Ctrl-R binding only
# This is a last resort when no system integration is available
# -----------------------------------------------------------------------------

_shell=$(__dot_shell_type)

if [ "$_shell" = "zsh" ]; then
  # Minimal zsh fallback - just Ctrl+R for history
  _fzf_history_widget() {
    _selected="" _num=0
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
    _selected=$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\*[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS:-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS:-} +m" fzf | awk '{ print $1 }')
    _ret=$?
    if [ -n "$_selected" ]; then
      _num=$_selected
      if [ -n "$_num" ]; then
        zle vi-fetch-history -n $_num
      fi
    fi
    zle reset-prompt
    return $_ret
  }
  zle -N _fzf_history_widget
  bindkey '^R' _fzf_history_widget
elif [ "$_shell" = "bash" ]; then
  # Minimal bash fallback - just Ctrl+R for history
  _fzf_history_bash() {
    local output
    output=$(
      builtin fc -lnr -2147483648 |
        last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
        FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS:-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS:-} +m --read0" fzf
    ) || return
    builtin history -s "$(command grep -o '\S.*' <<< "${output#$'\t'}")"
  }
  bind -m emacs-standard -x '"\C-r": _fzf_history_bash'
  bind -m vi-command -x '"\C-r": _fzf_history_bash'
  bind -m vi-insert -x '"\C-r": _fzf_history_bash'
fi

unset _shell
