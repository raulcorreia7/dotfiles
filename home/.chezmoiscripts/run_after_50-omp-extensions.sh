#!/bin/sh
# Keeps my omp extensions (private repo raulcorreia7/omp-extensions) cloned and up to date,
# then installs them into ~/.omp/agent/extensions. Skipped, not failed, until `gh auth login`.
set -eu

REPO=https://github.com/raulcorreia7/omp-extensions.git
SRC="${XDG_DATA_HOME:-$HOME/.local/share}/omp-extensions"

git_gh() {
  git -c credential.helper= -c credential.helper='!gh auth git-credential' "$@"
}

sync_repo() {
  if [ -d "$SRC/.git" ]; then
    git_gh -C "$SRC" pull -q --ff-only
  else
    git_gh clone -q "$REPO" "$SRC"
  fi
}

main() {
  if ! gh auth status >/dev/null 2>&1; then
    echo "omp-extensions: skipped; run 'gh auth login', then 'chezmoi apply'" >&2
    return 0
  fi
  sync_repo
  "$SRC/install.sh" >/dev/null
}

main "$@"
