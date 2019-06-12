#!/usr/bin/env bash

#
# Environment
#

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

# Define colors for BSD ls.
export LSCOLORS='gxfxcxdxbxGxDxabagacad'

# Define colors for the completion system.
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=0;41:sg=0;46:tw=0;42:ow=0;43:'

# Grep
export GREP_COLOR='37;45'           # BSD.
export GREP_COLORS="mt=$GREP_COLOR" # GNU.

# Browser
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi
