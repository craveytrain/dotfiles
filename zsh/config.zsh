HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP # don't restart background processes
setopt AUTO_CD # add cd if not provided
setopt NO_BEEP # never, ever, never beep
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt CORRECT #correct mistakes
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt interactivecomments # can comment inline

# History
setopt HIST_VERIFY
setopt APPEND_HISTORY # adds history
setopt SHARE_HISTORY # share history between sessions ???
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY # add timestamps to history

# superglobs
setopt extendedglob
unsetopt caseglob

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

zle -N salida
bindkey '^D' salida
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey 'BACKSPACE' delete-char

#setup autocomplete to use colors
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

autoload -U zmv