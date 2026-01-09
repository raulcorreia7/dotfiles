#!/bin/sh
# Small convenience helpers.

# -----------------------------------------------------------------------------
# Core helpers
# -----------------------------------------------------------------------------

__dot_has() {
	command -v "$1" >/dev/null 2>&1
}

__dot_pick() {
	for cmd in "$@"; do
		if __dot_has "$cmd"; then
			printf '%s\n' "$cmd"
			return 0
		fi
	done
	return 1
}

# -----------------------------------------------------------------------------
# Doctor
# -----------------------------------------------------------------------------

__dot_doctor_line() {
	label=$1
	shift
	cmd=$(__dot_pick "$@")
	if [ -n "$cmd" ]; then
		alts=""
		for alt in "$@"; do
			[ "$alt" = "$cmd" ] && continue
			if __dot_has "$alt"; then
				alts="${alts}${alts:+ }$alt"
			fi
		done
		if [ -n "$alts" ]; then
			printf '%s: ok (%s; alt: %s)\n' "$label" "$cmd" "$alts"
		else
			printf '%s: ok (%s)\n' "$label" "$cmd"
		fi
	else
		printf '%s: missing (try: %s)\n' "$label" "$*"
	fi
}

dot_doctor() {
	# Prefer modern tools but report fallbacks.
	__dot_doctor_line "fzf" fzf
	__dot_doctor_line "git" git
	__dot_doctor_line "sed" gsed sed
	__dot_doctor_line "rg" rg
	__dot_doctor_line "fd" fd
	__dot_doctor_line "grep" grep
	__dot_doctor_line "cat" cat
	__dot_doctor_line "bat" bat
	__dot_doctor_line "exa" eza exa
}

# -----------------------------------------------------------------------------
# Editor helpers
# -----------------------------------------------------------------------------

dot_nvimcfg() {
	case "$1" in
	-h | --help)
		printf 'Usage: nvimcfg\nOpen ~/.config/nvim.\n'
		return 0
		;;
	esac
	# Open the Neovim config in the preferred editor.
	editor="${EDITOR:-nvim}"
	nvimcfg_path="$HOME/.config/nvim"
	"$editor" "$nvimcfg_path"
}
