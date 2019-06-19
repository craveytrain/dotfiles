#!/usr/bin/env zsh

# Source module files.
source "${0:h}/external/zsh-history-substring-search.zsh" || return 1

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=yellow,bold,fg=black,bold'
