#!/bin/sh
# install.sh [chezmoi init args...]
# Bootstrap a machine: install chezmoi if it is missing, then apply this clone.
# Arguments go to `chezmoi init` (e.g. --promptChoice "Machine profile=work").
set -eu

usage() {
  cat <<'USAGE'
Usage: ./install.sh [chezmoi init args...]

Installs chezmoi if it is missing, then applies this clone to $HOME.
You are asked for host name, profile and git identity once; answers stay on the machine.
Example: ./install.sh --promptChoice "Machine profile=work"
USAGE
}

repo_dir() {
  CDPATH='' cd -- "$(dirname -- "$0")" && pwd
}

install_chezmoi() {
  echo "installing chezmoi"
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm chezmoi
  elif command -v brew >/dev/null 2>&1; then
    brew install chezmoi
  else
    sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
    PATH="$HOME/.local/bin:$PATH"
  fi
}

main() {
  case "${1:-}" in -h | --help) usage; return 0 ;; esac
  command -v chezmoi >/dev/null 2>&1 || install_chezmoi
  exec chezmoi init --apply --source "$(repo_dir)" "$@"
}

main "$@"
