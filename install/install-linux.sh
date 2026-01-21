#!/bin/sh
set -eu

# -----------------------------------------------------------------------------
# Load shared configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
. "$REPO_DIR/install/config.sh"

error() {
	printf 'Error: %s\n' "$1" >&2
	exit 1
}

info() {
	printf '==> %s\n' "$1"
}

check_sudo() {
	if ! command -v sudo >/dev/null 2>&1; then
		error 'sudo is required but not found'
	fi
}

read_packages() {
	if [ -f "$1" ]; then
		grep -v '^[[:space:]]*$' "$1" | grep -v '^#' || true
	fi
}

install_pacman_packages() {
	local category="$1"
	local pkg_file="${PKGS_ARCH}/${category}"

	if [ ! -f "$pkg_file" ]; then
		return
	fi

	local packages
	packages=$(read_packages "$pkg_file")

	if [ -z "$packages" ]; then
		return
	fi

	info "Installing pacman packages: ${category}"
	sudo pacman -S --needed $packages
}

install_paru() {
	if command -v paru >/dev/null 2>&1; then
		info "paru is already installed"
		return
	fi

	if sudo pacman -Ss '^paru$' >/dev/null 2>&1; then
		info "Installing paru from pacman"
		sudo pacman -S paru
		return
	fi

	info "Bootstrapping paru from AUR"

	for pkg in git base-devel; do
		if ! pacman -Q "$pkg" >/dev/null 2>&1; then
			info "Installing ${pkg} for paru bootstrap"
			sudo pacman -S --needed "$pkg"
		fi
	done

	local build_dir="${BUILD_DIR}/paru"
	rm -rf "$build_dir"
	git clone "${AUR_BASE_URL}/paru.git" "$build_dir"
	cd "$build_dir"
	makepkg -si
	cd - >/dev/null
	rm -rf "$build_dir"

	info "paru installed successfully"
}

install_aur_packages() {
	local aur_file="${PKGS_ARCH}/aur"

	if [ ! -f "$aur_file" ]; then
		info "No AUR packages file found"
		return
	fi

	local packages
	packages=$(read_packages "$aur_file")

	if [ -z "$packages" ]; then
		info "No AUR packages to install"
		return
	fi

	info "Installing AUR packages"
	paru -S --needed $packages
}

main() {
	check_sudo

	if [ -f /etc/arch-release ] || [ -f /etc/cachyos-release ]; then
		info "Installing pacman packages"
		for category in base cli development gui; do
			install_pacman_packages "$category"
		done

		install_paru
		install_aur_packages

		info "Installation complete"
		return 0
	fi

	if [ -f /etc/os-release ]; then
		. /etc/os-release
		if [ "${ID:-}" = "arch" ] || [ "${ID:-}" = "cachyos" ]; then
			info "Installing pacman packages"
			for category in base cli development gui; do
				install_pacman_packages "$category"
			done

			install_paru
			install_aur_packages

			info "Installation complete"
			return 0
		fi
	fi

	error "Unsupported Linux distro. Arch/CachyOS only."
}

main "$@"
