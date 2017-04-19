#!/usr/bin/env bash

nodes=(
  alfred-coolors
  alfred-updater
  babel-cli
  babel-eslint
  bookmarklet
  bower
  browserify
  diff-so-fancy
  eslint
  esformatter
  generator-alfred
  gulp
  grunt-cli
  sitespeed.io
  stylefmt
  stylelint
  svgo
  yo
)

echo "Installing the nodes"
yarn global add "${nodes[@]}" --prefix /usr/local
