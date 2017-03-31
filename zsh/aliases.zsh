#!/usr/bin/env zsh

#
# Aliases specifically for zsh
#


# Reload profile
alias reload!=". $HOME/.zshrc"

# This does the same thing as the first command, but with automatic conversion
# of the wildcards into the appropriate syntax.  If you combine this with
# noglob, you don't even need to quote the arguments.  For example,
#
# Usage: mmv *.c.orig orig/*.c

alias mmv='noglob zmv -W'
