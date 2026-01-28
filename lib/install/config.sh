#!/bin/sh
# Shared configuration for all install scripts

# ------------------------------------------------------------------------------
# SECTION 1: Path Setup
# ------------------------------------------------------------------------------

# Resolve script directory
# When sourced, SCRIPT_DIR should be set by the caller. Otherwise, detect it.
if [ -z "${SCRIPT_DIR:-}" ]; then
  SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
fi

# Source centralized paths
. "$SCRIPT_DIR/../../before/paths.sh"

# ------------------------------------------------------------------------------
# SECTION 2: Installer Configuration
# ------------------------------------------------------------------------------

# Installer-specific paths
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
INSTALLERS_DIR="$DOTFILES_DIR/lib/install"

# Package list directories
PKGS_ARCH="$SCRIPT_DIR/packages/arch"

# Package list files
PKGS_ARCH_PACMAN_FILE="$PKGS_ARCH/pacman"
PKGS_ARCH_AUR_FILE="$PKGS_ARCH/aur"

# Shell configs
SHELL_ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
SHELL_BASHRC="$HOME/.bashrc"

# URLs
AUR_BASE_URL="https://aur.archlinux.org"
