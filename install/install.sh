#!/bin/sh
set -e
# Main install dispatcher - bootstrap config and install packages for detected OS.

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

log() {
	printf '%s\n' "$*" >&2
}

detect_os() {
	case "$(uname -s)" in
	Darwin)
		echo "macos"
		;;
	Linux)
		echo "linux"
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
	. "$SCRIPT_DIR/link.sh"

	case "$os" in
	macos)
		if [ -x "$SCRIPT_DIR/install-macos.sh" ]; then
			log "installing macOS packages..."
			. "$SCRIPT_DIR/install-macos.sh"
		else
			log "error: install/install-macos.sh not found or not executable"
			exit 1
		fi
		;;
	linux)
		if [ -x "$SCRIPT_DIR/install-linux.sh" ]; then
			log "installing Linux packages..."
			. "$SCRIPT_DIR/install-linux.sh"
		else
			log "error: install/install-linux.sh not found or not executable"
			exit 1
		fi
		;;
	windows)
		log "Windows detected: please run 'pwsh -ExecutionPolicy Bypass -File install/install-windows.ps1'"
		log "or: 'powershell.exe -ExecutionPolicy Bypass -File install/install-windows.ps1'"
		exit 0
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
