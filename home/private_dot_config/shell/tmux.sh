# tmux, interactive shells only. Sourced by init.sh.

# sta HOST: attach to (or start) the "main" tmux session on a remote host.
sta() {
  [ -n "${1:-}" ] || {
    echo "Usage: sta <host>" >&2
    return 1
  }
  ssh -t "$1" "tmux attach -d 2>/dev/null || tmux new-session -s main"
}

# A random adjective-noun name, like cozy-forge.
_tmux_name() {
  awk 'BEGIN {
    srand()
    na = split("bouncy breezy cheeky chirpy cozy crispy dizzy feral fizzy giddy goofy jazzy jolly loopy nimble peppy rowdy shiny sneaky spicy spry toasty turbo wily zesty", a, " ")
    nn = split("arcade bazaar beacon bunker burrow camp castle cavern citadel forge goblin hideout hoard kettle lair market meadow outpost palace portal workshop", n, " ")
    print a[int(rand() * na) + 1] "-" n[int(rand() * nn) + 1]
  }'
}

# Autostart: each local terminal opens its own session.
# DOTFILES_TMUX_AUTOSTART=0 turns it off; DOTFILES_TMUX_SESSION picks the name.
if dot_has tmux && [ "${DOTFILES_TMUX_AUTOSTART:-1}" = 1 ] &&
  [ -z "${TMUX:-}" ] && [ -z "${SSH_CONNECTION:-}${SSH_TTY:-}" ]; then
  _session="${DOTFILES_TMUX_SESSION:-$(_tmux_name)}"
  tmux has-session -t "$_session" 2>/dev/null && _session="$_session-$$"
  tmux new-session -s "$_session"
fi
