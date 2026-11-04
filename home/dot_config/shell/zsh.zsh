# zsh only: zimfw (framework) and Powerlevel10k (prompt). Sourced by init.sh.
# chezmoi fetches zimfw.zsh (.chezmoiexternal.toml); zimrc lists the modules.

export ZIM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zim"
export ZIM_CONFIG_FILE="$SHELL_DIR/zimrc"

ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r $ZIM_HOME/zimfw.zsh ]]; then
  # Install missing modules and rebuild init.zsh when zimrc changed.
  if [[ ! $ZIM_HOME/init.zsh -nt $ZIM_CONFIG_FILE ]]; then
    source $ZIM_HOME/zimfw.zsh init -q
  fi

  source $ZIM_HOME/init.zsh
  source $SHELL_DIR/p10k.zsh
else
  print -u2 'zim: zimfw.zsh is missing; run: chezmoi apply'
fi

# Up and down search history by the typed prefix.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Case-insensitive, menu-style completion.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
