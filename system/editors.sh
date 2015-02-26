#
# Editors
#

# use vim if possible, otherwise vi
if [ -x `which vim` ]; then
	export EDITOR=vim
else
	export EDITOR=vi
fi

# if sublime is here, use it
if [ -x `which subl` ]; then
	export VISUAL='subl -n'
fi

export PAGER='less'
