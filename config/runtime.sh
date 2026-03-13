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

  echo "Syncing dotfiles..."
  git -C "$dot_sync_dir" pull --rebase || return 1

  echo "Applying setup..."
  "$dot_sync_install" --only setup || return 1

  if [ -r "$dot_sync_init" ]; then
    # Re-source runtime so the current shell sees any prompt/plugin changes.
    . "$dot_sync_init" || return 1
  fi

  echo "Dotfiles synced"
}

dot_help() {
  cat <<'EOF'
Usage: rdf <command> [options]

rdf (raul dotfiles) - Dotfiles management and system maintenance

Core Commands:
  sync            Pull and apply dotfiles changes
  reload          Reload dotfiles configuration
  edit            Open dotfiles in $EDITOR (default: nvim)
  doctor          Check if required tools are installed
  cd              Change to dotfiles directory

Arch Linux Maintenance (requires pacman):
  update          Update system packages with pacman/paru
                  Use --full to also remove orphans and clean cache
  orphans         List orphaned packages
                  Use --remove to uninstall them
  cache           Show cache size
                  Use --clean to remove cached packages

Examples:
  rdf sync                      # Pull and apply latest dotfiles changes
  rdf doctor                    # Check tool installation status
  rdf update                    # Standard update (packages only)
  rdf update --full             # Full maintenance (packages + cleanup)
  rdf orphans                   # List orphaned packages
  rdf orphans --remove          # Remove orphaned packages
  rdf cache                     # Show cache size
  rdf cache --clean             # Clean package cache

Environment Variables:
  DOTFILES_DIR                  # Dotfiles location (default: ~/.dotfiles)
  DOTFILES_OS_ARCH_ASSUME_YES   # Skip all prompts (set to 1)
  EDITOR                        # Editor for 'rdf edit' (default: nvim)

EOF
}

rdf() {
  dot_rdf_command="${1:-}"

  case "${1:-}" in
  sync)
    shift
    [ $# -eq 0 ] || {
      echo "Usage: rdf sync" >&2
      return 1
    }
    dot_sync
    ;;
  reload)
    . "${DOTFILES_DIR:-$HOME/.dotfiles}/init.sh" && echo "Reloaded"
    ;;
  edit)
    ${EDITOR:-nvim} "${DOTFILES_DIR:-$HOME/.dotfiles}"
    ;;
  doctor)
    dot_doctor
    ;;
  cd)
    cd "${DOTFILES_DIR:-$HOME/.dotfiles}" || return 1
    ;;
  update | orphans | cache)
    dot_rdf_subcommand="dot_arch_$dot_rdf_command"
    shift
    if type "$dot_rdf_subcommand" >/dev/null 2>&1; then
      "$dot_rdf_subcommand" "$@"
    else
      echo "rdf $dot_rdf_command: not available on this system (requires pacman)" >&2
      return 1
    fi
    ;;
  help | --help | -h | "")
    dot_help
    ;;
  *)
    echo "rdf: unknown command '$1'" >&2
    echo "Run 'rdf help' for usage information" >&2
    return 1
    ;;
  esac
}
