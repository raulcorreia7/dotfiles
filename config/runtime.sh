# shellcheck shell=sh
# Runtime library - sourced by shell init
# Provides: shell helpers, plugin loading, rdf command

if [ -n "${_DOTFILES_RUNTIME_LIB:-}" ]; then
  return 0
fi
_DOTFILES_RUNTIME_LIB=1

# =============================================================================
# SHELL HELPERS
# =============================================================================

# Check if a command exists
dot_has() {
  command -v "$1" >/dev/null 2>&1
}

# Get current shell type (zsh/bash/sh)
dot_shell_type() {
  if [ -n "${ZSH_VERSION:-}" ]; then
    echo "zsh"
  elif [ -n "${BASH_VERSION:-}" ]; then
    echo "bash"
  else
    echo "sh"
  fi
}

# Run tool's init command for current shell (e.g., 'zoxide init zsh')
dot_eval_init() {
  dot_has "$1" || return 1
  eval "$($1 init "$(dot_shell_type)" 2>/dev/null)"
}

dot_debug() {
  [ "${DOTFILES_DEBUG:-0}" = "1" ] && printf '[DEBUG] %s\n' "$*" >&2
}

# =============================================================================
# PLUGIN LOADING
# =============================================================================

dot_plugin_key() {
  printf '%s' "$1" | tr '[:lower:]/-' '[:upper:]__' | tr -c 'A-Z0-9_' '_'
}

dot_plugin_enabled() {
  dot_plugin_env_key=$(dot_plugin_key "$1")
  eval "dot_plugin_enabled_flag=\${DOTFILES_ENABLE_${dot_plugin_env_key}:-1}"
  [ "$dot_plugin_enabled_flag" != "0" ]
}

dot_load_plugin() {
  dot_plugin_name="$1"
  dot_plugin_init="${DOTFILES_PLUGINS_DIR:-$DOTFILES_DIR/config/plugins}/$dot_plugin_name/init.sh"
  [ -r "$dot_plugin_init" ] || return 0
  dot_plugin_enabled "$dot_plugin_name" || return 0
  dot_debug "plugin: $dot_plugin_name"
  . "$dot_plugin_init"
}

# =============================================================================
# RDF COMMAND (raul dotfiles)
# =============================================================================

# =============================================================================
# HEALTH CHECKS
# =============================================================================

dot_health_ok() {
  printf '  %-16s ok\n' "$1:"
}

dot_health_ok_val() {
  printf '  %-16s ok (%s)\n' "$1:" "$2"
}

dot_health_missing() {
  printf '  %-16s missing\n' "$1:"
}

dot_health_warn() {
  printf '  %-16s warn (%s)\n' "$1:" "$2"
}

dot_health_check_tool() {
  dot_h_name="$1"
  shift
  for dot_h_cmd in "$@"; do
    if dot_has "$dot_h_cmd"; then
      dot_health_ok_val "$dot_h_name" "$dot_h_cmd"
      return 0
    fi
  done
  dot_health_missing "$dot_h_name"
  return 1
}

dot_health_tools() {
  echo "tools:"
  dot_health_check_tool "fzf" "fzf"
  dot_health_check_tool "git" "git"
  dot_health_check_tool "rg" "rg"
  dot_health_check_tool "fd" "fd" "fdfind"
  dot_health_check_tool "bat" "bat"
  dot_health_check_tool "eza" "eza" "exa"
  dot_health_check_tool "stow" "stow"
}

dot_health_dirs() {
  dot_h_home="${HOME:-$(pwd)}"
  dot_h_xdg="${XDG_CONFIG_HOME:-$dot_h_home/.config}"
  dot_h_bin="${XDG_BIN_HOME:-$dot_h_home/.local/bin}"
  dot_h_dotfiles="${DOTFILES_DIR:-$dot_h_home/.dotfiles}"

  echo "dirs:"
  [ -d "$dot_h_dotfiles" ] && dot_health_ok_val "dotfiles" "$dot_h_dotfiles" || dot_health_missing "dotfiles"
  [ -d "$dot_h_xdg" ] && dot_health_ok_val "config" "$dot_h_xdg" || dot_health_missing "config"
  [ -d "$dot_h_bin" ] && dot_health_ok_val "bin" "$dot_h_bin" || dot_health_missing "bin"
  [ -d "$dot_h_dotfiles/.git" ] && dot_health_ok "git-repo" || dot_health_missing "git-repo"
}

