#!/bin/sh
set -e
# Unlink config and bin entries from standard locations.

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

unlink_path() {
  _dest=$1
  _prefix=$2

  [ -L "$_dest" ] || return 0
  _target=$(readlink "$_dest" 2>/dev/null || true)
  case "$_target" in
    "$_prefix"/*)
      rm "$_dest"
      changes=$((changes + 1))
      log "uninstall: removed $_dest"
      ;;
  esac
}

# ------------------------------------------------------------------------------
# SECTION 3: Unlink Config and Bin
# ------------------------------------------------------------------------------

changes=0

APP_CONFIGS="${DOTFILES_APP_CONFIGS:-alacritty ghostty nvim tmux mise}"
for name in $APP_CONFIGS; do
  dest="$XDG_CONFIG_HOME/$name"
  unlink_path "$dest" "$DOTFILES_DIR/config"
done

for f in "$DOTFILES_DIR"/bin/*; do
  [ -f "$f" ] || continue
  target="$USER_BIN_DIR/$(basename "$f")"
  unlink_path "$target" "$DOTFILES_DIR/bin"
done

ZDOTDIR="${ZDOTDIR:-$HOME}"
ZIM_CONFIG_DEST="${DOTFILES_ZIM_CONFIG:-$ZDOTDIR/.zimrc}"
unlink_path "$ZIM_CONFIG_DEST" "$DOTFILES_DIR/config"

# Remove any remaining symlinks in USER_BIN_DIR that point into dotfiles bin
for target in "$USER_BIN_DIR"/*; do
  [ -L "$target" ] || continue
  unlink_path "$target" "$DOTFILES_DIR/bin"
done

if [ "$changes" -eq 0 ]; then
  log "uninstall: no dotfiles symlinks found"
fi
