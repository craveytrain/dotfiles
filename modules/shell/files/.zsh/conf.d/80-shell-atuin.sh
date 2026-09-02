# shellcheck shell=zsh
# shell module - atuin shell history
#
# 80- is fine here (unlike the fish fragment): nothing else in zsh binds ctrl-r.
# --disable-up-arrow keeps the history-search-backward binding from 10-zsh-core.
# --disable-ai stops atuin binding "?".

eval "$(atuin init zsh --disable-up-arrow --disable-ai)"
