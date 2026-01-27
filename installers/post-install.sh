#!/bin/sh
set -e
# Post-install setup tasks (sane defaults).

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

POST_INSTALL_ZSH="${DOTFILES_POST_INSTALL_ZSH:-1}"
POST_INSTALL_PATH="${DOTFILES_POST_INSTALL_PATH:-1}"
POST_INSTALL_XDG_DIRS="${DOTFILES_POST_INSTALL_XDG_DIRS:-1}"
POST_INSTALL_GIT="${DOTFILES_POST_INSTALL_GIT:-1}"

ensure_line_in_file() {
  file="$1"
  line="$2"
  [ -f "$file" ] || return 0
  grep -Fqx "$line" "$file" && return 0
  printf '\n%s\n' "$line" >> "$file"
}

ensure_zsh_default() {
  [ "$POST_INSTALL_ZSH" = "1" ] || return 0

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

ensure_local_bin_in_path() {
  [ "$POST_INSTALL_PATH" = "1" ] || return 0

  if [ -z "$SHELL_ZSHRC" ]; then
    return 0
  fi

  ensure_line_in_file "$SHELL_ZSHRC" 'export PATH="$HOME/.local/bin:$PATH"'
}

ensure_xdg_dirs() {
  [ "$POST_INSTALL_XDG_DIRS" = "1" ] || return 0

  ensure_dir "$HOME/.config"
  ensure_dir "$HOME/.cache"
  ensure_dir "$HOME/.local/state"
  ensure_dir "$HOME/.local/bin"
}

setup_git_defaults() {
  [ "$POST_INSTALL_GIT" = "1" ] || return 0

  if ! has_command git; then
    log "git not found, skipping git defaults"
    return 0
  fi

  git config --global init.defaultBranch main
  git config --global pull.rebase true
  git config --global fetch.prune true

  editor="${EDITOR:-nvim}"
  git config --global core.editor "$editor"

  if has_command delta; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    git config --global delta.navigate true
  elif has_command difft; then
    git config --global diff.external difft
  fi
}

main() {
  ensure_xdg_dirs
  ensure_local_bin_in_path
  ensure_zsh_default
  setup_git_defaults
}

main "$@"
