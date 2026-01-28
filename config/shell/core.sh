#!/bin/sh
# Core shell helpers and plugin loader.

# ------------------------------------------------------------------------------
# SECTION 1: Base Helpers (shared across shells)
# ------------------------------------------------------------------------------

__dot_has() {
  command -v "$1" >/dev/null 2>&1
}

__dot_pick() {
  for cmd in "$@"; do
    if __dot_has "$cmd"; then
      printf '%s\n' "$cmd"
      return 0
    fi
  done
  return 1
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

# ------------------------------------------------------------------------------
# SECTION 4: Doctor
# ------------------------------------------------------------------------------

__dot_doctor_line() {
  _label=$1
  shift
  _cmd=$(__dot_pick "$@")
  if [ -n "$_cmd" ]; then
    _alts=""
    for _alt in "$@"; do
      [ "$_alt" = "$_cmd" ] && continue
      if __dot_has "$_alt"; then
        _alts="${_alts}${_alts:+ }$_alt"
      fi
    done
    if [ -n "$_alts" ]; then
      printf '%s: ok (%s; alt: %s)\n' "$_label" "$_cmd" "$_alts"
    else
      printf '%s: ok (%s)\n' "$_label" "$_cmd"
    fi
  else
    printf '%s: missing (try: %s)\n' "$_label" "$*"
  fi
}

dot_doctor() {
  __dot_doctor_line "fzf" fzf
  __dot_doctor_line "git" git
  __dot_doctor_line "sed" gsed sed
  __dot_doctor_line "rg" rg
  __dot_doctor_line "fd" fd
  __dot_doctor_line "grep" grep
  __dot_doctor_line "cat" cat
  __dot_doctor_line "bat" bat
  __dot_doctor_line "exa" eza exa
}

# ------------------------------------------------------------------------------
# SECTION 5: Editor Helpers
# ------------------------------------------------------------------------------

dot_nvimcfg() {
  case "$1" in
    -h | --help)
      printf 'Usage: nvimcfg\nOpen ~/.config/nvim.\n'
      return 0
      ;;
  esac
  # Open the Neovim config in the preferred editor.
  _editor="${EDITOR:-nvim}"
  _nvimcfg_path="$HOME/.config/nvim"
  "$_editor" "$_nvimcfg_path"
}
