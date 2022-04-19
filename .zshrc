#!/usr/bin/env zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Executes commands at the start of an interactive session.
fpath=($MODULES_DIR/functions $fpath)

# Load all the shared files
source "$HOME/.system/.environment.sh"
source "$HOME/.system/.aliases.sh"
source "$HOME/.system/.functions.sh"

source "$HOME/.zsh/utility.zsh"
source "$HOME/.zsh/history.zsh"
source "$HOME/.zsh/title.zsh"
source "$HOME/.zsh/completion/init.zsh"
source "$HOME/.zsh/zsh-prompt-benchmark/zsh-prompt-benchmark.plugin.zsh"
source "$HOME/.zsh/alias-tips/alias-tips.plugin.zsh"

# # These 3 must be at the end
# source "$MODULES_DIR/autosuggestions/init.zsh"
# source "$MODULES_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# source "$MODULES_DIR/zsh-history-substring-search/init.zsh"
source "$HOME/.zsh/prompt/init.zsh"

plugins=(
  zsh-prompt-benchmark
)

# load nodenv
if whence nodenv >/dev/null; then
  eval "$(nodenv init - --no-rehash zsh)"
fi
