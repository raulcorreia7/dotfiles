#!/bin/sh
# Keeps my omp extensions (github.com/raulcorreia7/omp-extensions) cloned at the latest commit,
# then installs them into ~/.omp/agent/extensions. The clone is never edited, so it resets to upstream.
set -eu

REPO=https://github.com/raulcorreia7/omp-extensions.git
SRC="${XDG_DATA_HOME:-$HOME/.local/share}/omp-extensions"

sync_repo() {
  if [ -d "$SRC/.git" ]; then
    git -C "$SRC" fetch -q origin
    git -C "$SRC" reset -q --hard origin/HEAD
  else
    git clone -q "$REPO" "$SRC"
  fi
}

main() {
  sync_repo
  "$SRC/install.sh" >/dev/null
}

main "$@"
