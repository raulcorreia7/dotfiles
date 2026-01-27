#!/bin/sh
# shellcheck disable=SC3043,SC2034
# FZFS: callback handlers.

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------

_fzfs_help_preview() {
  friendly="${FZFS_FRIENDLY:-1}"
  if [ "$friendly" -ne 0 ]; then
    cat <<'EOF'
Key Bindings:
  Enter     - Select and exit
  ctrl-e    - Edit file(s)
  ctrl-o    - Change directory
  ctrl-p    - Toggle preview
  ctrl-r    - Reload source
  ctrl-y    - Copy to clipboard
  ctrl-h    - Toggle hidden files
  alt-h     - Toggle friendly mode
  ?         - Show this help
  Alt-Up    - Preview scroll up
  Alt-Down  - Preview scroll down
  PgUp/PgDn - Preview page up/down
  ctrl-u/d  - Preview half page up/down
EOF
  else
    printf '%s\n' "Enter(Select) C-e(Edit) C-o(Cd) C-p(Preview) C-r(Reload) C-y(Copy) C-h(Hidden) Alt-h(Friendly) ?(Help) Alt-Up/Down(Scroll) PgUp/PgDn(Page) C-u/C-d(Half-Page)"
  fi
}

# -----------------------------------------------------------------------------
# Previews
# -----------------------------------------------------------------------------
_fzfs_callback_preview() {
  raw_path="$1"
  path=
  path="$(_fzfs_resolve_path "${raw_path%%:*}")"
  [ -n "$path" ] || return 0

  if [ -d "$path" ]; then
    if [ "$TOOL_LS" = "ls" ]; then
      ls -lah "$path"
    else $TOOL_LS -lah --color=always --icons --group-directories-first --git "$path"; fi
    return
  fi

  if [ -f "$path" ]; then
    # Preview archives without extraction.
    case "$path" in
      *.tar.gz | *.tgz | *.tar.bz2 | *.tar.xz | *.tar) __dot_has tar && {
        tar -tf "$path" | head -n 100
        return
      } ;;
      *.zip) __dot_has unzip && {
        unzip -l "$path" | head -n 100
        return
      } ;;
      *.7z) __dot_has 7z && {
        7z l "$path" | head -n 100
        return
      } ;;
      *.rar) __dot_has unrar && {
        unrar l "$path" | head -n 100
        return
      } ;;
    esac

    # Binary check to prevent terminal corruption.
    if __dot_has file && file --mime "$path" | grep -q "binary"; then
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

# -----------------------------------------------------------------------------
# Git previews
# -----------------------------------------------------------------------------
_fzfs_callback_git_preview() {
  hash=
  hash=$(printf '%s' "$1" | awk '{print $1}')
  printf "%bCommit:%b %s\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}" "$hash"
  diff_tool="cat"
  if [ "$HAS_DELTA" -eq 1 ]; then
    diff_tool="delta --width $(tput cols)"
  elif [ "$TOOL_CAT" = "bat" ]; then diff_tool="bat -pl diff"; fi

  git log -1 --color=always --date=short --format="%C(yellow)%h%Creset %C(magenta)%ad%Creset %C(cyan)%an%Creset%n%n%C(auto)%s%Creset%n" "$hash" 2>/dev/null
  printf "\n%bChanges:%b\n" "${CLR_BOLD_YELLOW}" "${CLR_RESET}"
  git show --color=always --stat --patch "$hash" | eval "$diff_tool" | head -n 150
}

# -----------------------------------------------------------------------------
# Branch previews
# -----------------------------------------------------------------------------
_fzfs_callback_branch_preview() {
  ref=
  ref=$(printf '%s' "$1" | awk '{print $1}')
  base="main"
  git show-ref --verify --quiet refs/heads/master && base="master"
  printf "%bBranch:%b %s\n" "${CLR_BOLD_CYAN}" "${CLR_RESET}" "$ref"

  ab=
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
