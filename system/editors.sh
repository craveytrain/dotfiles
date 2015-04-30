#
# Editors
#

# use vim if possible, otherwise vi
if hash vim 2>/dev/null; then
	export EDITOR=vim
else
	export EDITOR=vi
fi

# if sublime is here, use it
if hash subl 2>/dev/null; then
	# export VISUAL='subl -n'
	export VISUAL='atom -n'
fi

export PAGER='less'
