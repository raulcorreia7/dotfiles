# Plugin manifest (ordered list)
# OS-specific plugins are loaded conditionally

__dot_load_plugin "mise"
__dot_load_plugin "fzf"
__dot_load_plugin "zoxide"
__dot_load_plugin "tmux"

case "$(uname -s)" in
  Linux)
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "${ID_LIKE:-${ID:-}}" in
        *arch*) __dot_load_plugin "os/arch" ;;
      esac
    fi
    ;;
  Darwin)
    __dot_load_plugin "os/macos"
    ;;
esac
