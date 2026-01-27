#!/bin/sh
# Plugin manifest (ordered list).

# Enable/disable plugins with:
#   export DOTFILES_ENABLE_FZF=0
#   export DOTFILES_ENABLE_ZOXIDE=0
#   export DOTFILES_ENABLE_TMUX=0
#   export DOTFILES_ENABLE_OS_ARCH=0

__dot_load_plugin "fzf"
__dot_load_plugin "zoxide"
__dot_load_plugin "tmux"
__dot_load_plugin "os/arch"
