#!/bin/sh
set -e
# Link config and bin entries into standard locations.

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

DOTFILES_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
CONFIG_TARGET="$XDG_CONFIG_HOME/.dotfiles"
BIN_TARGET="$HOME/.local/bin"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

log() {
  printf '%s\n' "$*" >&2
}

debug() {
  [ "${DOTFILES_DEBUG:-0}" = "1" ] && log "$@"
}

ensure_dir() {
  [ -d "$1" ] || mkdir -p "$1"
}

link_path() {
  src=$1
  dest=$2
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    log "install: $dest exists (not symlink); skipping"
    return 0
  fi
  debug "install: link $src -> $dest"
  ln -sfn "$src" "$dest"
}

# -----------------------------------------------------------------------------
# Link config and bin
# -----------------------------------------------------------------------------

ensure_dir "$XDG_CONFIG_HOME"
ensure_dir "$BIN_TARGET"

link_path "$DOTFILES_DIR/config" "$CONFIG_TARGET"

if [ -d "$DOTFILES_DIR/bin" ]; then
  for f in "$DOTFILES_DIR"/bin/*; do
    [ -f "$f" ] || continue
    target="$BIN_TARGET/$(basename "$f")"
    link_path "$f" "$target"
  done
fi

# -----------------------------------------------------------------------------
# Shell setup notes
# -----------------------------------------------------------------------------

install_note() {
  shell_rc=$1
  if [ -r "$shell_rc" ]; then
    if ! grep -Fq "$DOTFILES_DIR/init.sh" "$shell_rc"; then
      log "install: add this to $shell_rc:"
      log "[ -r \"$DOTFILES_DIR/init.sh\" ] && . \"$DOTFILES_DIR/init.sh\""
    fi
  fi
}

install_note "$HOME/.zshrc"
install_note "$HOME/.bashrc"
