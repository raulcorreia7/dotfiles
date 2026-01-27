#!/bin/sh
set -e
# Post-install setup tasks.

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

ensure_zsh_default() {
  if ! has_command zsh; then
    log "zsh not found, skipping default shell change"
    return 0
  fi

  current_shell="${SHELL:-}"
  zsh_path=$(command -v zsh)

  if [ "$current_shell" = "$zsh_path" ]; then
    log "default shell already set to zsh"
    return 0
  fi

  if command -v chsh >/dev/null 2>&1; then
    log "setting default shell to zsh..."
    if chsh -s "$zsh_path"; then
      log "default shell set to zsh"
    else
      log "failed to set default shell, run: chsh -s \"$zsh_path\""
    fi
  else
    log "chsh not found, run: chsh -s \"$zsh_path\""
  fi
}

main() {
  ensure_zsh_default
}

main "$@"
