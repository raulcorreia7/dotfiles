#!/bin/sh

set -euo pipefail

# -----------------------------------------------------------------------------
# Load shared configuration
# -----------------------------------------------------------------------------

. "$(dirname "$0")/config.sh"

installed_count=0
failed_count=0
failed_categories=""

check_brew() {
	if ! command -v brew >/dev/null 2>&1; then
		echo "Error: Homebrew is not installed"
		echo "Please install Homebrew from ${BREW_INSTALL_URL}"
		echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
		exit 1
	fi
	echo "Homebrew found: $(brew --version | head -n1)"
}

install_category() {
	category="$1"
	file="$PKGS_MACOS/$category"

	if [ ! -f "$file" ]; then
		echo "Skipping $category: file not found"
		return
	fi

	echo "Installing $category..."

	if brew bundle --file="$file" --no-lock 2>&1; then
		echo "✓ $category installed successfully"
		installed_count=$((installed_count + 1))
	else
		echo "✗ $category installation failed"
		failed_count=$((failed_count + 1))
		if [ -z "$failed_categories" ]; then
			failed_categories="$category"
		else
			failed_categories="$failed_categories, $category"
		fi
	fi
}

main() {
	echo "=== macOS Package Installer ==="
	echo ""

	check_brew
	echo ""

	for category in $CATEGORIES; do
		install_category "$category"
		echo ""
	done

	echo "=== Summary ==="
	echo "Installed: $installed_count"
	echo "Failed: $failed_count"
	if [ "$failed_count" -gt 0 ]; then
		echo "Failed categories: $failed_categories"
	fi
}

main "$@"
