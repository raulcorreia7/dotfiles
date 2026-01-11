#!/bin/sh
# shellcheck disable=SC3043,SC2034
# ==============================================================================
# FZF Snacks (fzfs)
# ==============================================================================
# Snacks for Fuzzy finding your way through your terminal
# Features: live content search, project jumping, and git-integrated tools.
# ==============================================================================

# ==============================================================================
# SECTION 1: UI CONSTANTS & STYLE
# ==============================================================================

# ANSI Color Palette
CLR_RESET='\033[0m'
CLR_BOLD='\033[1m'
CLR_RED='\033[31m'
CLR_GREEN='\033[32m'
CLR_YELLOW='\033[33m'
CLR_CYAN='\033[36m'
CLR_MAGENTA='\033[35m'
CLR_BOLD_CYAN='\033[1;36m'
CLR_BOLD_YELLOW='\033[1;33m'

BIND_EDIT='ctrl-e'
BIND_CD='ctrl-o'
BIND_PREVIEW='ctrl-p'
BIND_YANK='ctrl-y'
BIND_HIDDEN='ctrl-h'

# ==============================================================================
# SECTION 2: CONFIGURATION DEFAULTS
# ==============================================================================

FZFS_BIN="${FZF_BIN:-${FZF_CMD:-fzf}}"
# Default options for the FZF UI. We ensure it has margin and padding of 1.
# If the existing FZFS_OPTS_UI looks broken (e.g. from a previous version), we reset it.
case "${FZFS_OPTS_UI:-}" in
*margin=0* | *padding=0* | ---* | "") FZFS_OPTS_UI="--height=80% --layout=reverse --info=inline-right --border=rounded --margin=1 --padding=1 --pointer=▶ --marker=✓" ;;
esac
: "${FZFS_OPTS_PREVIEW:=right:60%:wrap:nohidden}"
: "${FZFS_PROJECT_ROOTS:=$HOME/personal}"
: "${FZFS_CACHE_DIR:=${XDG_CACHE_HOME:-$HOME/.cache}/fzfs}"

# Files and patterns to hide from fuzzy search.
: "${FZFS_EXCLUDES:=.git node_modules .venv venv .cache .npm .yarn .pnpm-store dist build target .ssh .gnupg .direnv .terraform .idea .vscode .DS_Store coverage *.pem *.key *.crt *.pub *.asc *.p12 *.pfx}"

# ==============================================================================
# SECTION 3: THE TOOLBELT (Static Resolution)
# ==============================================================================

# We detect tools once at startup to keep the script feeling "Instantaneous".
_fzfs_has() { command -v "$1" >/dev/null 2>&1; }

if _fzfs_has eza; then TOOL_LS="eza"; elif _fzfs_has exa; then TOOL_LS="exa"; else TOOL_LS="ls"; fi
if _fzfs_has rg; then TOOL_GREP="rg"; else TOOL_GREP="grep"; fi
if _fzfs_has bat; then TOOL_CAT="bat"; else TOOL_CAT="cat"; fi
if _fzfs_has fd; then HAS_FD=1; else HAS_FD=0; fi
if _fzfs_has delta; then HAS_DELTA=1; else HAS_DELTA=0; fi

# ==============================================================================
# SECTION 4: UTILITY HELPERS
# ==============================================================================

# Exit with a red error message.
_fzfs_die() {
	printf "%bError:%b %s\n" "${CLR_RED}" "${CLR_RESET}" "$1" >&2
	exit "${2:-1}"
}

# Safely quote strings for use inside shell commands.
_fzfs_quote() {
	printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\''/g")"
}

