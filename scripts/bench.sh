#!/bin/sh
set -euo pipefail
# Benchmark and profile shell startup

MODE="${1:-bench}"
ITERATIONS="${2:-10}"

case "$MODE" in
  bench|benchmark)
    echo "=== Shell Startup Benchmark ($ITERATIONS iterations) ==="
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    cat > "$tmpdir/.zshrc" << 'ZSHRC'
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
[ -r "$DOTFILES_DIR/init.sh" ] && . "$DOTFILES_DIR/init.sh"
ZSHRC
    total_ms=0
    for i in $(seq 1 "$ITERATIONS"); do
      start=$(date +%s%N)
      ZDOTDIR="$tmpdir" zsh -i -c exit 2>/dev/null
      end=$(date +%s%N)
      elapsed=$(( (end - start) / 1000000 ))
      total_ms=$((total_ms + elapsed))
      echo "Run $i: ${elapsed}ms"
    done
    avg=$((total_ms / ITERATIONS))
    echo ""
    echo "Average: ${avg}ms"
    ;;
  
  profile|zprof)
    echo "=== Shell Startup Profile ==="
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    cat > "$tmpdir/.zshrc" << 'ZSHRC'
zmodload zsh/zprof
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
[ -r "$DOTFILES_DIR/init.sh" ] && . "$DOTFILES_DIR/init.sh"
zprof
ZSHRC
    ZDOTDIR="$tmpdir" zsh -i -c exit 2>&1 | head -50
    ;;
  
  *)
    echo "Usage: $0 [bench|profile] [iterations]"
    exit 1
    ;;
esac
