#!/bin/sh
# Bootstrap a machine: install chezmoi if it is missing, then apply this clone.
# Arguments go to `chezmoi init` (e.g. --promptChoice "Machine profile=work").
set -eu

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
  command -v chezmoi >/dev/null 2>&1 || install_chezmoi
  exec chezmoi init --apply --source "$(repo_dir)" "$@"
}

main "$@"
