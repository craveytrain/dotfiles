#!/usr/bin/env bash

nodes=(
  alfred-coolors
  alfred-updater
  bash-language-server
  babel-cli
  babel-eslint
  bookmarklet
  diff-so-fancy
  eslint
  generator-alfred
  sitespeed.io
  stylelint
  svgo
  yo
)

echo "Installing the nodes"
npm i -g "${nodes[@]}"
