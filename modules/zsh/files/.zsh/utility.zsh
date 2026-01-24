#!/usr/bin/env zsh

# Correct commands.
setopt CORRECT
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.

# Reload profile
alias reload!="exec zsh"

autoload zmv
# This does the same thing as the first command, but with automatic conversion
# of the wildcards into the appropriate syntax.  If you combine this with
# noglob, you don't even need to quote the arguments.  For example,
#
# Usage: mmv *.c.orig orig/*.c
alias zmv='noglob zmv -W'
alias zcp='zmv -C'
alias zln='zmv -L'

# auto change directory
setopt auto_cd

# History search with up/down arrows (fish-like behavior)
# Type partial command, then up/down to search matching history
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Rationalise dot - expands ... to ../.. as you type (fish-like)
# Works with both "cd ...." and just "...." (with auto_cd)
rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot
