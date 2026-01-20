#!/bin/sh
# Arch Linux system maintenance helpers.

# -----------------------------------------------------------------------------
# Package Updates
# -----------------------------------------------------------------------------

arch_pacmanupdate() {
	case "$1" in
	-h | --help)
		printf 'Usage: arch_pacmanupdate\nUpdate system packages via pacman.\n'
		return 0
		;;
	esac
	sudo pacman -Syu --noconfirm
}

arch_paruupdate() {
	case "$1" in
	-h | --help)
		printf 'Usage: arch_paruupdate\nUpdate AUR packages via paru.\n'
		return 0
		;;
	esac
	paru -Syu --noconfirm
}

arch_sysupdate() {
	case "$1" in
	-h | --help)
		printf 'Usage: arch_sysupdate\nUpdate system and AUR packages.\n'
		return 0
		;;
	esac
	arch_pacmanupdate && arch_paruupdate
}

# -----------------------------------------------------------------------------
# System Maintenance
# -----------------------------------------------------------------------------

arch_sysupdatefull() {
	case "$1" in
	-h | --help)
		printf 'Usage: arch_sysupdatefull\nInteractive system maintenance workflow.\n'
		return 0
		;;
	esac

	set -e

	printf '%s\n' '=== Arch Linux System Maintenance ==='

	orphans=$(pacman -Qdtq)
	if [ -n "$orphans" ]; then
		printf '%s\n' 'Orphan packages found:'
		printf '%s\n' "$orphans"
		printf '%s' 'Remove orphans? [y/N] '
		read -r response
		case "$response" in
		[yY][eE][sS] | [yY])
			pacman -Qdtq | sudo pacman -Rns -
			;;
		esac
	fi

	if pacman -Qk 2>&1 | grep -qE '[1-9][0-9]* missing files$'; then
		printf '%s\n' 'Broken packages detected. Aborting.'
		exit 1
	fi

	printf '%s\n' "Package cache size: $(du -sh /var/cache/pacman/pkg/ | cut -f1)"
	printf '%s' 'Clean package cache? [y/N] '
	read -r response
	case "$response" in
	[yY][eE][sS] | [yY])
		sudo pacman -Sc
		;;
	esac

	sudo pacman -Sy
	arch_pacmanupdate && arch_paruupdate

	printf '%s\n' '=== System maintenance complete ==='
}
