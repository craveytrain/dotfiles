#!/usr/bin/env sh

# Load shared things with bash
source_if_present "$HOME/.dir_colors"
source_if_present "$DOTFILES/system/aliases.sh"
source_if_present "$DOTFILES/system/functions.sh"
source_if_present "$DOTFILES/system/editors.sh"

# Load other files needed at init
source_if_present "$DOTFILES/git/hub/init.sh"
