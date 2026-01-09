#!/bin/sh
# shellcheck disable=SC3043
# ==============================================================================
# FZF Snacks (fzfs) - POSIX Compliant
# ==============================================================================
# A high-performance, modern-first fuzzy finder wrapper.
# Features: live content search, project jumping, and git-integrated tools.
# ==============================================================================

# Prevent double-sourcing loop.
if [ "${FZFS_LOADED:-0}" -eq 1 ]; then
    return 0 2>/dev/null || exit 0
fi

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
CLR_BOLD_CYAN='\033[1;36m'
CLR_BOLD_YELLOW='\033[1;33m'

# FZF Interaction Bindings
BIND_PREVIEW='ctrl-/'
BIND_EDIT='ctrl-e'
BIND_YANK='ctrl-y'
BIND_REFRESH='ctrl-r'
BIND_CD='ctrl-o'

# ==============================================================================
# SECTION 2: CONFIGURATION DEFAULTS
# ==============================================================================

FZFS_BIN="${FZF_BIN:-${FZF_CMD:-fzf}}"
FZFS_OPTS_UI="${FZFS_OPTS_UI:---\"height=50% --layout=reverse --info=inline --border --margin=0 --padding=0 --pointer=▶ --marker=✓}" 
FZFS_OPTS_PREVIEW="${FZFS_OPTS_PREVIEW:-right:50%:wrap}"
FZFS_PROJECT_ROOTS="${FZFS_PROJECT_ROOTS:-$HOME/personal}"
FZFS_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/fzfs"

# Files and patterns to hide from fuzzy search.
FZFS_EXCLUDES="${FZFS_EXCLUDES:-.git node_modules .venv venv .cache .npm .yarn .pnpm-store dist build target .ssh .gnupg .direnv .terraform .idea .vscode .DS_Store coverage *.pem *.key *.crt *.pub *.asc *.p12 *.pfx}"

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

