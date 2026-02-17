#!/bin/sh
set -e

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

INTERACTIVE="${DOTFILES_INTERACTIVE:-1}"

ask_backup() {
  path="$1"

  [ "$INTERACTIVE" = "1" ] && [ -t 0 ] || return 0

  printf '[?] Backup existing %s to %s.bak? [Y/n] ' "$(basename "$path")" "$(basename "$path")"
  read -r answer

  case "$answer" in
  [nN] | [nN][oO])
    log "install: skipping backup for $path"
    return 1
    ;;
  *)
    return 0
    ;;
  esac
}

link_path() {
  src="$1"
  dest="$2"

  log "install: linking $src -> $dest"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    if ask_backup "$dest"; then
      log "install: backing up $dest to ${dest}.bak"
      mv "$dest" "${dest}.bak"
    else
      rm -rf "$dest"
    fi
  fi

  ln -sfn "$src" "$dest" && log "install: successfully linked $dest" ||
    log "install: failed to link $dest"
}

log "install: creating directories..."
ensure_dir "$XDG_CONFIG_HOME" && log "install: created $XDG_CONFIG_HOME"
ensure_dir "$BIN_TARGET" && log "install: created $BIN_TARGET"
ensure_dir "$REPO_DIR/bin" && log "install: created $REPO_DIR/bin"

CONFIG_DIRS="
alacritty
ghostty
nvim
opencode
tmux
mise
zimfw
"

log "install: linking app config directories..."
for name in $CONFIG_DIRS; do
  src="$REPO_DIR/config/$name"
  [ -e "$src" ] || continue
  link_path "$src" "$XDG_CONFIG_HOME/$name"
done

log "install: linking bin files..."
for f in "$REPO_DIR"/bin/*; do
  [ -f "$f" ] || continue
  target="$BIN_TARGET/$(basename "$f")"
  link_path "$f" "$target"
done

setup_shell_rc() {
  shell_rc=$1

  if [ ! -r "$shell_rc" ]; then
    log "install: creating $shell_rc"
    touch "$shell_rc"
  fi

  if grep -Fq "$REPO_DIR/init.sh" "$shell_rc"; then
    log "install: dotfiles already sourced in $shell_rc"
    return 0
  fi

  log "install: adding dotfiles source to $shell_rc"
  {
    echo ""
    echo "# Source dotfiles"
    echo "[ -r \"$REPO_DIR/init.sh\" ] && . \"$REPO_DIR/init.sh\""
  } >>"$shell_rc"
  log "install: successfully updated $shell_rc"
}

setup_shell_rc "$SHELL_ZSHRC"
setup_shell_rc "$SHELL_BASHRC"
