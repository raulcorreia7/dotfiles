#!/bin/sh

WIDTH=$(tmux display-message -p "#{client_width}")
MIN_WIDTH=100

if [ "$WIDTH" -ge "$MIN_WIDTH" ]; then
  tmux-mem-cpu-load --interval 1
fi
