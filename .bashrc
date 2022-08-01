#!/usr/bin/env bash

# .bashrc

# keeping the paths simple
export PATH=$HOME/.bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/coreutils:$PATH

# Don't clear the screen after quitting a manual page
export MANPAGER="less -X"

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Profile reload
alias reload!='. ~/.bashrc'

# Load all the shared files
source "$HOME/.system/.environment.sh"
source "$HOME/.system/.aliases.sh"
source "$HOME/.system/.functions.sh"
source "$HOME/.system/.common.sh"

# auto cd into directories
shopt -s autocd
shopt -s cdable_vars

if type brew &>/dev/null; then
  HOMEBREW_PREFIX=$(brew --prefix)
  for COMPLETION in "$HOMEBREW_PREFIX"/etc/bash_completion.d/*
  do
    # shellcheck source=.dotfiles
    [[ -f $COMPLETION ]] && source "$COMPLETION"
  done
  if [[ -f ${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh ]];
  then
    # shellcheck source=.dotfiles
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  fi
fi

# shellcheck source=.dotfiles
source "./bash/prompt.bash"

# load nodenv
if hash asdf 2>/dev/null; then
  source "$(brew --prefix asdf)/libexec/asdf.sh"
fi
