# dotfiles

## Layout
- config/: variables and aliases
- scripts/: functions and helpers
- bin/: optional executables
- init.sh: entrypoint sourced by your shell
- install.sh: symlink helper

-## Commands
- fzfs: unified fuzzy finder for files/dirs (defaults to all), git status (-g/-gf/-gd), git projects (-gp), git branches (-gb), and git commits (-gc). Use -e to edit selection.
- gitclean: clean/reset repo with confirmation
- nvimcfg: open nvim config
- zreload: reload .zshrc
- dotreload: reload dotfiles
- dotdoctor: show tool availability

## Usage
Source init.sh from your shell config (zsh or bash):

```sh
[ -r "$HOME/personal/dotfiles/init.sh" ] && . "$HOME/personal/dotfiles/init.sh"
```

## Install
Run:

```sh
./install.sh
```

This links:
- config -> ~/.config/dotfiles
- bin/* -> ~/.local/bin
