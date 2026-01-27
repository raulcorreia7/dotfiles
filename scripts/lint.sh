#!/bin/sh
# Master lint/format runner for dotfiles.

set -e

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

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

fail=0

info "==> dotfiles lint/format: $ROOT_DIR"

# Shell
if have shfmt; then
  files=$(rg --files -g '*.sh' "$ROOT_DIR" || true)
  if [ -n "$files" ]; then
    run "shfmt" sh -c 'printf "%s\n" "$@" | xargs shfmt -w -i 2 -bn -ci' shfmt $files || fail=1
  else
    info "skip: shfmt (no .sh files)"
  fi
else
  info "skip: shfmt (not installed)"
fi

# Lua
if have stylua; then
  files=$(rg --files -g '*.lua' "$ROOT_DIR" || true)
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
  files=$(rg --files -g '*.toml' "$ROOT_DIR" || true)
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
  files=$(rg --files -g '*.yml' -g '*.yaml' "$ROOT_DIR" || true)
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
  files=$(rg --files -g '*.json' -g '*.md' -g '*.yml' -g '*.yaml' -g '*.css' -g '*.scss' -g '*.html' -g '*.js' -g '*.ts' "$ROOT_DIR" || true)
  if [ -n "$files" ]; then
    run "prettier" sh -c 'printf "%s\n" "$@" | xargs prettier --write' prettier $files || fail=1
  else
    info "skip: prettier (no matching files)"
  fi
else
  info "skip: prettier (not installed)"
fi

# EditorConfig
if have editorconfig-checker; then
  run "editorconfig-checker" editorconfig-checker "$ROOT_DIR" || fail=1
else
  info "skip: editorconfig-checker (not installed)"
fi

if [ "$fail" -ne 0 ]; then
  warn "==> done with errors"
  exit 1
fi

info "==> done"
