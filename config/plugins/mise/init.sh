#!/bin/sh
# Runtime version manager integration.

__dot_has mise || return 0
[ -t 0 ] || return 0

eval "$(mise activate "$(__dot_shell_type)" 2>/dev/null)" || true
