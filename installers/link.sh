#!/bin/sh
set -e
# Link config and bin entries into standard locations.

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"
DOTFILES_DIR="$REPO_DIR"

# ------------------------------------------------------------------------------
# SECTION 2: Helper Functions
# ------------------------------------------------------------------------------

debug() {
  [ "${DOTFILES_DEBUG:-0}" = "1" ] && log "$@"
}

link_path() {
  _src=$1
  _dest=$2
  log "install: linking $_src -> $_dest"

  if [ -e "$_dest" ] && [ ! -L "$_dest" ]; then
    _backup_path="$_dest.backup.$(date +%Y%m%d%H%M%S)"
    log "install: backing up $_dest to $_backup_path"
    mv "$_dest" "$_backup_path"
  fi

  if [ -L "$_dest" ] && [ ! -e "$_dest" ]; then
    log "install: removing broken symlink $_dest"
    rm "$_dest"
  fi

  ln -sfn "$_src" "$_dest" && log "install: successfully linked $_dest" || log "install: failed to link $_dest"
}

# ------------------------------------------------------------------------------
# SECTION 3: Link Config and Bin
# ------------------------------------------------------------------------------

log "install: creating directories..."
ensure_dir "$XDG_CONFIG_HOME" && log "install: created $XDG_CONFIG_HOME"
ensure_dir "$BIN_TARGET" && log "install: created $BIN_TARGET"
ensure_dir "$DOTFILES_DIR/bin" && log "install: created $DOTFILES_DIR/bin"

CONFIG_DIRS="
alacritty
ghostty
nvim
tmux
mise
zimfw
"

log "install: linking app config directories..."
for name in $CONFIG_DIRS; do
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

# ------------------------------------------------------------------------------
# SECTION 4: Shell Setup Notes
# ------------------------------------------------------------------------------

install_note() {
  _shell_rc=$1
  if [ -r "$_shell_rc" ]; then
    if ! grep -Fq "$DOTFILES_DIR/init.sh" "$_shell_rc"; then
      log "install: add this to $_shell_rc:"
      log "[ -r \"$DOTFILES_DIR/init.sh\" ] && . \"$DOTFILES_DIR/init.sh\""
    fi
  fi
}

install_note "$SHELL_ZSHRC"
install_note "$SHELL_BASHRC"
