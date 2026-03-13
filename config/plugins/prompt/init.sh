# shellcheck shell=sh

[ -n "${ZSH_VERSION:-}" ] || return 0
command -v _prompt_asciiship_vimode >/dev/null 2>&1 || return 0

dot_prompt_identity_mode="${DOTFILES_PROMPT_IDENTITY:-always}"

_dot_prompt_identity_segment() {
  case "${dot_prompt_identity_mode}" in
    always)
      print -n '%B%F{yellow}%n%f%b@%B%F{green}%m%f%b '
      ;;
    auto)
      if [ -n "${SSH_TTY:-}" ]; then
        print -n '%B%F{yellow}%n%f%b@%B%F{green}%m%f%b '
      elif [ "${EUID:-$(id -u)}" -eq 0 ]; then
        print -n '%B%F{red}%n%f%b@%B%F{green}%m%f%b '
      fi
      ;;
    never)
      ;;
    *)
      print -n '%B%F{yellow}%n%f%b@%B%F{green}%m%f%b '
      ;;
  esac
}

PS1='
%(2L.%B%F{yellow}(%L)%f%b .)$(_dot_prompt_identity_segment)%B%F{cyan}%~%f%b${(e)git_info[prompt]}${VIRTUAL_ENV:+" via %B%F{yellow}${VIRTUAL_ENV:t}%f%b"}${duration_info}
%B%(1j.%F{blue}*%f .)%(?.%F{green}.%F{red}%? )$(_prompt_asciiship_vimode)%f%b '
