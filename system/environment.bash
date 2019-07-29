#!/usr/bin/env bash

#
# Environment
#

# export nice, clean platform names
case "$OSTYPE" in
  solaris*) PLATFORM="SOLARIS" ;;
  darwin*)  PLATFORM="OSX" ;;
  linux*)   PLATFORM="LINUX" ;;
  bsd*)     PLATFORM="BSD" ;;
  msys*)    PLATFORM="WINDOWS" ;;
  *)        PLATFORM="unknown: $OSTYPE" ;;
esac
export PLATFORM

# use vim if possible, otherwise vi
if hash vim 2>/dev/null; then
  export EDITOR=vim
else
  export EDITOR=vi
fi

# if atom is here, use it
if hash atom 2>/dev/null; then
  export VISUAL='atom'
fi

export PAGER='less'

# Define colors for BSD ls
export LSCOLORS='exfxbxdxcxegedabagacad'
export CLICOLOR=1

# Define colors for GNU ls
export LS_COLORS='di=34:ln=35:so=31:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# if dircolors or gdircolors, run them
hash dircolors 2>/dev/null && eval "$(dircolors -b "$DOTFILES/system/dir_colors")"
hash gdircolors 2>/dev/null && eval "$(gdircolors -b "$DOTFILES/system/dir_colors")"

# Grep
export GREP_COLOR='1;90;103'           # BSD.
export GREP_COLORS="mt=$GREP_COLOR" # GNU.

# Browser
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

CDPATH=".:~"
add_to_cdpath() {
  if [[ -d "$1" ]]; then
    cdpath+=$1
    CDPATH="$CDPATH:$1"
  fi
}
add_to_cdpath "$HOME/Work"
add_to_cdpath "$HOME/Projects"
