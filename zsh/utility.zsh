#!/usr/bin/env zsh

# Correct commands.
setopt CORRECT
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.

# Reload profile
alias reload!=". $HOME/.zshrc"

# This does the same thing as the first command, but with automatic conversion
# of the wildcards into the appropriate syntax.  If you combine this with
# noglob, you don't even need to quote the arguments.  For example,
#
# Usage: mmv *.c.orig orig/*.c
alias mmv='noglob zmv -W'

# emacs keyboard shortcuts
bindkey -e

# some nice shortcuts for iTerm2 to hook into
bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

# Expands .... to ../..
function expand-dot-to-parent-directory-path {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N expand-dot-to-parent-directory-path
bindkey "." expand-dot-to-parent-directory-path

# auto change directory
setopt auto_cd
