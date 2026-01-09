#!/bin/sh
# Git helpers with explicit confirmation for destructive actions.

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------

dot_gitclean() {
	skip_confirm=0
	gitclean_clean_flags="-fdx"
	gitclean_reset_flags="--hard"

	case "$1" in
	-h | --help)
		printf 'Usage: gitclean [-y|--yes]\nRemove untracked files and hard reset (prompts by default).\n'
		return 0
		;;
	-y | --yes)
		skip_confirm=1
		shift
		;;
	esac

	if [ $# -gt 0 ]; then
		printf 'gitclean: unknown option: %s\n' "$1"
		return 2
	fi

	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		printf 'gitclean: not a git repository\n' >&2
		return 1
	}

	if [ "$skip_confirm" -ne 1 ]; then
		# Destructive operations; require explicit confirmation.
		printf 'gitclean: run "git clean %s" and "git reset %s" in %s? [y/N] ' \
			"$gitclean_clean_flags" "$gitclean_reset_flags" \
			"$(pwd)" >&2
		read -r gitclean_answer || return 1
		case "$gitclean_answer" in
		y | Y | yes | YES) ;;
		*)
			printf 'gitclean: aborted\n' >&2
			return 1
			;;
		esac
	fi

	git clean "$gitclean_clean_flags" || return $?
	git reset "$gitclean_reset_flags"
}
