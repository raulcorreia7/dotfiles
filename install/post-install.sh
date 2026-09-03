#!/bin/sh
set -e
# Post-install setup tasks (sane defaults).

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"
. "$SCRIPT_DIR/desktop-defaults.sh"

POST_INSTALL_ZSH="${DOTFILES_POST_INSTALL_ZSH:-1}"
POST_INSTALL_PATH="${DOTFILES_POST_INSTALL_PATH:-1}"
POST_INSTALL_XDG_DIRS="${DOTFILES_POST_INSTALL_XDG_DIRS:-1}"
POST_INSTALL_GIT="${DOTFILES_POST_INSTALL_GIT:-1}"
POST_INSTALL_LOGIN_DISPLAY="${DOTFILES_POST_INSTALL_LOGIN_DISPLAY:-1}"
POST_INSTALL_DIRS="${DOTFILES_POST_INSTALL_DIRS:-$HOME/projects}"
CACHYOS_ZSH_SOURCE='source /usr/share/cachyos-zsh-config/cachyos-config.zsh'

ensure_line_in_file() {
  file="$1"
  line="$2"
  [ -f "$file" ] || return 0
  grep -Fqx "$line" "$file" && return 0
  printf '\n%s\n' "$line" >>"$file"
}

ensure_zsh_default() {
  [ "$POST_INSTALL_ZSH" = "1" ] || return 0

  command -v zsh >/dev/null 2>&1 || {
    log "zsh not found, skipping default shell change"
    return 0
  }

  current_shell="${SHELL:-}"
  zsh_path=$(command -v zsh)

  [ "$current_shell" = "$zsh_path" ] && {
    log "default shell already set to zsh"
    return 0
  }

  if command -v chsh >/dev/null 2>&1; then
    log "setting default shell to zsh..."
    chsh -s "$zsh_path" || log "failed to set default shell, run: chsh -s \"$zsh_path\""
  else
    log "chsh not found, run: chsh -s \"$zsh_path\""
  fi
}

ensure_local_bin_in_path() {
  [ "$POST_INSTALL_PATH" = "1" ] || return 0
  [ -n "$SHELL_ZSHRC" ] || return 0
  ensure_line_in_file "$SHELL_ZSHRC" 'export PATH="$HOME/.local/bin:$PATH"'
}

is_cachyos() {
  os_release_file="${DOTFILES_OS_RELEASE_FILE:-/etc/os-release}"
  [ -r "$os_release_file" ] || return 1

  (
    . "$os_release_file"
    [ "${ID:-}" = "cachyos" ]
  )
}

disable_cachyos_zsh_config() {
  [ "$POST_INSTALL_ZSH" = "1" ] || return 0
  [ -f "$SHELL_ZSHRC" ] || return 0
  is_cachyos || return 0
  grep -Fqx "$CACHYOS_ZSH_SOURCE" "$SHELL_ZSHRC" || return 0

  tmp_file=$(mktemp)
  awk -v source_line="$CACHYOS_ZSH_SOURCE" '
    $0 == source_line {
      print "#" $0
      next
    }
    { print }
  ' "$SHELL_ZSHRC" >"$tmp_file"
  cat "$tmp_file" >"$SHELL_ZSHRC"
  rm -f "$tmp_file"
  log "disabled CachyOS zsh configuration in $SHELL_ZSHRC"
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

  command -v git >/dev/null 2>&1 || {
    log "git not found, skipping git defaults"
    return 0
  }

  git config --global init.defaultBranch main
  git config --global pull.rebase true
  git config --global fetch.prune true

  editor="${EDITOR:-nvim}"
  git config --global core.editor "$editor"

  if command -v delta >/dev/null 2>&1; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    git config --global delta.navigate true
  elif command -v difft >/dev/null 2>&1; then
    git config --global diff.external difft
  fi

  if command -v difft >/dev/null 2>&1; then
    git config --global alias.dft "-c diff.external=difft diff"
    git config --global alias.dshow "-c diff.external=difft show --ext-diff"
    git config --global alias.dlog "-c diff.external=difft log -p --ext-diff"
    git config --global alias.dst "-c diff.external=difft stash show --ext-diff -p"
  fi
}

login_manager_user() {
  if getent passwd plasmalogin >/dev/null 2>&1; then
    printf '%s\n' "plasmalogin"
  elif getent passwd sddm >/dev/null 2>&1; then
    printf '%s\n' "sddm"
  else
    return 1
  fi
}

sync_login_display_config() {
  [ "$POST_INSTALL_LOGIN_DISPLAY" = "1" ] || return 0
  is_kde_desktop || return 0

  output_config="${XDG_CONFIG_HOME:-$HOME/.config}/kwinoutputconfig.json"
  [ -r "$output_config" ] || {
    log "KDE display configuration not found, skipping login display setup"
    return 0
  }

  greeter_user=$(login_manager_user) || {
    log "Plasma Login Manager or SDDM user not found, skipping login display setup"
    return 0
  }
  greeter_home=$(getent passwd "$greeter_user" | cut -d: -f6)
  [ -n "$greeter_home" ] || {
    log "home directory not found for $greeter_user, skipping login display setup"
    return 0
  }

  command -v sudo >/dev/null 2>&1 || {
    log "sudo not found, skipping login display setup"
    return 0
  }

  log "applying KDE display layout to the $greeter_user login screen"
  sudo install -D -m 600 -o "$greeter_user" -g "$greeter_user" \
    "$output_config" "$greeter_home/.config/kwinoutputconfig.json"
}

main() {
  ensure_xdg_dirs
  ensure_dirs
  ensure_local_bin_in_path
  disable_cachyos_zsh_config
  ensure_zsh_default
  setup_git_defaults
  configure_desktop_defaults
  sync_login_display_config
}

main "$@"
