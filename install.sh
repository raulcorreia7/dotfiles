#!/bin/sh
set -e
# Main install dispatcher - bootstrap config and install packages for detected OS.

DOTFILES_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

log() {
	printf '%s\n' "$*" >&2
}

detect_os() {
	case "$(uname -s)" in
	Darwin)
		echo "macos"
		;;
	Linux)
		if [ -f /etc/arch-release ] || [ -f /etc/cachyos-release ]; then
			echo "arch"
		else
			echo "linux"
		fi
		;;
	MINGW* | MSYS* | CYGWIN*)
		echo "windows"
		;;
	*)
		log "Unknown OS: $(uname -s)"
		exit 1
		;;
	esac
}

main() {
	os=$(detect_os)
	log "detected OS: $os"

	log "running bootstrap..."
	. "$DOTFILES_DIR/scripts/bootstrap.sh"

	case "$os" in
	macos)
		if [ -x "$DOTFILES_DIR/scripts/install-macos.sh" ]; then
			log "installing macOS packages..."
			. "$DOTFILES_DIR/scripts/install-macos.sh"
		else
			log "error: scripts/install-macos.sh not found or not executable"
			exit 1
		fi
		;;
	arch)
		if [ -x "$DOTFILES_DIR/scripts/install-arch.sh" ]; then
			log "installing Arch packages..."
			. "$DOTFILES_DIR/scripts/install-arch.sh"
		else
			log "error: scripts/install-arch.sh not found or not executable"
			exit 1
		fi
		;;
	windows)
		log "Windows detected: please run 'pwsh -ExecutionPolicy Bypass -File scripts/install-windows.ps1'"
		log "or: 'powershell.exe -ExecutionPolicy Bypass -File scripts/install-windows.ps1'"
		exit 0
		;;
	linux)
		log "Linux detected but not Arch/CachyOS - package management not yet configured"
		log "please add your distro support or install packages manually"
		exit 1
		;;
	*)
		log "error: unsupported OS: $os"
		exit 1
		;;
	esac

	log "installation complete!"
	log "reload your shell: source ~/.zshrc or source ~/.bashrc"
}

main "$@"
