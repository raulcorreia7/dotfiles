# Shell runtime, sourced by ~/.zshrc and ~/.bashrc. Works in both shells.
# Machine-local settings go in env.local next to this file; it is never managed.

[ -n "${_DOTFILES_INIT:-}" ] && return 0
_DOTFILES_INIT=1

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
SHELL_DIR="$CONFIG_DIR/shell"

# --- helpers

dot_has() {
  command -v "$1" >/dev/null 2>&1
}

dot_interactive() {
  case "$-" in *i*) return 0 ;; *) return 1 ;; esac
}

dot_shell() {
  if [ -n "${ZSH_VERSION:-}" ]; then
    echo zsh
  elif [ -n "${BASH_VERSION:-}" ]; then
    echo bash
  else
    echo sh
  fi
}

# dot_path_add DIR: put DIR first on PATH unless it is already there
dot_path_add() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

# --- environment

dot_path_add "$HOME/.local/bin"

export EDITOR=nvim
export VISUAL=code
export LIGHTPANDA_DISABLE_TELEMETRY=true

[ -r "$SHELL_DIR/env.local" ] && . "$SHELL_DIR/env.local"

# Model API key for opencode, omp and other clients; written once per machine by the infra repo.
if [ -r "$CONFIG_DIR/homelab/ai.key" ]; then
  AI_API_KEY="$(cat "$CONFIG_DIR/homelab/ai.key")"
  export AI_API_KEY
fi

# --- the rest, in order: zsh framework and prompt, aliases, tools, tmux

[ -n "${ZSH_VERSION:-}" ] && . "$SHELL_DIR/zsh.zsh"
[ -r "$HOME/.alias" ] && . "$HOME/.alias"
[ -r "$HOME/.alias.local" ] && . "$HOME/.alias.local"
. "$SHELL_DIR/tools.sh"
dot_interactive && . "$SHELL_DIR/tmux.sh"
