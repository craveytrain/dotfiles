#! /bin/sh

#
# Editors
#

# use vim if possible, otherwise vi
if hash vim 2>/dev/null; then
	export EDITOR=vim
else
	export EDITOR=vi
fi

# if atom is here, use it
if hash atom 2>/dev/null; then
	export VISUAL='atom'
fi

export PAGER='less'
