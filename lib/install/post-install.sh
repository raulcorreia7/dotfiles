#!/bin/sh
set -euo pipefail
# Post-install setup tasks (sane defaults).

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

POST_INSTALL_ZSH="${DOTFILES_POST_INSTALL_ZSH:-1}"
POST_INSTALL_PATH="${DOTFILES_POST_INSTALL_PATH:-1}"
POST_INSTALL_XDG_DIRS="${DOTFILES_POST_INSTALL_XDG_DIRS:-1}"
POST_INSTALL_GIT="${DOTFILES_POST_INSTALL_GIT:-1}"
POST_INSTALL_DIRS="${DOTFILES_POST_INSTALL_DIRS:-$HOME/projects}"

# ------------------------------------------------------------------------------
# SECTION 2: Helper Functions
# ------------------------------------------------------------------------------

ensure_line_in_file() {
  file="$1"
  line="$2"
  [ -f "$file" ] || return 0
  grep -Fqx "$line" "$file" && return 0
  printf '\n%s\n' "$line" >>"$file"
}

ensure_zsh_default() {
  [ "$POST_INSTALL_ZSH" = "1" ] || return 0

  if ! __dot_has zsh; then
    log "zsh not found, skipping default shell change"
    return 0
  fi

  current_shell="${SHELL:-}"
  zsh_path=$(command -v zsh)

  [ "$current_shell" = "$zsh_path" ] && {
    log "default shell already set to zsh"
    return 0
  }

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

ensure_dirs() {
  [ -n "$POST_INSTALL_DIRS" ] || return 0

  for dir in $POST_INSTALL_DIRS; do
    ensure_dir "$dir"
  done
}

setup_git_defaults() {
  [ "$POST_INSTALL_GIT" = "1" ] || return 0

  if ! __dot_has git; then
    log "git not found, skipping git defaults"
    return 0
  fi

  git config --global init.defaultBranch main
  git config --global pull.rebase true
  git config --global fetch.prune true

  editor="${EDITOR:-nvim}"
  git config --global core.editor "$editor"

  if __dot_has delta; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    git config --global delta.navigate true
  elif __dot_has difft; then
    git config --global diff.external difft
  fi
}

# ------------------------------------------------------------------------------
# SECTION 3: Main
# ------------------------------------------------------------------------------

main() {
  ensure_xdg_dirs
  ensure_dirs
  ensure_local_bin_in_path
  ensure_zsh_default
  setup_git_defaults
}

main "$@"
