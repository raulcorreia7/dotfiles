#!/bin/sh
# Link dotfiles configurations and binaries
#
# Creates symlinks from ~/.dotfiles/config/* to ~/.config/*
# and bridges shared agent guidance plus Codex-managed files into their
# runtime locations.

set -e

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

INTERACTIVE="${DOTFILES_INTERACTIVE:-1}"
BACKUP_ALL=0
BACKUP_NONE=0

ask_backup() {
  path="$1"

  [ "$INTERACTIVE" = "1" ] && [ -t 0 ] || return 1

  [ "$BACKUP_ALL" = "1" ] && return 0
  [ "$BACKUP_NONE" = "1" ] && return 1

  printf '[?] Backup existing %s to %s.bak? [Yes/No/All/Skip] ' "$(basename "$path")" "$(basename "$path")"
  read -r answer

  case "$answer" in
  [yY] | [yY][eE][sS])
    return 0
    ;;
  [nN] | [nN][oO])
    log "Skipping backup for $path"
    return 1
    ;;
  [aA] | [aA][lL][lL])
    log "Backing up all remaining files"
    BACKUP_ALL=1
    return 0
    ;;
  [sS] | [sS][kK][iI][pP])
    log "Skipping all remaining backups"
    BACKUP_NONE=1
    return 1
    ;;
  *)
    return 0
    ;;
  esac
}

prepare_destination() {
  dest="$1"

  if [ -L "$dest" ]; then
    rm -f "$dest"
    return 0
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    if ask_backup "$dest"; then
      log "Backing up $dest to ${dest}.bak"
      mv "$dest" "${dest}.bak"
    else
      log "Removing existing $dest"
      rm -rf "$dest"
    fi
  fi
}

stow_path() {
  stow_dir="$1"
  target_dir="$2"
  package_name="$3"

  log "Stowing $package_name into $target_dir"
  ensure_dir "$target_dir"
  stow --dir="$stow_dir" --target="$target_dir" --restow "$package_name"
}

link_file() {
  source_path="$1"
  target_path="$2"

  ensure_dir "$(dirname -- "$target_path")"
  prepare_destination "$target_path"
  ln -s "$source_path" "$target_path"
}

resolve_link_target() {
  link_path="$1"
  link_target=$(readlink "$link_path") || return 1

  case "$link_target" in
  /*)
    printf '%s\n' "$link_target"
    ;;
  *)
    link_dir=$(CDPATH='' cd -- "$(dirname -- "$link_path")" && pwd)
    target_dir=$(CDPATH='' cd -- "$link_dir/$(dirname -- "$link_target")" && pwd) || return 1
    printf '%s/%s\n' "$target_dir" "$(basename -- "$link_target")"
    ;;
  esac
}

cleanup_legacy_config_links() {
  package_name="$1"
  package_root="$REPO_DIR/config/$package_name"

  for legacy in "$XDG_CONFIG_HOME"/* "$XDG_CONFIG_HOME"/.[!.]* "$XDG_CONFIG_HOME"/..?*; do
    [ -L "$legacy" ] || continue

    resolved_target=$(resolve_link_target "$legacy") || continue
    case "$resolved_target" in
    "$package_root"/*)
      log "Removing legacy top-level link $legacy"
      rm -rf "$legacy"
      ;;
    esac
  done
}

clone_alacritty_themes() {
  themes_dir="$REPO_DIR/config/alacritty/themes"

  if [ -d "$themes_dir" ]; then
    log "alacritty themes already present"
    return 0
  fi

  log "cloning alacritty themes..."
  git clone https://github.com/alacritty/alacritty-theme "$themes_dir"
}

link_config_dirs() {
  config_dirs="
alacritty
agents
codex
ghostty
nvim
opencode
tmux
mise
zimfw
"

  log ""
  log "Linking configuration directories..."

  for name in $config_dirs; do
    src="$REPO_DIR/config/$name"
    [ -e "$src" ] || continue
    prepare_destination "$XDG_CONFIG_HOME/$name"
    cleanup_legacy_config_links "$name"
    stow_path "$REPO_DIR/config" "$XDG_CONFIG_HOME/$name" "$name" || return 1
  done
}

link_codex_files() {
  codex_home="${CODEX_HOME:-$HOME/.codex}"

  log ""
  log "Linking Codex-managed files..."

  ensure_dir "$codex_home"

  link_file "$XDG_CONFIG_HOME/agents/AGENTS.md" "$codex_home/AGENTS.md"
  link_file "$XDG_CONFIG_HOME/codex/config.toml" "$codex_home/config.toml"
}

link_bin_files() {
  log ""
  log "Linking binaries..."

  has_bins=0
  for f in "$REPO_DIR"/bin/*; do
    [ -f "$f" ] || continue
    has_bins=1
    prepare_destination "$BIN_TARGET/$(basename "$f")"
  done

  [ "$has_bins" = "1" ] || return 0
  stow_path "$REPO_DIR" "$BIN_TARGET" "bin" || return 1
}

main() {
  require_command "stow" "GNU Stow is required for linking"

  log "Creating directories..."
  ensure_dir "$XDG_CONFIG_HOME" && log "  $XDG_CONFIG_HOME"
  ensure_dir "$BIN_TARGET" && log "  $BIN_TARGET"
  ensure_dir "$REPO_DIR/bin" && log "  $REPO_DIR/bin"

  log "Using GNU Stow for linking"

  clone_alacritty_themes || return 1
  link_config_dirs || return 1
  link_codex_files || return 1
  link_bin_files || return 1

  setup_shell_rc "$SHELL_ZSHRC"
  setup_shell_rc "$SHELL_BASHRC"

  log ""
  log "Linking complete"
}

setup_shell_rc() {
  shell_rc=$1

  if [ ! -r "$shell_rc" ]; then
    log "Creating $shell_rc"
    touch "$shell_rc"
  fi

  if grep -Fq "$REPO_DIR/init.sh" "$shell_rc"; then
    log "Dotfiles already sourced in $shell_rc"
    return 0
  fi

  log "Adding dotfiles source to $shell_rc"
  {
    printf '\n'
    printf '%s\n' "# Source dotfiles"
    printf '%s\n' "[ -r \"$REPO_DIR/init.sh\" ] && . \"$REPO_DIR/init.sh\""
  } >>"$shell_rc"
  log "Updated $shell_rc"
}

main "$@"
