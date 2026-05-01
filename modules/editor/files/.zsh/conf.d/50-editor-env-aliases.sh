# shellcheck shell=zsh
# editor module - EDITOR/VISUAL exports and editor aliases

# prefer BBEdit on macOS, fall back to vim then vi
if hash bbedit 2>/dev/null; then
  export EDITOR='bbedit -w'
  export VISUAL='bbedit -w'
elif hash vim 2>/dev/null; then
  export EDITOR=vim
else
  export EDITOR=vi
fi

alias e='${(z)VISUAL:-${(z)EDITOR}}'
