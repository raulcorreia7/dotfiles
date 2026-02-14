#!/bin/sh
# Install zimfw modules from .zimrc
# This script clones all modules defined in the zimrc file

set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"
. "$SCRIPT_DIR/config.sh"

MODULES_DIR="$REPO_DIR/config/zimfw/modules"

clone_module() {
  url="$1"
  name="$2"
  target_dir="$MODULES_DIR/$name"

  if [ -d "$target_dir/.git" ]; then
    log "  $name: already exists, skipping"
    return 0
  fi

  if [ -d "$target_dir" ]; then
    log "  $name: removing empty directory"
    rm -rf "$target_dir"
  fi

  log "  $name: cloning..."
  if git clone --depth 1 "$url" "$target_dir" 2>/dev/null; then
    log "  $name: done"
  else
    log "  $name: failed to clone"
    return 1
  fi
}

log "installing zimfw modules..."

# Core zimfw modules
clone_module "https://github.com/zimfw/environment.git" "environment"
clone_module "https://github.com/zimfw/git.git" "git"
clone_module "https://github.com/zimfw/input.git" "input"
clone_module "https://github.com/zimfw/termtitle.git" "termtitle"
clone_module "https://github.com/zimfw/utility.git" "utility"
clone_module "https://github.com/zimfw/duration-info.git" "duration-info"
clone_module "https://github.com/zimfw/git-info.git" "git-info"
clone_module "https://github.com/zimfw/asciiship.git" "asciiship"
clone_module "https://github.com/zimfw/completion.git" "completion"

# External modules
clone_module "https://github.com/zsh-users/zsh-completions.git" "zsh-completions"
clone_module "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting"
clone_module "https://github.com/zsh-users/zsh-history-substring-search.git" "zsh-history-substring-search"
clone_module "https://github.com/zsh-users/zsh-autosuggestions.git" "zsh-autosuggestions"

log "zimfw modules installed"
