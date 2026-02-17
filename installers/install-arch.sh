#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

if [ -n "${SUDO_USER:-}" ]; then
  ORIGINAL_HOME="/home/$SUDO_USER"
  XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$ORIGINAL_HOME/.config}"
  CONFIG_TARGET="$XDG_CONFIG_HOME/.dotfiles"
  BIN_TARGET="$ORIGINAL_HOME/.local/bin"
  SHELL_ZSHRC="$ORIGINAL_HOME/.zshrc"
  SHELL_BASHRC="$ORIGINAL_HOME/.bashrc"
fi

check_sudo_access() {
  command -v sudo >/dev/null 2>&1 || log_error "sudo is required but not found"
  sudo -v 2>/dev/null || {
    log "Note: sudo access will be required for package installation"
    return 1
  }
  return 0
}

has_sudo_access() {
  sudo -v 2>/dev/null
}

PACMAN_INSTALLED_FILE=""
PACMAN_REPO_FILE=""

cleanup_tmp_files() {
  [ -n "$PACMAN_INSTALLED_FILE" ] && rm -f "$PACMAN_INSTALLED_FILE" || true
  [ -n "$PACMAN_REPO_FILE" ] && rm -f "$PACMAN_REPO_FILE" || true
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
  printf '%s\n' $packages | sort -u >"$tmp_file"
  printf '%s\n' "$tmp_file"
}

get_installed_list_file() {
  [ -z "$PACMAN_INSTALLED_FILE" ] && {
    PACMAN_INSTALLED_FILE=$(mktemp)
    pacman -Qq | sort -u >"$PACMAN_INSTALLED_FILE"
  }
  printf '%s\n' "$PACMAN_INSTALLED_FILE"
}

get_pacman_repo_list_file() {
  [ -z "$PACMAN_REPO_FILE" ] && {
    PACMAN_REPO_FILE=$(mktemp)
    pacman -Slq | sort -u >"$PACMAN_REPO_FILE"
  }
  printf '%s\n' "$PACMAN_REPO_FILE"
}

get_conflicting_packages() {
  case "$1" in
  tealdeer) printf '%s\n' "tldr" ;;
  openai-codex-bin) printf '%s\n' "openai-codex-autoup-bin" ;;
  *) return 1 ;;
  esac
}

remove_conflicting_packages() {
  pkg_file="$1"
  packages_to_install=$(read_packages "$pkg_file")
  [ -n "$packages_to_install" ] || return 0

  has_sudo_access || {
    log_info "Skipping conflict removal (no sudo access)"
    return 0
  }

  for pkg in $packages_to_install; do
    conflicting=$(get_conflicting_packages "$pkg") || continue
    if pacman -Q "$conflicting" >/dev/null 2>&1; then
      log_info "Removing conflicting package: $conflicting (conflicts with $pkg)"
      sudo pacman -R --noconfirm "$conflicting" 2>/dev/null || true
      PACMAN_INSTALLED_FILE=""
    fi
  done
}

install_pacman_packages() {
  pkg_file="${PKGS_ARCH_PACMAN_FILE}"
  [ -f "$pkg_file" ] || return 0

  pkg_list_file=$(make_list_file "$pkg_file") || return
  installed_list_file=$(get_installed_list_file)

  if [ "${DOTFILES_VERIFY_PACKAGES:-0}" = "1" ]; then
    repo_list_file=$(get_pacman_repo_list_file)
    missing=$(comm -23 "$pkg_list_file" "$repo_list_file")
    [ -n "$missing" ] && {
      printf '%s\n' "$missing" >&2
      log_error "Pacman package(s) not found in repos"
    }
  fi

  packages_to_install=$(comm -23 "$pkg_list_file" "$installed_list_file")

  if [ -n "$packages_to_install" ]; then
    log_info "Installing pacman packages ($(printf '%s\n' "$packages_to_install" | count_lines))"
    if has_sudo_access; then
      sudo pacman -S --needed --noconfirm $packages_to_install
    else
      log_info "Skipping pacman install (no sudo access): $packages_to_install"
    fi
  else
    log_info "No new pacman packages to install"
  fi

  rm -f "$pkg_list_file"
}

install_paru() {
  command -v paru >/dev/null 2>&1 && {
    log_info "paru is already installed"
    return 0
  }

  if pacman -Ss '^paru$' >/dev/null 2>&1 && has_sudo_access; then
    log_info "Installing paru from pacman"
    sudo pacman -S --noconfirm paru
    return 0
  fi

  log_info "Bootstrapping paru from AUR"

  for pkg in git base-devel; do
    pacman -Q "$pkg" >/dev/null 2>&1 && continue
    log_info "Installing ${pkg} for paru bootstrap"
    if has_sudo_access; then
      sudo pacman -S --needed --noconfirm "$pkg"
    else
      log_info "Missing dependency: $pkg (no sudo access)"
      return 0
    fi
  done

  build_dir="${BUILD_DIR}/paru"
  rm -rf "$build_dir"
  git clone "${AUR_BASE_URL}/paru.git" "$build_dir"
  cd "$build_dir"
  makepkg -si --noconfirm
  cd - >/dev/null
  rm -rf "$build_dir"
  log_info "paru installed successfully"
}

install_aur_packages() {
  aur_file="${PKGS_ARCH_AUR_FILE}"
  [ -f "$aur_file" ] || {
    log_info "No AUR packages file found"
    return 0
  }

  aur_list_file=$(make_list_file "$aur_file") || {
    log_info "No AUR packages to install"
    return
  }

  if [ "${DOTFILES_VERIFY_PACKAGES:-0}" = "1" ]; then
    paru -Si $(cat "$aur_list_file") || log_error "AUR package(s) not found"
  fi

  installed_list_file=$(get_installed_list_file)
  packages_to_install=$(comm -23 "$aur_list_file" "$installed_list_file")
  if [ -n "$packages_to_install" ]; then
    log_info "Installing AUR packages ($(printf '%s\n' "$packages_to_install" | count_lines))"
    if [ "${DOTFILES_ARCH_ASSUME_YES:-0}" = "1" ]; then
      paru -S --needed --noconfirm $packages_to_install 2>&1 || {
        log_info "Retrying without --noconfirm for interactive prompts..."
        paru -S --needed $packages_to_install
      }
    else
      paru -S --needed $packages_to_install
    fi
  else
    log_info "No new AUR packages to install"
  fi

  rm -f "$aur_list_file"
}

is_arch_based() {
  [ -f /etc/arch-release ] || [ -f /etc/cachyos-release ]
}

is_arch_from_os_release() {
  [ -f /etc/os-release ] && {
    . /etc/os-release
    [ "${ID:-}" = "arch" ] || [ "${ID_LIKE:-}" = "arch" ]
  }
}

main() {
  check_sudo_access || true

  if is_arch_based || is_arch_from_os_release; then
    remove_conflicting_packages "${PKGS_ARCH_PACMAN_FILE}"
    install_pacman_packages
    install_paru
    install_aur_packages
    log_info "Installation complete"
    return 0
  fi

  log_error "Unsupported Linux distro. Arch-based distros only (ID_LIKE=arch)."
}

main "$@"