# Resolve '~' to actual home directory.
_fzfs_expand_path() {
    case "$1" in
        ~/*) printf '%s/%s' "$HOME" "${1#~/}" ;;
        ~)   printf '%s' "$HOME" ;;
        *)   printf '%s' "$1" ;;
    esac
}

# Copy text to clipboard (works on macOS and Linux).
_fzfs_copy() {
    if _fzfs_has pbcopy; then printf '%s' "$1" | pbcopy
    elif _fzfs_has xclip; then printf '%s' "$1" | xclip -selection clipboard
    elif _fzfs_has xsel; then printf '%s' "$1" | xsel --clipboard --input; fi
}

# Find the real path of this script for callbacks.
_fzfs_resolve_self() {
    [ -n "${FZFS_SCRIPT_PATH:-}" ] && { printf '%s' "$FZFS_SCRIPT_PATH"; return; }
    local src=""
    if [ -n "${BASH_SOURCE:-}" ]; then src="${BASH_SOURCE}"
    elif [ -n "${ZSH_VERSION:-}" ]; then eval 'src="${(%):-%x}"'
    else src="$0"; fi
    if _fzfs_has readlink && readlink -f "$src" >/dev/null 2>&1; then readlink -f "$src"
    else local dir; dir="$(cd "$(dirname "$src")" 2>/dev/null && pwd)"; printf '%s/%s' "$dir" "$(basename "$src")"; fi
}

# Cache script path globally.
FZFS_SCRIPT_PATH="$(_fzfs_resolve_self)"
export FZFS_SCRIPT_PATH

# ==============================================================================
# SECTION 5: DATA GENERATORS (The Sources)
# ==============================================================================

# Mode: Files and Directories
_fzfs_gen_files() {
    local type="$1" base; base="$(_fzfs_expand_path "$2")"
    
    if [ "$HAS_FD" -eq 1 ]; then
        local opts="--hidden --follow --color=never"
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
        local fopts=""; [ "$type" = "f" ] && fopts="-type f"; [ "$type" = "d" ] && fopts="-type d"
        [ "$type" = "recent" ] && fopts="-type f -mtime -1"
        # shellcheck disable=SC2086
        find "$base" $fopts 2>/dev/null
    fi
}

# Mode: Live Content Search (Ripgrep)
_fzfs_gen_search() {
    local base; base="$(_fzfs_expand_path "$1")"
    local query="$2"
    
    if [ "$TOOL_GREP" = "rg" ]; then
        rg --column --line-number --no-heading --color=always --smart-case \
           --hidden --follow --glob "!.git/*" -- "$query" "$base" 2>/dev/null
    else
        grep -rIn "$query" "$base" 2>/dev/null
    fi
}

# Mode: Git Status / Tracked
_fzfs_gen_git() {
    git rev-parse --git-dir >/dev/null 2>&1 || _fzfs_die "Not a git repository."
    case "$1" in
        tracked) git ls-files ;; 
        status)  git ls-files -m -o --exclude-standard ;; 
        dirs)    git ls-files -co --exclude-standard | awk -F/ 'BEGIN {OFS="/"} NF>1 {NF--; dir=$0; if (!seen[dir]++) { print dir "/"; fflush() }}' ;; 
        *)       git ls-files -co --exclude-standard ;; 
    esac
}

# Mode: Projects (Cached)
_fzfs_gen_projects() {
    local roots="$1" refresh="$2" cache_file="$FZFS_CACHE_DIR/projects"
    [ -d "$FZFS_CACHE_DIR" ] || mkdir -p "$FZFS_CACHE_DIR"
    
    # Use provided root or default configuration.
    local search_roots="${roots:-$FZFS_PROJECT_ROOTS}"

    if [ "$refresh" = "--refresh" ] || [ ! -f "$cache_file" ] || [ -n "$roots" ]; then
        local out_list=""
        if [ "$HAS_FD" -eq 1 ]; then
            local cmd="fd --hidden --no-ignore --type d --glob .git"
            for ex in $FZFS_EXCLUDES; do cmd="$cmd --exclude $ex"; done
            out_list=$(for r in $search_roots; do
                r="$(_fzfs_expand_path "$r")"
                [ -d "$r" ] && $cmd "$r"
            done | sed 's|/\.git$||' | sort -u)
        else
            out_list=$(for r in $search_roots; do
                r="$(_fzfs_expand_path "$r")"
                [ -d "$r" ] && find "$r" -type d -name .git -prune -print
            done | sed 's|/\.git$||' | sort -u)
        fi
        
        # Only cache results if using the default environment roots.
        if [ -z "$roots" ]; then 
            printf '%s\n' "$out_list" > "$cache_file"
        else
            printf '%s\n' "$out_list"
            return
        fi
    fi
    cat "$cache_file"
}

# ==============================================================================
# SECTION 6: CALLBACK HANDLERS (Preview Engine)
# ==============================================================================

# Previews for files, directories, and archives.
_fzfs_callback_preview() {
    local path; path="$(_fzfs_expand_path "${1%%:*}")"
    
    if [ -d "$path" ]; then
        if [ "$TOOL_LS" = "ls" ]; then ls -lah "$path"
        else $TOOL_LS -lah --color=always --icons --group-directories-first --git "$path"; fi
        return
    fi
    
    if [ -f "$path" ]; then
        # Preview archives without extraction.
        case "$path" in
            *.tar.gz|*.tgz|*.tar.bz2|*.tar.xz|*.tar) _fzfs_has tar && { tar -tf "$path" | head -n 100; return; } ;;
            *.zip) _fzfs_has unzip && { unzip -l "$path" | head -n 100; return; } ;;
            *.7z) _fzfs_has 7z && { 7z l "$path" | head -n 100; return; } ;;
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
    local hash; hash=$(printf '%s' "$1" | awk '{print $1}')
    printf "%bCommit:%b %s\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}" "$hash"
    local diff_tool="cat"
    if [ "$HAS_DELTA" -eq 1 ]; then diff_tool="delta --width $(tput cols)"
    elif [ "$TOOL_CAT" = "bat" ]; then diff_tool="bat -pl diff"; fi
    
    git log -1 --color=always --date=short --format="%C(yellow)%h%Creset %C(magenta)%ad%Creset %C(cyan)%an%Creset%n%n%C(auto)%s%Creset%n" "$hash" 2>/dev/null
    printf "\n%bChanges:%b\n" "${CLR_BOLD_YELLOW}" "${CLR_RESET}"
    git show --color=always --stat --patch "$hash" | eval "$diff_tool" | head -n 150
}

# Preview for Git Branches.
_fzfs_callback_branch_preview() {
    local ref; ref=$(printf '%s' "$1" | awk '{print $1}')
    local base="main"; git show-ref --verify --quiet refs/heads/master && base="master"
    printf "%bBranch:%b %s\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}" "$ref"
    
    local ab; ab=$(git rev-list --left-right --count "$base...$ref" 2>/dev/null)
    if [ -n "$ab" ]; then 
        printf "%bDiff vs %s:%b Ahead %s, Behind %s\n" "${CLR_BOLD}" "$base" "${CLR_RESET}" "${ab#*\t}" "${ab%%\t*}"
    fi
    
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
    local mode="$1" base="$2" edit="$3" self_q; self_q="$(_fzfs_quote "$FZFS_SCRIPT_PATH")"
    local src_cmd="" preview_cmd="sh $self_q --internal-preview {}" 
    local fzf_mode_opts=""
    
    case "$mode" in
        git_*)   src_cmd="sh $self_q --internal-gen-git ${mode#git_}" ;;
        projects) src_cmd="sh $self_q --internal-gen-projects $(_fzfs_quote "$base")" ;;
        commits)  src_cmd="sh $self_q --internal-gen-commits"; preview_cmd="sh $self_q --internal-git-preview {}" ;;
        recent)   src_cmd="sh $self_q --internal-gen-files recent $(_fzfs_quote "$base")" ;;
        search)   
            fzf_mode_opts="--disabled"
            src_cmd="sh $self_q --internal-gen-search $(_fzfs_quote "$base") ''"
            ;;;
        *)        src_cmd="sh $self_q --internal-gen-files $mode $(_fzfs_quote "$base")" ;;
    esac

    local binds="$BIND_PREVIEW:toggle-preview,$BIND_YANK:execute-silent(sh $self_q --internal-copy {})",alt-up:preview-up,alt-down:preview-down"
    local b_edit="$BIND_EDIT:execute(${EDITOR:-vi} {})+abort"
    
    if [ "$mode" = "projects" ]; then
        binds="$binds,$BIND_REFRESH:reload(sh $self_q --internal-gen-projects '' --refresh)"
    elif [ "$mode" = "search" ]; then
        b_edit="$BIND_EDIT:execute(${EDITOR:-vi} \$(echo {} | cut -d: -f1) +\$(echo {} | cut -d: -f2))+abort"
        binds="$binds,change:reload:sh $self_q --internal-gen-search $(_fzfs_quote "$base") {q}"
    fi
    binds="$binds,$b_edit"

    local result
    # shellcheck disable=SC2086
    result="$(eval "$src_cmd" | "$FZFS_BIN" --ansi --header "fzfs: Enter(Select) $BIND_CD(cd) $BIND_EDIT(Edit) $BIND_YANK(Copy)" $FZFS_OPTS_UI $fzf_mode_opts --preview "$preview_cmd" --preview-window "$FZFS_OPTS_PREVIEW" --bind "$binds" --expect=$BIND_CD)" || return 1

    local key; key="$(printf '%s\n' "$result" | head -n1)"
    local sel; sel="$(printf '%s\n' "$result" | head -n2 | tail -n1)"
    [ -n "$sel" ] || return 0
    [ "$mode" = "search" ] && sel=$(echo "$sel" | cut -d: -f1)
    [ "$mode" = "commits" ] && sel=$(echo "$sel" | awk '{print $1}')

    if [ "$key" = "$BIND_CD" ]; then
        if [ -d "$sel" ]; then 
            cd "$sel" || return 1
            return 0
        fi
        edit=1
    fi

    if [ "$edit" -eq 1 ]; then
        "${EDITOR:-vi}" "$sel"
    elif [ -t 1 ] && [ -d "$sel" ] && [ "$mode" != "projects" ]; then
        cd "$sel" || return 1
    else
        printf '%s\n' "$sel"
    fi
}

# Specialized UI for Branch switching.
_fzfs_ui_branch() {
    local self_q; self_q="$(_fzfs_quote "$FZFS_SCRIPT_PATH")"
    local c_loc="sh $self_q --internal-gen-branches local"
    local c_rem="sh $self_q --internal-gen-branches remote"
    local c_fet="git fetch --all --prune >/dev/null 2>&1"
    local binds="ctrl-l:change-prompt(Local> )+reload($c_loc),ctrl-r:change-prompt(Remote> )+reload($c_rem),ctrl-f:execute-silent($c_fet)+reload($c_loc),alt-up:preview-up,alt-down:preview-down"
    
    local result
    # shellcheck disable=SC2086
    result="$(eval "$c_loc" | "$FZFS_BIN" --ansi --header "Branches: Ctrl-L(ocal) Ctrl-R(emote) Ctrl-F(etch)" $FZFS_OPTS_UI --prompt "Local> " --preview "sh $self_q --internal-branch-preview {}" --preview-window "$FZFS_OPTS_PREVIEW" --bind "$binds")" || return 1
    local sel; sel="$(printf '%s\n' "$result" | head -n1 | awk '{print $1}')"
    [ -n "$sel" ] && git checkout "$sel"
}

# ==============================================================================
# SECTION 8: DIAGNOSTICS & HELP UI
# ==============================================================================

_fzfs_help() {
    printf "%b" "${CLR_BOLD_CYAN}"
    cat <<'EOF'
    _______  _______  _______  _______ 
   |  ____||___  / ||  ____|/  ____/ 
   | |__      / /  || |__   | (___   
   |  __|    / /   ||  __|   \___ \  
   | |      / /__  || |      ____) | 
   |_|     /_____| ||_|     |_____/  
                                     
EOF
    printf "%b" "${CLR_RESET}"
    cat <<EOF
Usage: fzfs [MODE] [OPTIONS] [PATH]

A unified, high-performance fuzzy finder.

MODES:
  (default)       Search all (files + dirs)
  -f, --files     Search files only
  -d, --dirs      Search directories only (Ctrl-O to cd)
  -s, --search    Live file content search (ripgrep)
  -g, --git       Git tracked files
  -gs, --status   Git status (modified/untracked)
  -gd, --git-dirs Git directories (Ctrl-O to cd)
  -gb, --branch   Git branches (interactive)
  -gc, --commits  Git commits browser
  -gp, --projects Git project jumping (Cached, Ctrl-O to cd)

KEYS:
  Enter           Select / Open / Checkout
  $BIND_CD          cd into selection (Directories)
  $BIND_EDIT          Open in \$EDITOR
  $BIND_YANK          Copy selection to clipboard
EOF
}

_fzfs_doctor() {
    printf "%bFZFS Doctor - Diagnostics%b\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}"
    printf "  Script: %s\n\n" "$FZFS_SCRIPT_PATH"
    _doc_line() {
        printf "    %-14s : " "$1"
        if _fzfs_has "$2"; then printf "%b%-8s (active)%b\n" "${CLR_GREEN}" "$2" "${CLR_RESET}"
        else printf "%b%-8s (missing)%b -> fallback: %s\n" "${CLR_YELLOW}" "$2" "${CLR_RESET}" "$3"; fi
    }
    printf "  %bCore:%b\n" "${CLR_BOLD}" "${CLR_RESET}"
    if _fzfs_has "$FZFS_BIN"; then
        local v; v=$("$FZFS_BIN" --version | awk '{print $1}')
        printf "    %-14s : %b%s (v%s)%b\n" "FZF Binary" "${CLR_GREEN}" "$FZFS_BIN" "$v" "${CLR_RESET}"
    else
        printf "    %-14s : %b%s (missing)%b\n" "FZF Binary" "${CLR_RED}" "$FZFS_BIN" "${CLR_RESET}"
    fi
    printf "\n  %bTooling:%b\n" "${CLR_BOLD}" "${CLR_RESET}"
    _doc_line "File Finder" "fd" "find"
    _doc_line "Content Search" "rg" "grep"
    _doc_line "Directory LS" "$TOOL_LS" "ls"
    _doc_line "File Preview" "bat" "cat"
    _doc_line "Git Diff" "delta" "bat/cat"
    printf "\n  %bUtilities:%b\n" "${CLR_BOLD}" "${CLR_RESET}"
    _fzfs_has file && printf "    %-14s : %bfile (ok)%b\n" "Binary Det" "${CLR_GREEN}" "${CLR_RESET}" || printf "    %-14s : %bmissing%b\n" "Binary Det" "${CLR_RED}" "${CLR_RESET}"
    printf "    %-14s : %b" "Archives" "${CLR_GREEN}"
    _fzfs_has tar && printf "tar "; _fzfs_has unzip && printf "unzip "; _fzfs_has 7z && printf "7z "
    printf "%b\n" "${CLR_RESET}"
}

# ==============================================================================
# SECTION 9: MAIN DISPATCHER
# ==============================================================================

fzfs() {
    local mode="a" base="." edit=0

    # Parse command line arguments.
    while [ "$#" -gt 0 ]; do
        case "$1" in
            # External Modes
            -f|--files)     mode="f" ;;
            -d|--dirs)      mode="d" ;;
            -a|--all)       mode="a" ;;
            -s|--search)    mode="search" ;;
            -g|--git)       mode="git_tracked" ;;
            -gd|--git-dirs) mode="git_dir" ;;
            -gf|--git-all)  mode="git_all" ;;
            -gs|--status)   mode="git_status" ;;
            -mr|--recent)   mode="recent" ;;
            -gb|--branch)   mode="branch" ;;
            -gc|--commits)  mode="commits" ;;
            -gp|--projects) mode="projects" ;;
            -e|--edit)      edit=1 ;;
            --check|--doctor) mode="check" ;;
            -h|--help)      _fzfs_help; return 0 ;;

            # Internal callback logic
            --internal-gen-files)    _fzfs_gen_files "$2" "$3"; return 0 ;;
            --internal-gen-search)   _fzfs_gen_search "$2" "$3"; return 0 ;;
            --internal-gen-git)      if [ "$2" = "dir" ]; then _fzfs_gen_git dirs; else _fzfs_gen_git "$2"; fi; return 0 ;;
            --internal-gen-branches) local fmt="%(refname:short)"; case "$2" in remote) git for-each-ref --format="$fmt" refs/remotes | $TOOL_GREP -v '/HEAD$' ;; *) git for-each-ref --format="$fmt" refs/heads ;; esac; return 0 ;; 
            --internal-gen-commits)  _fzfs_gen_commits; return 0 ;; 
            --internal-gen-projects) _fzfs_gen_projects "$2" "$3"; return 0 ;; 
            --internal-preview)      _fzfs_callback_preview "$2"; return 0 ;; 
            --internal-git-preview)  _fzfs_callback_git_preview "$2"; return 0 ;; 
            --internal-branch-preview) _fzfs_callback_branch_preview "$2"; return 0 ;; 
            --internal-copy)         _fzfs_copy "$2"; return 0 ;; 

            --) shift; break ;; 
            -*) _fzfs_die "Unknown option: $1" ;; 
            *)  base="$1" ;; 
        esac
        shift
    done

    # 1. Dispatch Diagnostics
    [ "$mode" = "check" ] && { _fzfs_doctor; return 0; }
    
    # 2. Trigger Background Project Sync
    if [ "$mode" = "projects" ] && [ "$base" = "." ] && [ -f "$FZFS_CACHE_DIR/projects" ]; then
        find "$FZFS_CACHE_DIR" -name projects -mmin +15 -exec sh -c "sh $(_fzfs_quote "$FZFS_SCRIPT_PATH") --internal-gen-projects '' --refresh >/dev/null 2>&1 &" ";" 
    fi

    # 3. Start the Interactive UI
    if [ "$mode" = "branch" ]; then 
        _fzfs_ui_branch
    else 
        _fzfs_ui_search "$mode" "$base" "$edit"
    fi
}

# Execution Guard: Run fzfs if not being sourced.
(return 0 2>/dev/null) && FZFS_LOADED=1 || fzfs "$@"
