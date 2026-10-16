#!/usr/bin/env zsh

# Relocate zsh runcoms to XDG. Must be set here so subsequent files
# (.zprofile, .zshrc, .zlogin) are loaded from $ZDOTDIR.
#
# zsh reads exactly one of ~/.zshenv or $ZDOTDIR/.zshenv: this file when
# ZDOTDIR is unset, $ZDOTDIR/.zshenv when a parent already exported it. Keep
# the real content there and only bootstrap here, so child shells spawned
# with ZDOTDIR in their environment still get the same setup.
export ZDOTDIR="$HOME/.config/zsh"
source "$ZDOTDIR/.zshenv"
