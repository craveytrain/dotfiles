#!/usr/bin/env zsh

export DOT="dotfiles"
export DOTFILES="$HOME/$DOT"

# https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zshenv
# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Local configuration (machine-specific overrides)
[ -f "${ZDOTDIR:-$HOME}/.zshenv.local.zsh" ] && source "${ZDOTDIR:-$HOME}/.zshenv.local.zsh"
