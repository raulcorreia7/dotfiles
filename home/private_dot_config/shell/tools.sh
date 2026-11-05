# Tool integrations, each skipped when the tool is missing. Sourced by init.sh.

dot_has fzf && eval "$(fzf "--$(dot_shell)")"
dot_has zoxide && eval "$(zoxide init "$(dot_shell)")"

# mise: shims keep non-interactive shells working; activate hooks interactive ones.
if dot_has mise; then
  _shims="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"
  [ -d "$_shims" ] && dot_path_add "$_shims"
  unset _shims

  dot_interactive && eval "$(mise activate "$(dot_shell)")"
fi

# Google Cloud SDK, when its installer put it in $HOME (it ships zsh and bash variants).
_gcloud="$HOME/google-cloud-sdk"
if [ -r "$_gcloud/path.$(dot_shell).inc" ]; then
  . "$_gcloud/path.$(dot_shell).inc"
  dot_interactive && [ -r "$_gcloud/completion.$(dot_shell).inc" ] && . "$_gcloud/completion.$(dot_shell).inc"
fi
unset _gcloud
