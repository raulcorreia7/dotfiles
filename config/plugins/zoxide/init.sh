#!/bin/sh
# Zoxide plugin: smarter cd command integration.
#
# Disable: DOTFILES_ENABLE_ZOXIDE=0

__dot_has zoxide || return 0
__dot_init_tool zoxide
