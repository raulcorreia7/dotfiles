#!/bin/sh
# Installs my omp extensions from the checkout chezmoi keeps (see .chezmoiexternal.toml.tmpl)
# into ~/.omp/agent/extensions. Their install.sh replaces each extension wholesale, so re-runs are safe.
set -eu

main() {
  src="$HOME/.local/share/omp-extensions"
  [ -x "$src/install.sh" ] || return 0
  "$src/install.sh" >/dev/null
}

main "$@"
