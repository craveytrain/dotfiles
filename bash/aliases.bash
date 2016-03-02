#!/usr/bin/env bash

# Profile reload
alias reload!='. ~/.bashrc'

alias ls="ls -FG"        # ls with those helpful little trailing characters
alias ll='ls -lh'        # Lists human readable sizes.
alias la='ll -A'         # Lists human readable sizes, hidden files.
alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
alias lx='ll -XB'        # Lists sorted by extension (GNU only).
alias lk='ll -Sr'        # Lists sorted by size, largest last.
alias lt='ll -tr'        # Lists sorted by date, most recent last.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.

# Make e work for editor
alias e='${VISUAL:-$EDITOR}'

# Colorize grep
alias grep='GREP_COLOR="1;37;45" LANG=C grep --color=auto'

# Resource Usage
alias df='df -kh'
alias du='du -kh'
