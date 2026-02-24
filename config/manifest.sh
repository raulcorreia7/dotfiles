# shellcheck shell=sh
# Plugin manifest - defines which plugins to load and in what order
# Loaded by init.sh after shell initialization

# Cross-platform plugins (loaded on all systems)
dot_load_plugin "mise"   # Runtime version manager
dot_load_plugin "fzf"    # Fuzzy finder
dot_load_plugin "zoxide" # Smarter cd command
dot_load_plugin "tmux"   # Terminal multiplexer autostart

# OS-specific plugins (loaded conditionally based on detected OS)
case "$(uname -s)" in
  Linux)
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "${ID_LIKE:-${ID:-}}" in
        *arch*) dot_load_plugin "os/arch" ;; # Arch Linux maintenance commands
      esac
    fi
    ;;
  Darwin)
    dot_load_plugin "os/macos" # macOS-specific functionality
    ;;
esac
