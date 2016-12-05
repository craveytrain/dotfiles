#!/usr/bin/env bash

nodes=(
  babel
  babel-eslint
  bookmarklet
  bower
  browserify
  csscomb
  csslint
  diff-so-fancy
  eslint
  eslint-plugin-json
  eslint-plugin-html
  eslint-plugin-markdown
  esformatter
  gulp
  grunt-cli
  js-beautify
  sitespeed.io
  svgo
)

echo "Installing the nodes"
yarn global add "${nodes[@]}"
