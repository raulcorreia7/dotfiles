#!/bin/sh
# shellcheck disable=SC3043
# ==============================================================================
# GIT SNACKS (gits)
# ==============================================================================
# Git helpers with explicit confirmation for destructive actions.
# ==============================================================================

# ==============================================================================
# SECTION 1: UI CONSTANTS & STYLE
# ==============================================================================

CLR_RESET='\033[0m'
CLR_BOLD='\033[1m'
CLR_RED='\033[31m'
CLR_GREEN='\033[32m'
CLR_YELLOW='\033[33m'
CLR_CYAN='\033[36m'
CLR_BOLD_CYAN='\033[1;36m'

# ==============================================================================
# SECTION 2: CONFIGURATION DEFAULTS
# ==============================================================================

GITCLEAN_CLEAN_FLAGS="${GITCLEAN_CLEAN_FLAGS:--fdx}"
GITCLEAN_RESET_FLAGS="${GITCLEAN_RESET_FLAGS:---hard}"

# ==============================================================================
# SECTION 3: UTILITY HELPERS
# ==============================================================================

# Exit with a red error message.
_git_die() {
	printf "%bError:%b %s\n" "${CLR_RED}" "${CLR_RESET}" "$1" >&2
	exit "${2:-1}"
}

# Check if inside git repository.
_git_check_repo() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		_git_die "Not a git repository" 1
	}
}

# ==============================================================================
# SECTION 4: GIT COMMANDS
# ==============================================================================

# Clean and reset git repository safely.
_git_clean() {
	local skip_confirm=0

	case "$1" in
	-h | --help)
		_git_help
		return 0
		;;
	-y | --yes)
		skip_confirm=1
		shift
		;;
	esac

	[ $# -gt 0 ] && _git_die "Unknown option: $1" 2

	_git_check_repo

	if [ "$skip_confirm" -eq 0 ]; then
		printf "%bgitclean%b: Run %bgit clean %s%b and %bgit reset %s%b in %b%s%b? [y/N] " \
			"${CLR_BOLD_CYAN}" "${CLR_RESET}" "${CLR_YELLOW}" "$GITCLEAN_CLEAN_FLAGS" "${CLR_RESET}" \
			"${CLR_YELLOW}" "$GITCLEAN_RESET_FLAGS" "${CLR_RESET}" \
			"${CLR_BOLD}" "$(pwd)" "${CLR_RESET}" >&2
		read -r gitclean_answer || return 1
		case "$gitclean_answer" in
		y | Y | yes | YES) ;;
		*)
			_git_die "Aborted" 1
			;;
		esac
	fi

	git clean "$GITCLEAN_CLEAN_FLAGS" || return $?
	git reset "$GITCLEAN_RESET_FLAGS"
}

# ==============================================================================
# SECTION 5: HELP UI
# ==============================================================================

_git_help() {
	printf "\n"
	printf "%b███████ ███████ ███████ ███████%b\n" "${CLR_CYAN}" "${CLR_RESET}"
	printf "%b██         ███  ██      ██     %b\n" "${CLR_CYAN}" "${CLR_RESET}"
	printf "%b█████     ███   █████   ███████%b\n" "${CLR_CYAN}" "${CLR_RESET}"
	printf "%b██       ███    ██           ██%b\n" "${CLR_CYAN}" "${CLR_RESET}"
	printf "%b██      ███████ ██      ███████%b\n" "${CLR_CYAN}" "${CLR_RESET}"
	printf "\n%b        git snacks%b\n\n" "${CLR_BOLD}" "${CLR_RESET}"
	cat <<EOF
Usage: gits [COMMAND] [OPTIONS]

COMMANDS:
  clean              Remove untracked files and hard reset
                    (prompts for confirmation by default)

OPTIONS:
  -y, --yes         Skip confirmation prompt
  -h, --help        Show this help message

EXAMPLES:
  gits clean         # Clean with confirmation
  gits clean -y      # Clean without confirmation

CONFIGURATION:
  GITCLEAN_CLEAN_FLAGS   Flags for git clean (default: -fdx)
  GITCLEAN_RESET_FLAGS   Flags for git reset (default: --hard)
EOF
}

# ==============================================================================
# SECTION 6: MAIN DISPATCHER
# ==============================================================================

gits() {
	[ -n "${ZSH_VERSION:-}" ] && setopt localoptions shwordsplit
	local command=""

	while [ "$#" -gt 0 ]; do
		case "$1" in
		clean) command="clean" ;;
		-h | --help)
			_git_help
			return 0
			;;
		-*) _git_die "Unknown option: $1" 2 ;;
		*) _git_die "Unknown command: $1" 2 ;;
		esac
		shift
	done

	case "$command" in
	clean) _git_clean "$@" ;;
	*) _git_die "No command specified. Use 'gits --help' for usage." 1 ;;
	esac
}

# Execution Guard: Run gits if not being sourced.
(return 0 2>/dev/null) || gits "$@"
