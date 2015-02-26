#!/bin/zsh

# Install if we don't have it
if test ! $(which brew); then
	echo "Installing homebrew..."
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Updating and upgrading homebrew recipes"
brew update
brew upgrade
brew tap homebrew/dupes

binaries=(
	ack
	apple-gcc42
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
	steam
	the_silver_searcher
	wget
	zsh
	)

echo "Installing binaries"
brew install ${binaries[@]}

echo "Installing casks"
brew install caskroom/cask/brew-cask
brew tap caskroom/versions

apps=(
	adobe-creative-cloud
	alfred
	atom
	dropbox
	firefox
	firefox-aurora
	google-chrome
	google-chrome-canary
	google-drive
	hipchat
	imagealpha
	imageoptim
	iterm2
	kaleidoscope
	onepassword
	querious
	skype
	spotify
	sublime-text3
	transmission
	transmit
	tunnelblick-beta
	vagrant
	virtualbox
	)

brew cask install --appdir="/Applications" ${apps[@]}

# Linking up for Alfred
brew cask alfred link

echo "Installing fonts"
brew tap caskroom/fonts
fonts=(
	font-inconsolata-dz
	font-inconsolata-dz-for-powerline
	font-open-sans
	)

brew cask install ${fonts[@]}

echo "Cleaning up your mess"
brew cleanup
brew cask cleanup

# echo "Making OSX for elite hackerz"
./osx-for-hackers.sh

echo "Bounce your shell"
