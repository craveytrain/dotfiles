#!/usr/bin/env bash

nodes=(
	babel
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
