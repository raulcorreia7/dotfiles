#!/bin/sh
# Shared configuration for all install scripts

if [ -n "${DOTFILES_DIR:-}" ]; then
  REPO_DIR="$DOTFILES_DIR"
elif [ -n "${INSTALL_DIR:-}" ]; then
  DOTFILES_DIR=$(CDPATH='' cd -- "$INSTALL_DIR/.." && pwd)
  REPO_DIR="$DOTFILES_DIR"
else
  DOTFILES_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
  REPO_DIR="$DOTFILES_DIR"
fi

PACKAGES_DIR="$REPO_DIR/packages"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_TARGET="$XDG_CONFIG_HOME/.dotfiles"
BIN_TARGET="$HOME/.local/bin"
BUILD_DIR="${TMPDIR:-/tmp}"

PKGS_MACOS="$PACKAGES_DIR/macos"
PKGS_ARCH="$PACKAGES_DIR/arch"
PKGS_ARCH_PACMAN_FILE="$PKGS_ARCH/pacman"
PKGS_ARCH_AUR_FILE="$PKGS_ARCH/aur"

SHELL_ZSHRC="$HOME/.zshrc"
SHELL_BASHRC="$HOME/.bashrc"

AUR_BASE_URL="https://aur.archlinux.org"

DOTFILES_ZIM_HOME="$DOTFILES_DIR/config/zimfw"
DOTFILES_ZIM_CONFIG="$DOTFILES_DIR/config/.zimrc"
