# Powerlevel10k: the shipped "lean" style (two lines: path and git, then the prompt char),
# with user@host always shown, moved to the start of line one.
source "$ZIM_HOME/modules/powerlevel10k/config/p10k-lean.zsh"
unset POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS:#context})
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context $POWERLEVEL9K_LEFT_PROMPT_ELEMENTS)
