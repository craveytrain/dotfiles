#!/usr/bin/env bash

brews=(
	ack
	bash
	boot2docker
	coreutils
	doctl
	findutils
	git
	homebrew/dupes/grep
	httpie
	hub
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

    # Install if we don't have it
    hash brew 2>/dev/null || {
    	echo "Installing homebrew..."
    	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    }

    echo "Updating and upgrading homebrew recipes"
    brew update
    brew upgrade
    brew tap homebrew/dupes

    echo "Brewing binaries"
    brew install "${brews[@]}"

    echo "Making option utils available"
    ln -sf "$(brew --prefix)/share/git-core/contrib/diff-highlight/diff-highlight" /usr/local/bin/diff-highlight

    echo "Cleaning up your mess"
    brew cleanup
