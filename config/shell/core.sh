#!/bin/sh
# Core shell helpers and plugin loader.

# ------------------------------------------------------------------------------
# SECTION 1: Base Helpers (shared across shells)
# ------------------------------------------------------------------------------

__dot_has() {
  command -v "$1" >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# SECTION 2: Shell Detection Helpers
# ------------------------------------------------------------------------------

# Detect shell type for tool initialization
__dot_shell_type() {
  [ -n "${ZSH_VERSION:-}" ] && printf 'zsh' && return
  [ -n "${BASH_VERSION:-}" ] && printf 'bash' && return
  printf 'sh'
}

# Initialize tool with shell integration
__dot_init_tool() {
  _tool="$1"
  __dot_has "$_tool" || return 0

  _shell=$(__dot_shell_type)
  eval "$($_tool init "$_shell" 2>/dev/null || $_tool init sh)"
}

# ------------------------------------------------------------------------------
# SECTION 3: Plugin Loading
# ------------------------------------------------------------------------------

__dot_plugin_key() {
  # Normalize a plugin path into a safe env var suffix.
  printf '%s' "$1" | tr '[:lower:]/-' '[:upper:]__' | tr -c 'A-Z0-9_' '_'
}

__dot_plugin_enabled() {
  _plugin_key=$(__dot_plugin_key "$1")
  _var_name="DOTFILES_ENABLE_${_plugin_key}"

  case $(eval "printf '%s' \"\${${_var_name}:-1}\"") in
    0 | false | no | off) return 1 ;;
    *) return 0 ;;
  esac
}

__dot_load_plugin() {
  plugin="$1"
  plugin_dir="$DOTFILES_PLUGINS_DIR/$plugin"
  plugin_init="$plugin_dir/init.sh"

  # Skip duplicates
  case " $__DOT_PLUGIN_LOADED " in
    *" $plugin "*) return 0 ;;
  esac

  [ -r "$plugin_init" ] || return 0
  __dot_plugin_enabled "$plugin" || return 0

  __dot_debug "dotfiles: plugin $plugin"
  . "$plugin_init"
  __DOT_PLUGIN_LOADED="$__DOT_PLUGIN_LOADED $plugin"
}

rdotfiles() {
  _cmd=$(command -v rdotfiles 2>/dev/null || true)
  case "$_cmd" in
    /*)
      command rdotfiles "$@"
      return $?
      ;;
  esac

  if [ -x "$DOTFILES_DIR/bin/rdotfiles" ]; then
    "$DOTFILES_DIR/bin/rdotfiles" "$@"
    return $?
  fi

  __dot_log "dotfiles: rdotfiles not found (run installers/link.sh)"
  return 1
}
