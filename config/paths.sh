#!/bin/sh
# Centralized path definitions for dotfiles.
# Source this file to ensure consistent paths across runtime and install-time.

# Base directory (can be overridden by environment)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Config paths
DOTFILES_CONFIG_DIR="${DOTFILES_CONFIG_DIR:-$DOTFILES_DIR/config}"
DOTFILES_SHELL_DIR="${DOTFILES_SHELL_DIR:-$DOTFILES_CONFIG_DIR/shell}"
DOTFILES_PLUGINS_DIR="${DOTFILES_PLUGINS_DIR:-$DOTFILES_CONFIG_DIR/plugins}"
DOTFILES_LOADERS_DIR="${DOTFILES_LOADERS_DIR:-$DOTFILES_CONFIG_DIR/loaders}"

# Legacy scripts path (deprecated)
DOTFILES_SCRIPTS_DIR="${DOTFILES_SCRIPTS_DIR:-$DOTFILES_DIR/scripts}"

# Install paths
DOTFILES_INSTALL_DIR="${DOTFILES_INSTALL_DIR:-$DOTFILES_DIR/installers}"

# User paths (install targets)
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
USER_BIN_DIR="${USER_BIN_DIR:-$HOME/.local/bin}"
