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

dot_doctor_check() {
  dot_tool_name="$1"
  shift

  dot_tool_found=""
  dot_tool_alternatives=""
  dot_tool_try=""

  for dot_tool_cmd in "$@"; do
    if [ -n "$dot_tool_try" ]; then
      dot_tool_try="$dot_tool_try or $dot_tool_cmd"
    else
      dot_tool_try="$dot_tool_cmd"
    fi

    if dot_has "$dot_tool_cmd"; then
      if [ -z "$dot_tool_found" ]; then
        dot_tool_found="$dot_tool_cmd"
      else
        dot_tool_alternatives="$dot_tool_alternatives $dot_tool_cmd"
      fi
    fi
  done

  if [ -n "$dot_tool_found" ]; then
    if [ -n "$dot_tool_alternatives" ]; then
      printf '%s: ok (%s; alt:%s)\n' "$dot_tool_name" "$dot_tool_found" "$dot_tool_alternatives"
    else
      printf '%s: ok (%s)\n' "$dot_tool_name" "$dot_tool_found"
    fi
  else
    printf '%s: missing (try: %s)\n' "$dot_tool_name" "$dot_tool_try"
  fi
}

dot_doctor() {
  dot_doctor_check "fzf" "fzf"
  dot_doctor_check "git" "git"
  dot_doctor_check "rg" "rg"
  dot_doctor_check "fd" "fd"
  dot_doctor_check "bat" "bat"
  dot_doctor_check "eza" "eza" "exa"
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
  doctor           Check required tools
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
  doctor          Check if required tools are installed
  cd              Change to dotfiles directory

Arch Linux (requires pacman):
  update [--full] Update system packages with pacman/paru
                  --full also removes orphans and cleans cache

  orphans [-r]    List orphaned packages
                  -r prompts to remove them

  cache [-c]      Show pacman cache size
                  -c prompts to clean cache

Examples:
  rdf sync                  # Pull latest changes
  rdf sync --abort          # Cancel failed sync
  rdf update                # Update packages
  rdf update --full         # Full system maintenance
  rdf orphans -r            # Remove orphaned packages

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
  doctor)
    dot_doctor
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
