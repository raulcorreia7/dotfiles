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
. "$SCRIPT_DIR/../config/paths.sh"

# ------------------------------------------------------------------------------
# SECTION 2: Installer Configuration
# ------------------------------------------------------------------------------

# Installer-specific paths
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
INSTALLERS_DIR="$DOTFILES_INSTALL_DIR"
PACKAGES_DIR="$DOTFILES_DIR/packages"
BUILD_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/build"

# Package list directories
PKGS_ARCH="$PACKAGES_DIR/arch"
PKGS_MACOS="$PACKAGES_DIR/macos"
PKGS_WINDOWS="$PACKAGES_DIR/windows"

# Package list files
PKGS_ARCH_PACMAN_FILE="$PKGS_ARCH/pacman"
PKGS_ARCH_AUR_FILE="$PKGS_ARCH/aur"

# Categories
CATEGORIES="base cli development gui"

# Shell configs
SHELL_ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
SHELL_BASHRC="$HOME/.bashrc"

# URLs
AUR_BASE_URL="https://aur.archlinux.org"
BREW_INSTALL_URL="https://brew.sh"
CHOCO_INSTALL_URL="https://community.chocolatey.org/install.ps1"
SCOOP_INSTALL_URL="https://get.scoop.sh"

# Init path
INIT_SCRIPT="$DOTFILES_DIR/init.sh"
