#!/usr/bin/env zsh
# Reference: https://www.atlassian.com/git/tutorials/dotfiles

dir="$HOME/.dotfiles"

# change to dir
cd $dir


# if stow exists
if hash stow >/dev/null; then
# set stow directories
	stow_dir=(
		bin
		config
		dev
		git
		vim
	)

	for dir in "${stow_dir[@]}"; do
		stow $dir
	done
fi
