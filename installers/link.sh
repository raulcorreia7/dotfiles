#!/bin/sh
set -e
# Link config and bin entries into standard locations.

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# -----------------------------------------------------------------------------
# Paths and config
# -----------------------------------------------------------------------------

. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"
DOTFILES_DIR="$REPO_DIR"

debug() {
  [ "${DOTFILES_DEBUG:-0}" = "1" ] && log "$@"
}

link_path() {
  src=$1
  dest=$2
  log "install: linking $src -> $dest"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    backup_path="$dest.backup.$(date +%Y%m%d%H%M%S)"
    log "install: backing up $dest to $backup_path"
    mv "$dest" "$backup_path"
  fi
  ln -sfn "$src" "$dest" && log "install: successfully linked $dest" || log "install: failed to link $dest"
}

# -----------------------------------------------------------------------------
# Link config and bin
# -----------------------------------------------------------------------------

log "install: creating directories..."
ensure_dir "$XDG_CONFIG_HOME" && log "install: created $XDG_CONFIG_HOME"
ensure_dir "$BIN_TARGET" && log "install: created $BIN_TARGET"
ensure_dir "$DOTFILES_DIR/bin" && log "install: created $DOTFILES_DIR/bin"

log "install: linking app config directories..."
for name in nvim tmux mise zimfw; do
  src="$DOTFILES_DIR/config/$name"
  [ -e "$src" ] || continue
  link_path "$src" "$XDG_CONFIG_HOME/$name"
done

log "install: linking bin files..."
for f in "$DOTFILES_DIR"/bin/*; do
  [ -f "$f" ] || continue
  target="$BIN_TARGET/$(basename "$f")"
  link_path "$f" "$target"
done

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

install_note "$SHELL_ZSHRC"
install_note "$SHELL_BASHRC"
