#!/usr/bin/env bash

brews=(
  ack
  bash
  bash_completion
  coreutils
  doctl
  findutils
  git
  homebrew/dupes/grep
  httpie
  hub
  hugo
  imagemagick
  jq
  libyaml
  mercurial
  mobile-shell
  ngrep
  node
  nvm
  phantomjs
  python
  rbenv
  ruby-build
  shellcheck
  sudolikeaboss
  the_silver_searcher
  wget
  yarn
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
brew tap ravenac95/sudolikeaboss
brew tap homebrew/completions

echo "Brewing binaries"
brew install "${brews[@]}"

echo "Cleaning up your mess"
brew cleanup