dot_health_links() {
  dot_h_home="${HOME:-$(pwd)}"
  dot_h_xdg="${XDG_CONFIG_HOME:-$dot_h_home/.config}"
  dot_h_dotfiles="${DOTFILES_DIR:-$dot_h_home/.dotfiles}"

  echo "links:"
  for dot_h_link in nvim tmux alacritty ghostty mise zimfw; do
    dot_h_path="$dot_h_xdg/$dot_h_link"
    dot_h_src="$dot_h_dotfiles/config/$dot_h_link"

    [ -d "$dot_h_src" ] || continue

    if [ -L "$dot_h_path" ]; then
      dot_h_target=$(readlink -f "$dot_h_path" 2>/dev/null || readlink "$dot_h_path")
      if [ -d "$dot_h_target" ]; then
        dot_health_ok "$dot_h_link"
      else
        dot_health_warn "$dot_h_link" "broken"
      fi
    elif [ -d "$dot_h_path" ]; then
      dot_h_linked=$(find "$dot_h_path" -maxdepth 1 -type l 2>/dev/null | head -1)
      if [ -n "$dot_h_linked" ]; then
        dot_health_ok "$dot_h_link"
      else
        dot_health_warn "$dot_h_link" "not linked"
      fi
    else
      dot_health_missing "$dot_h_link"
    fi
  done
}

dot_health_git() {
  dot_h_dir="${DOTFILES_DIR:-$HOME/.dotfiles}"

  echo "git:"
  if [ ! -d "$dot_h_dir/.git" ]; then
    dot_health_missing "repo"
    return 0
  fi

  dot_h_branch=$(git -C "$dot_h_dir" branch --show-current 2>/dev/null)
  [ -n "$dot_h_branch" ] && dot_health_ok_val "branch" "$dot_h_branch" || dot_health_warn "branch" "detached?"

  dot_h_status=$(git -C "$dot_h_dir" status --porcelain 2>/dev/null)
  dot_h_ahead=$(git -C "$dot_h_dir" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo "0")
  dot_h_behind=$(git -C "$dot_h_dir" rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo "0")

  if [ -z "$dot_h_status" ] && [ "$dot_h_ahead" = "0" ] && [ "$dot_h_behind" = "0" ]; then
    dot_health_ok "status"
  else
    dot_h_msgs=""
    [ -n "$dot_h_status" ] && dot_h_msgs="dirty"
    [ "$dot_h_ahead" != "0" ] && dot_h_msgs="$dot_h_msgs, $dot_h_ahead ahead"
    [ "$dot_h_behind" != "0" ] && dot_h_msgs="$dot_h_msgs, $dot_h_behind behind"
    dot_h_msgs=$(echo "$dot_h_msgs" | sed 's/^, //')
    dot_health_warn "status" "$dot_h_msgs"
  fi
}

dot_health() {
  dot_h_scope="${1:-all}"

  case "$dot_h_scope" in
  tools) dot_health_tools ;;
  dirs) dot_health_dirs ;;
  links) dot_health_links ;;
  git) dot_health_git ;;
  all | "")
    dot_health_tools
    echo ""
    dot_health_dirs
    echo ""
    dot_health_links
    echo ""
    dot_health_git
    ;;
  *)
    echo "Usage: rdf health [tools|dirs|links|git|all]" >&2
    return 1
    ;;
  esac
}

dot_reload() {
  dot_reload_init="${DOTFILES_DIR:-$HOME/.dotfiles}/init.sh"
  [ -r "$dot_reload_init" ] || {
    echo "rdf reload: init.sh not found at $dot_reload_init" >&2
    return 1
  }
  . "$dot_reload_init" && echo "Reloaded"
}

dot_edit() {
  ${EDITOR:-nvim} "${DOTFILES_DIR:-$HOME/.dotfiles}"
}

dot_run_os_command() {
  dot_os_cmd="$1"
  shift
  dot_os_fn="dot_arch_$dot_os_cmd"
  if type "$dot_os_fn" >/dev/null 2>&1; then
    "$dot_os_fn" "$@"
  else
    echo "rdf $dot_os_cmd: not available on this system" >&2
    return 1
  fi
}

