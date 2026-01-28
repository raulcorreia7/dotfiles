#!/bin/sh
# Master format runner for dotfiles.

set -euo pipefail

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ -r "$ROOT_DIR/before/paths.sh" ]; then
  . "$ROOT_DIR/before/paths.sh"
fi

# Directories to exclude (third-party code)
EXCLUDE_DIRS="${DOTFILES_EXCLUDE_DIRS:-config/tmux/plugins config/zimfw/modules config/kimi .git .sisyphus}"
EXCLUDE_FILES="${DOTFILES_EXCLUDE_FILES:-}"

# ------------------------------------------------------------------------------
# SECTION 2: Helper Functions
# ------------------------------------------------------------------------------

info() {
  printf '%s\n' "$*"
}

warn() {
  printf '%s\n' "$*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

run() {
  name=$1
  shift
  if "$@"; then
    info "ok: $name"
    return 0
  fi
  warn "fail: $name"
  return 1
}

# ------------------------------------------------------------------------------
# SECTION 3: Main
# ------------------------------------------------------------------------------

fail=0

if [ $# -eq 0 ]; then
  set -- "$ROOT_DIR"
fi

info "==> dotfiles format: $*"

filter_excludes() {
  if have grep; then
    _pattern=""
    for dir in $EXCLUDE_DIRS; do
      _pattern="${_pattern}${_pattern:+|}/$dir(/|$)"
    done
    for file in $EXCLUDE_FILES; do
      _pattern="${_pattern}${_pattern:+|}/$file$"
    done
    if [ -n "$_pattern" ]; then
      grep -Ev "$_pattern"
      return 0
    fi
  fi
  cat
}

list_files() {
  _glob=$1
  shift
  find "$@" -type f -name "$_glob" 2>/dev/null | filter_excludes || true
}

dedupe_list() {
  awk 'NF && !seen[$0]++'
}

list_shell_files() {
  _files=""
  _files=$(list_files '*.sh' "$@")
  _files="${_files}${_files:+
}$(list_files '*.bash' "$@")"
  _files="${_files}${_files:+
}$(list_files '*.zsh' "$@")"
  _shebang=$(find "$@" -type f 2>/dev/null | filter_excludes | while IFS= read -r _file; do
    _first=$(head -n 1 "$_file" 2>/dev/null || true)
    case "$_first" in
      '#!'*'/sh' | '#!'*' env sh' | \
        '#!'*'/bash' | '#!'*' env bash' | \
        '#!'*'/zsh' | '#!'*' env zsh')
        printf '%s\n' "$_file"
        ;;
    esac
  done)
  printf '%s\n' "$_files" "$_shebang" | dedupe_list
}

# Shell
if have shfmt; then
  files=$(list_shell_files "$@")
  if [ -n "$files" ]; then
    for f in $files; do
      _lang="posix"
      case "$f" in
        *.bash) _lang="bash" ;;
        *.zsh) _lang="zsh" ;;
        *)
          _first=$(head -n 1 "$f" 2>/dev/null || true)
          case "$_first" in
            *bash*) _lang="bash" ;;
            *zsh*) _lang="zsh" ;;
          esac
          ;;
      esac
      if [ "$_lang" = "zsh" ]; then
        info "skip: shfmt (zsh file) $f"
        continue
      fi
      if ! shfmt -w -i 2 -bn -ci -ln "$_lang" "$f"; then
        warn "fail: shfmt ($f)"
        fail=1
      fi
    done
  else
    info "skip: shfmt (no shell files)"
  fi
else
  info "skip: shfmt (not installed)"
fi

# Lua
if have stylua; then
  files=$(list_files '*.lua' "$@")
  if [ -n "$files" ]; then
    run "stylua" sh -c 'printf "%s\n" "$@" | xargs stylua' stylua $files || fail=1
  else
    info "skip: stylua (no .lua files)"
  fi
else
  info "skip: stylua (not installed)"
fi

# TOML
if have taplo; then
  files=$(list_files '*.toml' "$@")
  if [ -n "$files" ]; then
    run "taplo fmt" sh -c 'printf "%s\n" "$@" | xargs taplo fmt' taplo $files || fail=1
  else
    info "skip: taplo fmt (no .toml files)"
  fi
else
  info "skip: taplo fmt (not installed)"
fi

# YAML
if have yamlfmt; then
  files=$(list_files '*.yml' "$@")
  _yaml=$(list_files '*.yaml' "$@")
  files="${files}${files:+
}$_yaml"
  if [ -n "$files" ]; then
    run "yamlfmt" sh -c 'printf "%s\n" "$@" | xargs yamlfmt' yamlfmt $files || fail=1
  else
    info "skip: yamlfmt (no .yml/.yaml files)"
  fi
else
  info "skip: yamlfmt (not installed)"
fi

# Prettier (web formats)
if have prettier; then
  files=""
  for _ext in "*.json" "*.md" "*.yml" "*.yaml" "*.css" "*.scss" "*.html" "*.js" "*.ts"; do
    _found=$(list_files "$_ext" "$@")
    files="${files}${files:+
}$_found"
  done
  if [ -n "$files" ]; then
    run "prettier" sh -c 'printf "%s\n" "$@" | xargs prettier --write' prettier $files || fail=1
  else
    info "skip: prettier (no matching files)"
  fi
else
  info "skip: prettier (not installed)"
fi

if [ "$fail" -ne 0 ]; then
  warn "==> done with errors"
  exit 1
fi

info "==> done"