# Resolve paths, expanding relative paths and handling '~'.
_fzfs_expand_path() {
	case "$1" in
	~/*) printf %s "$HOME/${1#~/}" ;;
	~) printf %s "$HOME" ;;
	*)
		if _fzfs_has realpath; then
			realpath "$1"
		else
			# Fallback for systems without realpath
			printf %s "$1"
		fi
		;;
	esac
}

# Copy text to clipboard (works on macOS and Linux).
_fzfs_copy() {
	if _fzfs_has pbcopy; then
		printf '%s' "$1" | pbcopy
	elif _fzfs_has xclip; then
		printf '%s' "$1" | xclip -selection clipboard
	elif _fzfs_has xsel; then printf '%s' "$1" | xsel --clipboard --input; fi
}

# Find the real path of this script for callbacks.
_fzfs_resolve_self() {
	[ -n "${FZFS_SCRIPT_PATH:-}" ] && {
		printf '%s' "$FZFS_SCRIPT_PATH"
		return
	}
	# shellcheck disable=SC3043
	local src=""
	if [ -n "${BASH_SOURCE:-}" ]; then
		src="${BASH_SOURCE}"
	elif [ -n "${ZSH_VERSION:-}" ]; then
		eval 'src="${(%):-%x}"'
	else src="$0"; fi
	if _fzfs_has readlink && readlink -f "$src" >/dev/null 2>&1; then
		readlink -f "$src"
	else
		local dir
		dir="$(cd "$(dirname "$src")" 2>/dev/null && pwd)"
		printf '%s/%s' "$dir" "$(basename "$src")"
	fi
}

# Cache script path globally.
FZFS_SCRIPT_PATH="$(_fzfs_resolve_self)"
export FZFS_SCRIPT_PATH

# ==============================================================================
# SECTION 5: DATA GENERATORS (The Sources)
# ==============================================================================

# Mode: Files and Directories
_fzfs_gen_files() {
	local type="$1" base
	base="$(_fzfs_expand_path "$2")"
	local show_hidden="${3:-1}"

	if [ "$HAS_FD" -eq 1 ]; then
		local opts="--follow --color=never"
		[ "$show_hidden" -eq 1 ] && opts="$opts --hidden"
		for ex in $FZFS_EXCLUDES; do opts="$opts --exclude $ex"; done

		case "$type" in
		f) opts="$opts --type f" ;;
		d) opts="$opts --type d" ;;
		esac
		[ "$type" = "recent" ] && opts="$opts --changed-within 24h --type f"

		if [ "$base" = "." ] || [ "$base" = "./" ]; then
			# shellcheck disable=SC2086
			fd $opts --strip-cwd-prefix
		else
			# shellcheck disable=SC2086
			fd $opts . "$base"
		fi
	else
		local fopts=""
		[ "$show_hidden" -eq 1 ] && fopts="-name .*"
		[ "$type" = "f" ] && fopts="$fopts -type f"
		[ "$type" = "d" ] && fopts="$fopts -type d"
		[ "$type" = "recent" ] && fopts="$fopts -type f -mtime -1"
		# shellcheck disable=SC2086
		find "$base" $fopts 2>/dev/null
	fi
}

# Mode: Live Content Search (Ripgrep)
_fzfs_gen_search() {
	local base
	base="$(_fzfs_expand_path "$1")"
	local query="$2"

	if [ "$TOOL_GREP" = "rg" ]; then
		# Faster: use -uu for unrestricted, -S for smart case, -N for no filename prefix
		rg -uu -n --no-heading --color=always -S --glob '!.git' -- "$query" "$base" 2>/dev/null
	else
		grep -rIn "$query" "$base" 2>/dev/null
	fi
}

# Mode: Git Status / Tracked
_fzfs_gen_git() {
	git rev-parse --git-dir >/dev/null 2>&1 || _fzfs_die "Not a git repository."
	case "$1" in
	tracked) git ls-files ;;
	status) git ls-files -m -o --exclude-standard ;;
	staged) git diff --name-only --cached ;;
	dirs) git ls-files -co --exclude-standard | awk -F/ 'BEGIN {OFS="/"} NF>1 {NF--; dir=$0; if (!seen[dir]++) { print dir "/"; fflush() }}' ;;
	*) git ls-files -co --exclude-standard ;;
	esac
}

# Mode: Git Commits
_fzfs_gen_commits() {
	git rev-parse --git-dir >/dev/null 2>&1 || _fzfs_die "Not a git repository."
	git log --color=always --format="%C(yellow)%h%Creset %C(magenta)%ad%Creset %C(cyan)%an%Creset %s" --date=short
}

# Mode: Git Branches
_fzfs_gen_branches() {
	git rev-parse --git-dir >/dev/null 2>&1 || _fzfs_die "Not a git repository."
	local fmt="%(refname:short)"
	case "$1" in
	remote) git for-each-ref --format="$fmt" refs/remotes | "$TOOL_GREP" -v '/HEAD$' ;;
	*) git for-each-ref --format="$fmt" refs/heads ;;
	esac
}

# Mode: Projects (Cached)
_fzfs_gen_projects() {
	local roots="${1:-.}"
	local dirs=""

	for r in $roots; do
		r="$(_fzfs_expand_path "$r")"
		if [ -d "$r" ]; then
			if [ -z "$dirs" ]; then
				dirs="$r"
			else
				dirs="$dirs $r"
			fi
		fi
	done

	[ -z "$dirs" ] && return

	if [ "$HAS_FD" -eq 1 ]; then
		fd --hidden --no-ignore --type d --glob .git "$dirs" -x dirname
	else
		for d in $dirs; do
			find "$d" -type d -name .git -exec dirname {} \;
		done
	fi
}

# ==============================================================================
# SECTION 6: CALLBACK HANDLERS (Preview Engine)
# ==============================================================================

# Previews for files, directories, and archives.
_fzfs_callback_preview() {
	local path
	path="$(_fzfs_expand_path "${1%%:*}")"

	if [ -d "$path" ]; then
		if [ "$TOOL_LS" = "ls" ]; then
			ls -lah "$path"
		else $TOOL_LS -lah --color=always --icons --group-directories-first --git "$path"; fi
		return
	fi

	if [ -f "$path" ]; then
		# Preview archives without extraction.
		case "$path" in
		*.tar.gz | *.tgz | *.tar.bz2 | *.tar.xz | *.tar) _fzfs_has tar && {
			tar -tf "$path" | head -n 100
			return
		} ;;
		*.zip) _fzfs_has unzip && {
			unzip -l "$path" | head -n 100
			return
		} ;;
		*.7z) _fzfs_has 7z && {
			7z l "$path" | head -n 100
			return
		} ;;
		*.rar) _fzfs_has unrar && {
			unrar l "$path" | head -n 100
			return
		} ;;
		esac

		# Binary check to prevent terminal corruption.
		if _fzfs_has file && file --mime "$path" | grep -q "binary"; then
			printf "%bBinary file detected (Preview disabled)%b" "${CLR_YELLOW}" "${CLR_RESET}"
			return
		fi

		if [ "$TOOL_CAT" = "bat" ]; then
			bat --style=numbers --color=always --line-range :200 "$path"
		else
			head -n 100 "$path"
		fi
	fi
}

# Preview for Git Commits.
_fzfs_callback_git_preview() {
	local hash
	hash=$(printf '%s' "$1" | awk '{print $1}')
	printf "%bCommit:%b %s\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}" "$hash"
	local diff_tool="cat"
	if [ "$HAS_DELTA" -eq 1 ]; then
		diff_tool="delta --width $(tput cols)"
	elif [ "$TOOL_CAT" = "bat" ]; then diff_tool="bat -pl diff"; fi

	git log -1 --color=always --date=short --format="%C(yellow)%h%Creset %C(magenta)%ad%Creset %C(cyan)%an%Creset%n%n%C(auto)%s%Creset%n" "$hash" 2>/dev/null
	printf "\n%bChanges:%b\n" "${CLR_BOLD_YELLOW}" "${CLR_RESET}"
	git show --color=always --stat --patch "$hash" | eval "$diff_tool" | head -n 150
}

# Preview for Git Branches.
_fzfs_callback_branch_preview() {
	local ref
	ref=$(printf '%s' "$1" | awk '{print $1}')
	local base="main"
	git show-ref --verify --quiet refs/heads/master && base="master"
	printf "%bBranch:%b %s\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}" "$ref"

	local ab
	ab=$(git rev-list --left-right --count "$base...$ref" 2>/dev/null)
	if [ -n "$ab" ]; then
		printf "%bDiff vs %s:%b Ahead %s, Behind %s\n" "${CLR_BOLD}" "$base" "${CLR_RESET}" "${ab#*\t}" "${ab%%\t*}"
	fi

	printf "\n%bBranch Graph (tree visualization):%b\n" "${CLR_BOLD_YELLOW}" "${CLR_RESET}"
	git log --oneline --abbrev-commit --graph --decorate --color "$base" "$ref" -20 2>/dev/null | cut -c1-120

	printf "\n%bLatest Commit:%b\n" "${CLR_BOLD_YELLOW}" "${CLR_RESET}"
	git log -1 --color=always --date=short --format="%C(yellow)%h%Creset %C(magenta)%ad%Creset %C(cyan)%an%Creset %s" "$ref" 2>/dev/null

	printf "\n%bChanges Overview:%b\n" "${CLR_BOLD_YELLOW}" "${CLR_RESET}"
	git diff --stat --color=always "$base...$ref" 2>/dev/null | head -n 10
}

# ==============================================================================
# SECTION 7: INTERACTIVE UI (The Controllers)
# ==============================================================================

# Unified FZF loop for most modes.
_fzfs_ui_search() {
	[ -n "${ZSH_VERSION:-}" ] && setopt localoptions shwordsplit
	local mode="$1" base="$2" edit="$3" self_q
	self_q="$(_fzfs_quote "$FZFS_SCRIPT_PATH")"
	local src_cmd="" preview_cmd="sh $self_q --internal-preview {}"
	local fzf_mode_opts="--multi"
	local show_hidden="${FZFS_SHOW_HIDDEN:-1}"

	case "$mode" in
	git_*) src_cmd="sh $self_q --internal-gen-git ${mode#git_}" ;;
	projects) src_cmd="sh $self_q --internal-gen-projects $(_fzfs_quote "$base")" ;;
	commits)
		src_cmd="sh $self_q --internal-gen-commits"
		preview_cmd="sh $self_q --internal-git-preview {}"
		;;
	recent) src_cmd="sh $self_q --internal-gen-files recent $(_fzfs_quote "$base") $show_hidden" ;;
	search)
		fzf_mode_opts="$fzf_mode_opts --disabled"
		src_cmd="sh $self_q --internal-gen-search $(_fzfs_quote "$base") ''"
		;;
	*) src_cmd="sh $self_q --internal-gen-files $mode $(_fzfs_quote "$base") $show_hidden" ;;
	esac

	local binds="${BIND_YANK}:execute-silent(sh $self_q --internal-copy {}),${BIND_PREVIEW}:toggle-preview,alt-up:preview-up,alt-down:preview-down"
	local b_edit="${BIND_EDIT}:become(${EDITOR:-vi} {+})"

	case "$mode" in
	f | d | a | recent)
		# shellcheck disable=SC2086,SC2193
		binds="$binds,${BIND_HIDDEN}:reload(sh $self_q --internal-gen-files $mode $(_fzfs_quote "$base") \$( [ \"$show_hidden\" = 1 ] && echo 0 || echo 1 ))+change-prompt($([ \"$show_hidden\" = 1 ] && echo 'Vis> ' || echo 'All> '))+execute-silent( [ \"$show_hidden\" = 1 ] && export FZFS_SHOW_HIDDEN=0 || export FZFS_SHOW_HIDDEN=1 )"
		;;
	esac

	if [ "$mode" = "search" ]; then
		# For search mode, we use {1} for file and {2} for line. become() replaces process.
		b_edit="${BIND_EDIT}:become(${EDITOR:-vi} {1} +{2})"
		# Use sleep 0.1 to debounce reload. Ensure query {q} is not empty to avoid rg errors.
		binds="$binds,change:reload:sleep 0.1; [ -n {q} ] && sh $self_q --internal-gen-search $(_fzfs_quote "$base") {q} || true"
	fi

	binds="$binds,$b_edit"

	local result
	# shellcheck disable=SC2086
	result=$(eval "$src_cmd" | "$FZFS_BIN" --ansi --no-sort --header "fzfs: Enter(Select) C-e(Edit) C-o(Cd) C-p(Preview) C-y(Copy) C-h(Hidden)" $FZFS_OPTS_UI $fzf_mode_opts --preview "$preview_cmd" --preview-window "$FZFS_OPTS_PREVIEW" --bind "$binds" --expect=$BIND_CD) || return 1

	local key
	key="$(printf '%s\n' "$result" | head -n1)"
	local sel
	sel="$(printf '%s\n' "$result" | tail -n +2)"
	[ -n "$sel" ] || return 0

	if [ "$mode" = "search" ]; then
		# Extract filename from "file:line:col:content" or "file:line:content"
		# Handling multiple lines from multi-select
		sel=$(printf '%s\n' "$sel" | cut -d: -f1 | sort -u)
	elif [ "$mode" = "commits" ]; then
		# Extract hash from commit line
		sel=$(printf '%s\n' "$sel" | awk '{print $1}')
	fi

	if [ "$key" = "$BIND_CD" ]; then
		# Use first selection for CD
		local first_sel
		first_sel=$(printf '%s\n' "$sel" | head -n1)
		if [ -d "$first_sel" ]; then
			cd "$first_sel" || return 1
			return 0
		fi
		# If it was a file, switch to edit mode
		edit=1
	fi

	if [ "$edit" -eq 1 ]; then
		# Use a while loop to handle filenames with spaces correctly when passing to editor
		printf '%s\n' "$sel" | xargs -I {} "${EDITOR:-vi}" "{}"
	elif [ -t 1 ] && printf '%s\n' "$sel" | head -n1 | xargs -I {} [ -d "{}" ] && [ "$mode" != "projects" ]; then
		local d
		d=$(printf '%s\n' "$sel" | head -n1)
		cd "$d" || return 1
	else
		printf '%s\n' "$sel"
	fi
}

# Specialized UI for Branch switching.
_fzfs_ui_branch() {
	[ -n "${ZSH_VERSION:-}" ] && setopt localoptions shwordsplit
	local self_q
	self_q="$(_fzfs_quote "$FZFS_SCRIPT_PATH")"
	local c_loc="sh $self_q --internal-gen-branches local"
	local c_rem="sh $self_q --internal-gen-branches remote"
	local c_fet="git fetch --all --prune >/dev/null 2>&1"
	local binds="ctrl-l:change-prompt(Local> )+reload($c_loc),ctrl-r:change-prompt(Remote> )+reload($c_rem),ctrl-f:execute-silent($c_fet)+reload($c_loc),alt-up:preview-up,alt-down:preview-down"

	local result
	# shellcheck disable=SC2086
	result="$(eval "$c_loc" | "$FZFS_BIN" --ansi --header "Branches: C-l(Local) C-r(Remote) C-f(Fetch)" $FZFS_OPTS_UI --prompt "Local> " --preview "sh $self_q --internal-branch-preview {}" --preview-window "$FZFS_OPTS_PREVIEW" --bind "$binds")" || return 1
	local sel
	sel="$(printf '%s\n' "$result" | head -n1 | awk '{print $1}')"
	[ -n "$sel" ] && git checkout "$sel"
}

# ==============================================================================
# SECTION 8: DIAGNOSTICS & HELP UI
# ==============================================================================

_fzfs_help() {
	printf "\n"
	printf "%b███████ ███████ ███████ ███████%b\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}"
	printf "%b██         ███  ██      ██     %b\n" "${CLR_CYAN}" "${CLR_RESET}"
	printf "%b█████     ███   █████   ███████%b\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}"
	printf "%b██       ███    ██           ██%b\n" "${CLR_CYAN}" "${CLR_RESET}"
	printf "%b██      ███████ ██      ███████%b\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}"
	printf "\n%b        fuzzy finder snacks%b\n\n" "${CLR_BOLD}" "${CLR_RESET}"
	cat <<EOF
Usage: fzfs [MODE] [PATH]

MODES:
  -a,  --all        Files and directories (default)
  -f,  --files      Files only
  -d,  --dirs       Directories
  -s,  --search      Live file content search
  -g,  --git        Git tracked files
  -gs, --status    Git status
  -gst, --staged   Git staged files
  -gd, --git-dirs  Git directories
  -gb, --branch    Git branches
  -gc, --commits   Git commits
  -gp, --projects  Git projects

KEYS:
  Enter             Select
  ctrl-e            Edit file(s)
  ctrl-o            cd to directory
  ctrl-p            Toggle preview
  ctrl-y            Copy path
  ctrl-h            Toggle hidden files
EOF
}

_fzfs_doctor() {
	printf "%bFZFS Doctor - Diagnostics%b\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}"
	printf "  Script: %s\n\n" "$FZFS_SCRIPT_PATH"

	printf "  %bCore Dependencies:%b\n" "${CLR_BOLD}" "${CLR_RESET}"
	if _fzfs_has "$FZFS_BIN"; then
		local v
		v=$("$FZFS_BIN" --version | awk '{print $1}')
		printf "    %-18s : %b%s (v%s)%b\n" "FZF Binary" "${CLR_GREEN}" "$FZFS_BIN" "$v" "${CLR_RESET}"
	else
		printf "    %-18s : %b%s (missing)%b\n" "FZF Binary" "${CLR_RED}" "$FZFS_BIN" "${CLR_RESET}"
	fi

	printf "\n  %bActive Tooling (with fallbacks):%b\n" "${CLR_BOLD}" "${CLR_RESET}"

	printf "    %-18s : " "File Finder"
	if [ "$HAS_FD" -eq 1 ]; then
		local v
		v=$(fd --version 2>/dev/null | awk '{print $2}')
		printf "%bfd (v%s)%b\n" "${CLR_GREEN}" "$v" "${CLR_RESET}"
	else
		printf "%bfind (native fallback)%b\n" "${CLR_YELLOW}" "${CLR_RESET}"
	fi

	printf "    %-18s : " "Content Search"
	if [ "$TOOL_GREP" = "rg" ]; then
		local v
		v=$(rg --version 2>/dev/null | head -n1 | awk '{print $2}')
		printf "%brg (v%s)%b\n" "${CLR_GREEN}" "$v" "${CLR_RESET}"
	else
		printf "%bgrep (native fallback)%b\n" "${CLR_YELLOW}" "${CLR_RESET}"
	fi

	printf "    %-18s : " "Directory Listing"
	if [ "$TOOL_LS" = "eza" ]; then
		local v
		v=$(eza --version 2>/dev/null | awk '{print $2}')
		printf "%beza (v%s)%b\n" "${CLR_GREEN}" "$v" "${CLR_RESET}"
	elif [ "$TOOL_LS" = "exa" ]; then
		printf "%bexa (installed)%b\n" "${CLR_GREEN}" "${CLR_RESET}"
	else
		printf "%bls (native fallback)%b\n" "${CLR_YELLOW}" "${CLR_RESET}"
	fi

	printf "    %-18s : " "File Preview"
	if [ "$TOOL_CAT" = "bat" ]; then
		local v
		v=$(bat --version 2>/dev/null | awk '{print $2}')
		printf "%bbat (v%s)%b\n" "${CLR_GREEN}" "$v" "${CLR_RESET}"
	else
		printf "%bcat (native fallback)%b\n" "${CLR_YELLOW}" "${CLR_RESET}"
	fi

	printf "    %-18s : " "Git Diff Viewer"
	if [ "$HAS_DELTA" -eq 1 ]; then
		local v
		v=$(delta --version 2>/dev/null | awk '{print $2}')
		printf "%bdelta (v%s)%b\n" "${CLR_GREEN}" "$v" "${CLR_RESET}"
	else
		if [ "$TOOL_CAT" = "bat" ]; then
			printf "%bbat (as diff viewer)%b\n" "${CLR_GREEN}" "${CLR_RESET}"
		else
			printf "%bcat (native fallback)%b\n" "${CLR_YELLOW}" "${CLR_RESET}"
		fi
	fi

	printf "\n  %bUtilities:%b\n" "${CLR_BOLD}" "${CLR_RESET}"

	_fzfs_status() {
		if _fzfs_has "$1"; then
			printf "%b%s%b " "${CLR_GREEN}" "$1" "${CLR_RESET}"
		else
			printf "%b%s (missing)%b " "${CLR_RED}" "$1" "${CLR_RESET}"
		fi
	}

	_fzfs_binary_status() {
		if _fzfs_has file; then
			printf "%bfile (ok)%b\n" "${CLR_GREEN}" "${CLR_RESET}"
		else
			printf "%bfile (missing)%b\n" "${CLR_RED}" "${CLR_RESET}"
		fi
	}

	_fzfs_clipboard_status() {
		if _fzfs_has pbcopy; then
			printf "%bpbcopy (macOS)%b\n" "${CLR_GREEN}" "${CLR_RESET}"
		elif _fzfs_has xclip; then
			printf "%bxclip (Linux)%b\n" "${CLR_GREEN}" "${CLR_RESET}"
		elif _fzfs_has xsel; then
			printf "%bxsel (Linux)%b\n" "${CLR_GREEN}" "${CLR_RESET}"
		else
			printf "%bclipboard: none (missing)%b\n" "${CLR_RED}" "${CLR_RESET}"
		fi
	}

	printf "    %-18s : " "Binary Detection"
	_fzfs_binary_status

	printf "    %-18s : " "Clipboard"
	_fzfs_clipboard_status

	printf "    %-18s : " "Archive Support"
	_fzfs_status tar
	_fzfs_status unzip
	_fzfs_status 7z
	_fzfs_status unrar
	printf "\n"

	printf "  %bConfiguration:%b\n" "${CLR_BOLD}" "${CLR_RESET}"
	printf "    %-18s : %s\n" "Project Roots" "$FZFS_PROJECT_ROOTS"
	printf "    %-18s : %s\n" "Cache Directory" "$FZFS_CACHE_DIR"
	printf "    %-18s : %d items\n" "Excluded Patterns" "$(printf '%s' "$FZFS_EXCLUDES" | wc -w | tr -d ' ')"
}

# ==============================================================================
# SECTION 9: MAIN DISPATCHER
# ==============================================================================

fzfs() {
	[ -n "${ZSH_VERSION:-}" ] && setopt localoptions shwordsplit
	local mode="a" base="." edit=0

	# Parse command line arguments.
	while [ "$#" -gt 0 ]; do
		case "$1" in
		# External Modes
		-f | --files) mode="f" ;;
		-d | --dirs) mode="d" ;;
		-a | --all) mode="a" ;;
		-s | --search) mode="search" ;;
		-g | --git) mode="git_tracked" ;;
		-gd | --git-dirs) mode="git_dir" ;;
		-gf | --git-all) mode="git_all" ;;
		-gs | --status) mode="git_status" ;;
		-gst | --staged) mode="git_staged" ;;
		-mr | --recent) mode="recent" ;;
		-gb | --branch) mode="branch" ;;
		-gc | --commits) mode="commits" ;;
		-gp | --projects) mode="projects" ;;
		-e | --edit) edit=1 ;;
		--check | --doctor) mode="check" ;;
		-h | --help)
			_fzfs_help
			return 0
			;;

		# Internal callback logic
		--internal-gen-files)
			_fzfs_gen_files "$2" "$3"
			return 0
			;;
		--internal-gen-search)
			_fzfs_gen_search "$2" "$3"
			return 0
			;;
		--internal-gen-git)
			if [ "$2" = "dir" ]; then _fzfs_gen_git dirs; else _fzfs_gen_git "$2"; fi
			return 0
			;;
		--internal-gen-branches)
			_fzfs_gen_branches "$2"
			return 0
			;;
		--internal-gen-commits)
			_fzfs_gen_commits
			return 0
			;;
		--internal-gen-projects)
			_fzfs_gen_projects "$2"
			return 0
			;;
		--internal-preview)
			_fzfs_callback_preview "$2"
			return 0
			;;
		--internal-git-preview)
			_fzfs_callback_git_preview "$2"
			return 0
			;;
		--internal-branch-preview)
			_fzfs_callback_branch_preview "$2"
			return 0
			;;
		--internal-copy)
			_fzfs_copy "$2"
			return 0
			;;

		--)
			shift
			break
			;;
		-*) _fzfs_die "Unknown option: $1" ;;
		*) base="$1" ;;
		esac
		shift
	done

	# 1. Dispatch Diagnostics
	[ "$mode" = "check" ] && {
		_fzfs_doctor
		return 0
	}

	# 3. Start the Interactive UI
	if [ "$mode" = "branch" ]; then
		_fzfs_ui_branch
	else
		_fzfs_ui_search "$mode" "$base" "$edit"
	fi
}

# Execution Guard: Run fzfs if not being sourced.
(return 0 2>/dev/null) || fzfs "$@"