dot_sync() {
  dot_sync_dir="${DOTFILES_DIR:-$HOME/.dotfiles}"
  dot_sync_install="$dot_sync_dir/install"
  dot_sync_init="$dot_sync_dir/init.sh"

  dot_has git || {
    echo "rdf sync: git is required" >&2
    return 1
  }

  [ -d "$dot_sync_dir/.git" ] || {
    echo "rdf sync: $dot_sync_dir is not a git repository" >&2
    return 1
  }

  [ -x "$dot_sync_install" ] || {
    echo "rdf sync: install script not found at $dot_sync_install" >&2
    return 1
  }

  if [ "${1:-}" = "--abort" ]; then
    echo "Aborting sync..."
    git -C "$dot_sync_dir" rebase --abort 2>/dev/null || {
      echo "No rebase in progress" >&2
      return 1
    }
    echo "Sync aborted"
    return 0
  fi

  echo "Syncing dotfiles..."
  if ! git -C "$dot_sync_dir" pull --rebase --autostash 2>&1; then
    echo ""
    echo "Sync failed. Options:"
    echo "  rdf sync --abort    Abort and return to previous state"
    echo "  cd \$DOTFILES_DIR && git status    Inspect conflicts"
    return 1
  fi

  echo "Applying setup..."
  "$dot_sync_install" --only setup || return 1

  if [ -r "$dot_sync_init" ]; then
    . "$dot_sync_init" || return 1
  fi

  echo "Dotfiles synced"
}

dot_help() {
  cat <<'EOF'
Usage: rdf <command> [options]

Dotfiles management and system maintenance.

Commands:
  sync [--abort]   Pull and apply changes (auto-stashes locals)
  reload           Reload dotfiles in current shell
  edit             Open dotfiles in $EDITOR
  health [scope]   Check system health (tools|dirs|links|git|all)
  cd               Change to dotfiles directory

Arch (requires pacman):
  update [--full]  Update packages (+ orphans/cache with --full)
  orphans [-r]     List orphaned packages (-r to remove)
  cache [-c]       Show cache size (-c to clean)

Run 'rdf help' for full documentation.
EOF
}

dot_help_full() {
  cat <<'EOF'
Usage: rdf <command> [options]

rdf - Dotfiles management and system maintenance.

Commands:
  sync [--abort]   Pull and apply dotfiles changes
                  Local changes are auto-stashed and restored.
                  Use --abort to cancel a failed sync.

  reload          Reload dotfiles in current shell
  edit            Open dotfiles in $EDITOR (default: nvim)
  cd              Change to dotfiles directory

  health [scope]  Check system health
                  Scopes: tools, dirs, links, git, all (default: all)
                  Shows status of tools, directories, symlinks, and git repo.

Arch Linux (requires pacman):
  update [--full] Update system packages with pacman/paru
                  --full also removes orphans and cleans cache

  orphans [-r]    List orphaned packages
                  -r prompts to remove them

  cache [-c]      Show pacman cache size
                  -c prompts to clean cache

Examples:
  rdf sync                  # Pull latest changes
  rdf health                # Full health check
  rdf health tools          # Check tools only
  rdf health git            # Check git status
  rdf update                # Update packages
  rdf update --full         # Full system maintenance

Environment:
  DOTFILES_DIR              Dotfiles location (default: ~/.dotfiles)
  DOTFILES_OS_ARCH_ASSUME_YES  Skip prompts (set to 1)
  EDITOR                    Editor for 'rdf edit'

EOF
}

rdf() {
  case "${1:-}" in
  sync)
    shift
    dot_sync "$@"
    ;;
  reload)
    dot_reload
    ;;
  edit)
    dot_edit
    ;;
  health)
    shift
    dot_health "${1:-all}"
    ;;
  cd)
    cd "${DOTFILES_DIR:-$HOME/.dotfiles}" || return 1
    ;;
  update | orphans | cache)
    dot_cmd="$1"
    shift
    dot_run_os_command "$dot_cmd" "$@"
    ;;
  help | --help | -h | "")
    dot_help
    ;;
  --full-help)
    dot_help_full
    ;;
  *)
    echo "rdf: unknown command '$1'" >&2
    echo "Run 'rdf help' for usage" >&2
    return 1
    ;;
  esac
}
