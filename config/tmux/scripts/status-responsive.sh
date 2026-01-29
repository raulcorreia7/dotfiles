#!/bin/sh

WIDTH=$(tmux display-message -p "#{client_width}")
MIN_WIDTH=100

# Use tmux-mem-cpu-load from TPM plugin directory
TMUX_MEM_CPU_LOAD="${HOME}/.tmux/plugins/tmux-mem-cpu-load/tmux-mem-cpu-load"
if [ -x "$TMUX_MEM_CPU_LOAD" ]; then
  "$TMUX_MEM_CPU_LOAD" --interval 1
fi
