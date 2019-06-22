#!/usr/bin/env zsh

# enable for profiling
# zmodload zsh/zprof

# Executes commands at the start of an interactive session.
ZSHDIR="$DOTFILES/zsh"
MODULES_DIR="$ZSHDIR/modules"

fpath=($MODULES_DIR/functions $fpath)

source "$DOTFILES/system/init.bash"
source "$ZSHDIR/utility.zsh"
# source_if_present "$DOTFILES/system/load.sh"
source "$ZSHDIR/history.zsh"
source "$MODULES_DIR/completion/init.zsh"

# These 3 must be at the end
source "$MODULES_DIR/autosuggestions/init.zsh"
source "$MODULES_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$MODULES_DIR/zsh-history-substring-search/init.zsh"
source "$MODULES_DIR/prompt/init.zsh"

# load nodenv
if whence nodenv >/dev/null; then
  eval "$(nodenv init - --no-rehash zsh)"
fi

# enable for profiling
# zprof
