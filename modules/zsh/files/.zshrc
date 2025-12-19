#!/usr/bin/env zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Executes commands at the start of an interactive session.
# fpath=($MODULES_DIR/functions $fpath)  # Commented out - MODULES_DIR not defined

# Load all the shared files
source "$HOME/.zsh/environment.sh"
source "$HOME/.zsh/aliases.sh"
source "$HOME/.zsh/functions.sh"
source "$HOME/.zsh/utility.zsh"


# Prompt goes last
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
