#!/bin/bash

# Install if we don't have it
hash brew 2>/dev/null || {
	echo "Installing homebrew..."
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

echo "Updating and upgrading homebrew recipes"
brew update
brew upgrade
brew tap homebrew/dupes

binaries=(
	ack
	bash
	boot2docker
	coreutils
	findutils
	git
	homebrew/dupes/grep
	imagemagick
	jq
	libyaml
	mercurial
	mobile-shell
	ngrep
	node
	nvm
	phantomjs
	rbenv
	ruby-build
	the_silver_searcher
	wget
	zsh
	)

echo "Installing binaries"
brew install "${binaries[@]}"

echo "Cleaning up your mess"
brew cleanup

echo "Making OSX for elite hackerz"
./osx-for-hackers.sh

printf "\n#################\n\n"
echo "Bounce your shell"
printf "\n#################\n\n"
