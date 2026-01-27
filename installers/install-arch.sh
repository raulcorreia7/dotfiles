#!/bin/sh
set -eu

# -----------------------------------------------------------------------------
# Paths and config
# -----------------------------------------------------------------------------

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

# Preserve original user home if running with sudo
if [ -n "${SUDO_USER:-}" ]; then
  ORIGINAL_HOME="/home/$SUDO_USER"
  XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$ORIGINAL_HOME/.config}"
  CONFIG_TARGET="$XDG_CONFIG_HOME/.dotfiles"
  BIN_TARGET="$ORIGINAL_HOME/.local/bin"
  SHELL_ZSHRC="$ORIGINAL_HOME/.zshrc"
  SHELL_BASHRC="$ORIGINAL_HOME/.bashrc"
fi

check_sudo_access() {
  if ! command -v sudo >/dev/null 2>&1; then
    error 'sudo is required but not found'
  fi

  # Test if we can use sudo (will ask for password if needed and cache it)
  if ! sudo -v 2>/dev/null; then
    log "Note: sudo access will be required for package installation"
  fi
}

# -----------------------------------------------------------------------------
# Package install
# -----------------------------------------------------------------------------

PACMAN_INSTALLED_FILE=""
PACMAN_REPO_FILE=""

cleanup_tmp_files() {
  [ -n "$PACMAN_INSTALLED_FILE" ] && rm -f "$PACMAN_INSTALLED_FILE"
  [ -n "$PACMAN_REPO_FILE" ] && rm -f "$PACMAN_REPO_FILE"
}

trap cleanup_tmp_files EXIT

count_lines() {
  awk 'NF{c++} END{print c+0}'
}

make_list_file() {
  pkg_file="$1"
  packages=$(read_packages "$pkg_file")
  [ -n "$packages" ] || return 1

  tmp_file=$(mktemp)
  printf '%s\n' $packages | sort -u > "$tmp_file"
  printf '%s\n' "$tmp_file"
}

list_has() {
  list_file="$1"
  item="$2"
  grep -Fxq "$item" "$list_file"
}

get_installed_list_file() {
  if [ -z "$PACMAN_INSTALLED_FILE" ]; then
    PACMAN_INSTALLED_FILE=$(mktemp)
    pacman -Qq | sort -u > "$PACMAN_INSTALLED_FILE"
  fi
  printf '%s\n' "$PACMAN_INSTALLED_FILE"
}

get_pacman_repo_list_file() {
  if [ -z "$PACMAN_REPO_FILE" ]; then
    PACMAN_REPO_FILE=$(mktemp)
    pacman -Slq | sort -u > "$PACMAN_REPO_FILE"
  fi
  printf '%s\n' "$PACMAN_REPO_FILE"
}

is_package_installed() {
  local pkg="$1"
  pacman -Q "$pkg" >/dev/null 2>&1
}

is_package_in_pacman() {
  local pkg="$1"
  pacman -Si "$pkg" >/dev/null 2>&1
}

is_package_in_aur() {
  local pkg="$1"
  if command -v paru >/dev/null 2>&1; then
    paru -Si "$pkg" >/dev/null 2>&1
  else
    return 1
  fi
}

install_pacman_packages() {
  local pkg_file="${PKGS_ARCH_PACMAN_FILE}"

  if [ ! -f "$pkg_file" ]; then
    return
  fi

  pkg_list_file=$(make_list_file "$pkg_file") || return
  installed_list_file=$(get_installed_list_file)

  if [ "${DOTFILES_VERIFY_PACKAGES:-0}" = "1" ]; then
    repo_list_file=$(get_pacman_repo_list_file)
    missing=$(comm -23 "$pkg_list_file" "$repo_list_file")
    if [ -n "$missing" ]; then
      printf '%s\n' "$missing" >&2
      error "Pacman package(s) not found in repos"
    fi
  fi

  packages_to_install=$(comm -23 "$pkg_list_file" "$installed_list_file")
  if [ -n "$packages_to_install" ]; then
    info "Installing pacman packages ($(printf '%s\n' "$packages_to_install" | count_lines))"
    sudo pacman -S --needed --noconfirm $packages_to_install
  else
    info "No new pacman packages to install"
  fi

  rm -f "$pkg_list_file"
}

install_paru() {
  if command -v paru >/dev/null 2>&1; then
    info "paru is already installed"
    return
  fi

  if sudo pacman -Ss '^paru$' >/dev/null 2>&1; then
    info "Installing paru from pacman"
    sudo pacman -S --noconfirm paru
    return
  fi

  info "Bootstrapping paru from AUR"

  for pkg in git base-devel; do
    if ! pacman -Q "$pkg" >/dev/null 2>&1; then
      info "Installing ${pkg} for paru bootstrap"
      sudo pacman -S --needed --noconfirm "$pkg"
    fi
  done

  local build_dir="${BUILD_DIR}/paru"
  rm -rf "$build_dir"
  git clone "${AUR_BASE_URL}/paru.git" "$build_dir"
  cd "$build_dir"
  makepkg -si --noconfirm
  cd - >/dev/null
  rm -rf "$build_dir"

  info "paru installed successfully"
}

install_aur_packages() {
  local aur_file="${PKGS_ARCH_AUR_FILE}"

  if [ ! -f "$aur_file" ]; then
    info "No AUR packages file found"
    return
  fi

  aur_list_file=$(make_list_file "$aur_file") || {
    info "No AUR packages to install"
    return
  }

  if [ "${DOTFILES_VERIFY_PACKAGES:-0}" = "1" ]; then
    if ! paru -Si $(cat "$aur_list_file"); then
      error "AUR package(s) not found"
    fi
  fi

  installed_list_file=$(get_installed_list_file)
  packages_to_install=$(comm -23 "$aur_list_file" "$installed_list_file")
  if [ -n "$packages_to_install" ]; then
    info "Installing AUR packages ($(printf '%s\n' "$packages_to_install" | count_lines))"
    paru -S --needed --noconfirm $packages_to_install
  else
    info "No new AUR packages to install"
  fi

  rm -f "$aur_list_file"
}

verify_arch_package_lists() {
  if [ "${DOTFILES_VERIFY_PACKAGES:-0}" != "1" ]; then
    return
  fi

  local pacman_file="${PKGS_ARCH_PACMAN_FILE}"
  [ -f "$pacman_file" ] || error "Pacman packages file not found: ${pacman_file}"

  local aur_file="${PKGS_ARCH_AUR_FILE}"
  [ -f "$aur_file" ] || error "AUR packages file not found: ${aur_file}"
}

# -----------------------------------------------------------------------------
# Platform checks
# -----------------------------------------------------------------------------

is_arch_based() {
  [ -f /etc/arch-release ] || [ -f /etc/cachyos-release ]
}

is_arch_from_os_release() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    [ "${ID:-}" = "arch" ] || [ "${ID:-}" = "cachyos" ]
  else
    return 1
  fi
}

install_arch_packages() {
  install_pacman_packages

  install_paru
  verify_arch_package_lists
  install_aur_packages

  info "Installation complete"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  check_sudo_access

  if is_arch_based || is_arch_from_os_release; then
    install_arch_packages
    return 0
  fi

  error "Unsupported Linux distro. Arch/CachyOS only."
}

main "$@"
