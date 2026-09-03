#!/bin/sh
# Shared configuration for the pure-configuration installer (install/)

if [ -z "${DOTFILES_DIR:-}" ]; then
  if [ -n "${INSTALL_DIR:-}" ]; then
    DOTFILES_DIR=$(CDPATH='' cd -- "$INSTALL_DIR/.." && pwd)
  else
    DOTFILES_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
  fi
fi
REPO_DIR="$DOTFILES_DIR"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_TARGET="$HOME/.local/bin"
BUILD_DIR="${TMPDIR:-/tmp}"

SHELL_ZSHRC="$HOME/.zshrc"
SHELL_BASHRC="$HOME/.bashrc"

DOTFILES_ZIM_HOME="$DOTFILES_DIR/config/zimfw"
DOTFILES_ZIM_CONFIG="$DOTFILES_DIR/config/.zimrc"
