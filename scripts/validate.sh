#!/bin/sh
set -euo pipefail
# Validation script for dotfiles migration

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
ERRORS=0

log() { printf '%s\n' "$*"; }
error() { printf 'ERROR: %s\n' "$*" >&2; ERRORS=$((ERRORS + 1)); }

# -----------------------------------------------------------------------------
# Syntax Checks
# -----------------------------------------------------------------------------

log "=== Syntax Checks ==="

for f in "$DOTFILES_DIR"/init.sh "$DOTFILES_DIR"/bin/rdotfiles \
         "$DOTFILES_DIR"/lib/loader.sh "$DOTFILES_DIR"/lib/manifest.sh; do
  if [ -r "$f" ]; then
    if sh -n "$f" 2>&1; then
      log "  OK: $f"
    else
      error "Syntax error in: $f"
    fi
  fi
done

for plugin in "$DOTFILES_DIR"/modules/*/init.sh; do
  [ -r "$plugin" ] || continue
  if sh -n "$plugin" 2>&1; then
    log "  OK: $plugin"
  else
    error "Syntax error in: $plugin"
  fi
done

# -----------------------------------------------------------------------------
# Required Files Check
# -----------------------------------------------------------------------------

log ""
log "=== Required Files ==="

required_files="
  init.sh
  before/paths.sh
  lib/loader.sh
  lib/manifest.sh
  bin/rdotfiles
  lib/install/link.sh
"

for f in $required_files; do
  if [ -r "$DOTFILES_DIR/$f" ]; then
    log "  OK: $f"
  else
    error "Missing: $f"
  fi
done

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

log ""
if [ "$ERRORS" -eq 0 ]; then
  log "=== VALIDATION PASSED ==="
  exit 0
else
  log "=== VALIDATION FAILED: $ERRORS error(s) ==="
  exit 1
fi
