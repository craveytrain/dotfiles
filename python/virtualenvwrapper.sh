#!/usr/bin/env sh

source_if_present "$(which virtualenvwrapper.sh)"

WORKON_HOME="$HOME/.virtualenvs"
export WORKON_HOME
