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
