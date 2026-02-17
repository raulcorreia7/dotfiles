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

dot_has() {
  command -v "$1" >/dev/null 2>&1
}

dot_shell_type() {
  if [ -n "${ZSH_VERSION:-}" ]; then
    echo "zsh"
  elif [ -n "${BASH_VERSION:-}" ]; then
    echo "bash"
  else
    echo "sh"
  fi
}

dot_eval_init() {
  dot_has "$1" || return 1
  eval "$($1 init "$(dot_shell_type)" 2>/dev/null)"
}

__dot_debug() {
  [ "${DOTFILES_DEBUG:-0}" = "1" ] && printf '[DEBUG] %s\n' "$*" >&2
}

# =============================================================================
# PLUGIN LOADING
# =============================================================================

__dot_plugin_key() {
  printf '%s' "$1" | tr '[:lower:]/-' '[:upper:]__' | tr -c 'A-Z0-9_' '_'
}

__dot_plugin_enabled() {
  plugin_key=$(__dot_plugin_key "$1")
  eval "enabled=\${DOTFILES_ENABLE_${plugin_key}:-1}"
  [ "$enabled" != "0" ]
}

__dot_load_plugin() {
  plugin="$1"
  plugin_init="${DOTFILES_PLUGINS_DIR:-$DOTFILES_DIR/config/plugins}/$plugin/init.sh"
  [ -r "$plugin_init" ] || return 0
  __dot_plugin_enabled "$plugin" || return 0
  __dot_debug "plugin: $plugin"
  . "$plugin_init"
}

# =============================================================================
# RDF COMMAND
# =============================================================================

__rdf_doctor() {
  for label in "fzf:fzf" "git:git" "rg:rg" "fd:fd" "bat:bat" "eza:eza,exa"; do
    name="${label%%:*}"
    cmds="${label#*:}"
    found=""
    alts=""

    for cmd in ${cmds//,/ }; do
      if dot_has "$cmd"; then
        [ -z "$found" ] && found="$cmd" || alts="$alts $cmd"
      fi
    done

    if [ -n "$found" ]; then
      if [ -n "$alts" ]; then
        printf '%s: ok (%s; alt:%s)\n' "$name" "$found" "$alts"
      else
        printf '%s: ok (%s)\n' "$name" "$found"
      fi
    else
      printf '%s: missing (try: %s)\n' "$name" "${cmds//,/ or }"
    fi
  done
}

__rdf_help() {
  cat <<'EOF'
Usage: rdf <command>

Commands:
  reload    Reload dotfiles
  edit      Edit dotfiles
  doctor    Check tools
  cd        Go to dotfiles
  update    System update (Arch)
  orphans   List/remove orphans (Arch)
  cache     Show/clean cache (Arch)
EOF
}

rdf() {
  case "${1:-}" in
  reload)
    . "${DOTFILES_DIR:-$HOME/.dotfiles}/init.sh" && echo "Reloaded"
    ;;
  edit)
    ${EDITOR:-nvim} "${DOTFILES_DIR:-$HOME/.dotfiles}"
    ;;
  doctor)
    __rdf_doctor
    ;;
  cd)
    cd "${DOTFILES_DIR:-$HOME/.dotfiles}" || return 1
    ;;
  update | orphans | cache)
    sub="__rdf_arch_$1"
    shift
    if type "$sub" >/dev/null 2>&1; then
      "$sub" "$@"
    else
      echo "rdf $1: not available on this system"
      return 1
    fi
    ;;
  help | --help | -h | "")
    __rdf_help
    ;;
  *)
    echo "rdf: unknown command '$1'" >&2
    return 1
    ;;
  esac
}
