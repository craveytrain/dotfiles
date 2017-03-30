#!/usr/bin/env bash

nodes=(
  babel-cli
  babel-eslint
  bookmarklet
  bower
  browserify
  diff-so-fancy
  eslint
  eslint-plugin-json
  eslint-plugin-html
  eslint-plugin-markdown
  esformatter
  gulp
  grunt-cli
  sitespeed.io
  stylefmt
  stylelint
  svgo
)

echo "Installing the nodes"
yarn global add "${nodes[@]}" --prefix /usr/local
