#!/usr/bin/env zsh

prompt_zsh_nodenv() {
  [[ -z $commands[node] ]] || [[ -z $commands[nodenv] ]] && return

  local nodenv_version="$(nodenv version-name 2>/dev/null)"

  [[ "$nodenv_version" == "system" ]] && return

  print "$nodenv_version $POWERLEVEL9K_CUSTOM_NODENV_ICON"
}

typeset -g POWERLEVEL9K_CUSTOM_NODENV=prompt_zsh_nodenv
typeset -g POWERLEVEL9K_CUSTOM_NODENV_FOREGROUND='green'
typeset -g POWERLEVEL9K_CUSTOM_NODENV_BACKGROUND=none
typeset -g POWERLEVEL9K_CUSTOM_NODENV_ICON=$'\uf7d7'
