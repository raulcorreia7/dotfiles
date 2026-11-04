# Powerlevel10k: the shipped "lean" style (two lines: path and git, then the prompt char),
# plus the one change we want: always show user@host, so a long hostname has line one to itself.
source "$ZIM_HOME/modules/powerlevel10k/config/p10k-lean.zsh"
unset POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION
