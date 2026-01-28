#!/bin/sh
# Master lint runner for dotfiles.

set -euo pipefail

# ------------------------------------------------------------------------------
# SECTION 1: Setup
# ------------------------------------------------------------------------------

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ -r "$ROOT_DIR/before/paths.sh" ]; then
  . "$ROOT_DIR/before/paths.sh"
fi

# Directories/files to exclude (third-party or generated)
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
# SECTION 3: File Listing
# ------------------------------------------------------------------------------

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

list_all_files() {
  find "$@" -type f 2>/dev/null | filter_excludes || true
}

# ------------------------------------------------------------------------------
# SECTION 4: Main
# ------------------------------------------------------------------------------

if [ $# -eq 0 ]; then
  set -- "$ROOT_DIR"
fi

fail=0

info "==> dotfiles lint: $*"

if have editorconfig-checker; then
  files=$(list_all_files "$@")
  if [ -n "$files" ]; then
    run "editorconfig-checker" sh -c 'printf "%s\n" "$@" | xargs editorconfig-checker' editorconfig-checker $files || fail=1
  else
    info "skip: editorconfig-checker (no files)"
  fi
else
  info "skip: editorconfig-checker (not installed)"
fi

if [ "$fail" -ne 0 ]; then
  warn "==> done with errors"
  exit 1
fi

info "==> done"
