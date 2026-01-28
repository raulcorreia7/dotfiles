#!/bin/sh
# Plugin manifest: ordered plugin loading.
#
# Disable plugins with: DOTFILES_ENABLE_<PLUGIN>=0

__dot_load_plugin "zimfw"
__dot_load_plugin "mise"
__dot_load_plugin "fzf"
__dot_load_plugin "zoxide"
__dot_load_plugin "tmux"
__dot_load_plugin "arch"
