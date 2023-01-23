#!/usr/bin/env zsh
# Reference: https://www.atlassian.com/git/tutorials/dotfiles

dir="$HOME/.dotfiles"

if [ ! -d $dir ]; then
	# if directory does not exist, git clone to it
	git clone https://github.com/craveytrain/dotfiles.git $dir
fi

# change to dir
cd $dir


# if stow exists
if hash stow >/dev/null; then
# set stow directories
	stow_dir=(
		bin
		dev
		git
		zsh
	)

	for dir in "${stow_dir[@]}"; do
		stow $dir
	done
fi
