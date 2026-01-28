# FILE AUTOMATICALLY GENERATED FROM /home/rcorreia/.dotfiles/config/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]] zimfw() { source "${HOME}/.dotfiles/config/zimfw/zimfw.zsh" "${@}" }
fpath=("${HOME}/.dotfiles/config/zimfw/modules/zim-mise/functions" "${HOME}/.dotfiles/config/zimfw/modules/git/functions" "${HOME}/.dotfiles/config/zimfw/modules/utility/functions" "${HOME}/.dotfiles/config/zimfw/modules/duration-info/functions" "${HOME}/.dotfiles/config/zimfw/modules/git-info/functions" "${HOME}/.dotfiles/config/zimfw/modules/zsh-completions/src" "${HOME}/.dotfiles/config/zimfw/modules/completion/functions" ${fpath})
autoload -Uz -- git-alias-lookup git-branch-current git-branch-delete-interactive git-branch-remote-tracking git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove mkcd mkpw duration-info-precmd duration-info-preexec coalesce git-action git-info
source "${HOME}/.dotfiles/config/zimfw/modules/environment/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/zim-mise/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/git/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/input/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/run-help/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/termtitle/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/utility/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/direnv/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/duration-info/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/asciiship/asciiship.zsh-theme"
source "${HOME}/.dotfiles/config/zimfw/modules/completion/init.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/zsh-history-substring-search/zsh-history-substring-search.zsh"
source "${HOME}/.dotfiles/config/zimfw/modules/zsh-autosuggestions/zsh-autosuggestions.zsh"
