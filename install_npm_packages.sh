#!/usr/bin/env bash

nodes=(
	babel
	babel-eslint
	bookmarklet
	bower
	browserify
	csscomb
	csslint
	eslint
	gulp
	grunt-cli
	js-beautify
	jscs
	jsdoc
	jshint
	node-inspector
	sitespeed.io
	svgo
)

echo "Installing the nodes"
npm install -g "${nodes[@]}"
