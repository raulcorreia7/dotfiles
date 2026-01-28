#!/bin/sh
set -e
# Link config and bin entries into standard locations.

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

# Use REPO_DIR if available, otherwise use the parent of SCRIPT_DIR
if [ -n "${REPO_DIR:-}" ]; then
  DOTFILES_DIR="$REPO_DIR"
else
  DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
fi

# Safety check: ensure DOTFILES_DIR is set and valid
if [ -z "$DOTFILES_DIR" ] || [ ! -d "$DOTFILES_DIR/bin" ]; then
  error "DOTFILES_DIR is not set correctly: '$DOTFILES_DIR' (bin directory not found)"
fi

# ------------------------------------------------------------------------------
# SECTION 2: Helper Functions
# ------------------------------------------------------------------------------

link_path() {
  _src=$1
  _dest=$2

  if [ -e "$_dest" ] && [ ! -L "$_dest" ]; then
    _backup_path="$_dest.backup.$(date +%Y%m%d%H%M%S)"
    mv "$_dest" "$_backup_path"
  fi

  if [ -L "$_dest" ] && [ ! -e "$_dest" ]; then
    rm "$_dest"
  fi

  ln -sfn "$_src" "$_dest" 2>/dev/null || log "install: failed to link $_dest"
}

# ------------------------------------------------------------------------------
# SECTION 3: Link Config and Bin
# ------------------------------------------------------------------------------

ensure_dir "$XDG_CONFIG_HOME"
ensure_dir "$USER_BIN_DIR"

CONFIG_DIRS="
alacritty
ghostty
nvim
tmux
mise
zimfw
"

for name in $CONFIG_DIRS; do
  src="$DOTFILES_DIR/config/$name"
  [ -e "$src" ] || continue
  link_path "$src" "$XDG_CONFIG_HOME/$name"
done

# Only link files from dotfiles bin directory, NOT system /bin
for f in "$DOTFILES_DIR"/bin/*; do
  [ -f "$f" ] || continue
  target="$USER_BIN_DIR/$(basename "$f")"
  link_path "$f" "$target"
done

# ------------------------------------------------------------------------------
# SECTION 4: Shell Setup Notes
# ------------------------------------------------------------------------------

install_note() {
  _shell_rc=$1
  if [ -r "$_shell_rc" ]; then
    if ! grep -Fq "$DOTFILES_DIR/init.sh" "$_shell_rc" 2>/dev/null; then
      log "install: add this to $_shell_rc:"
      log "[ -r \"$DOTFILES_DIR/init.sh\" ] && . \"$DOTFILES_DIR/init.sh\""
    fi
  fi
}

install_note "$SHELL_ZSHRC"
install_note "$SHELL_BASHRC"
