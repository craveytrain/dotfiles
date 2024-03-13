#!/usr/bin/env zsh

# Executes commands at the start of an interactive session.
fpath=($MODULES_DIR/functions $fpath)

# Load all the shared files
source "$HOME/.zsh/environment.sh"
source "$HOME/.zsh/aliases.sh"
source "$HOME/.zsh/functions.sh"
source "$HOME/.zsh/utility.zsh"

# load asdf
if whence asdf >/dev/null; then
  source "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# Prompt goes last
if whence oh-my-posh >/dev/null; then
	# Uncomment this and comment the other one out to get default prompt
	# eval "$(oh-my-posh init zsh)"
	# eval "$(oh-my-posh init zsh --config $HOME/.zsh/prompt/default.omp.json)"
	eval "$(oh-my-posh init zsh --config $HOME/.zsh/prompt/oh-my-posh.json)"
fi
