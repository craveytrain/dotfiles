# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending
