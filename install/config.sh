#!/bin/sh
# Shared configuration for all install scripts

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$DOTFILES_DIR"
PACKAGES_DIR="$REPO_DIR/packages"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_TARGET="$XDG_CONFIG_HOME/.dotfiles"
BIN_TARGET="$HOME/.local/bin"
BUILD_DIR="${TMPDIR:-/tmp}"

# -----------------------------------------------------------------------------
# Package directories
# -----------------------------------------------------------------------------

PKGS_MACOS="$PACKAGES_DIR/macos"
PKGS_ARCH="$PACKAGES_DIR/arch"
PKGS_WINDOWS="$PACKAGES_DIR/windows"

# -----------------------------------------------------------------------------
# Categories
# -----------------------------------------------------------------------------

CATEGORIES="base cli development gui"

# -----------------------------------------------------------------------------
# Shell RC files
# -----------------------------------------------------------------------------

SHELL_ZSHRC="$HOME/.zshrc"
SHELL_BASHRC="$HOME/.bashrc"

# -----------------------------------------------------------------------------
# URLs
# -----------------------------------------------------------------------------

AUR_BASE_URL="https://aur.archlinux.org"

# -----------------------------------------------------------------------------
# Package managers
# -----------------------------------------------------------------------------

BREW_INSTALL_URL="https://brew.sh"
CHOCO_INSTALL_URL="https://community.chocolatey.org/install.ps1"
SCOOP_INSTALL_URL="https://get.scoop.sh"

# -----------------------------------------------------------------------------
# Init path
# -----------------------------------------------------------------------------

INIT_SCRIPT="$REPO_DIR/init.sh"
