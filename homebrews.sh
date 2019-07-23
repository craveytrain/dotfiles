#!/usr/bin/env bash

brews=(
  ack
  bash
  coreutils
  doctl
  findutils
  fontforge
  git
  grep
  httpie
  hub
  imagemagick
  jq
  libyaml
  mobile-shell
  ngrep
  node
  nodenv
  "nodenv/nodenv/nodenv-aliases"
  "nodenv/nodenv/nodenv-default-packages"
  "nodenv/nodenv/nodenv-man"
  "nodenv/nodenv/nodenv-package-rehash"
  "nodenv/nodenv/nodenv-vars"
  shellcheck
  sudolikeaboss
  the_silver_searcher
  wget
  yarn
  zsh
)

casks=(
  font-fira-code
  font-firacode-nerd-font
  font-firacode-nerd-font-mono
  font-inconsolata
  font-inconsolata-nerd-font
  font-inconsolata-nerd-font-mono
  font-input
  font-source-code-pro
  font-sourcecodepro-nerd-font
  font-sourcecodepro-nerd-font-mono
)

# Install if we don't have it
hash brew 2>/dev/null || {
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

echo "Updating and upgrading homebrew recipes"
brew update
brew upgrade
brew tap "ravenac95/sudolikeaboss"
brew tap "nodenv/nodenv"
brew tap "homebrew/cask-fonts"

echo "Brewing binaries"
brew install "${brews[@]}"

brew cask install "${casks[@]}"

echo "Cleaning up your mess"
brew cleanup
