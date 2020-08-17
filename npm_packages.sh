#!/usr/bin/env bash

nodes=(
  alfred-coolors
  alfred-updater
  bash-language-server
  diff-so-fancy
  eslint
  generator-alfred
  stylelint
  svgo
)

echo "Installing the nodes"
npm i -g "${nodes[@]}"
