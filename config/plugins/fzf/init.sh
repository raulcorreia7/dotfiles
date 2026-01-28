#!/bin/sh
# FZF plugin: fuzzy finder integration.
#
# Disable: DOTFILES_ENABLE_FZF=0

# Skip if fzf not available
__dot_has fzf || return 0

# Set up fzf defaults (if not already configured)
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 80% --layout=reverse --border}"

# Load key bindings
[ -r "$DOTFILES_PLUGINS_DIR/fzf/bindings.sh" ] || return 0
. "$DOTFILES_PLUGINS_DIR/fzf/bindings.sh"
