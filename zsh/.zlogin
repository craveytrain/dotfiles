#!/usr/bin/env zsh

#
# Executes commands at login post-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Execute code that does not affect the current session in the background.
{
  # Compile the completion dump to increase startup speed.
  zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
  fi

  # not needed, atm
  # autoload -U zrecompile
  #
  # # zcompile .zshrc
  #    zrecompile -pq ${ZDOTDIR:-${HOME}}/.zshrc
  #    zrecompile -pq ${ZDOTDIR:-${HOME}}/.zprofile
  #    zrecompile -pq ${ZDOTDIR:-${HOME}}/.zshenv
} &!
