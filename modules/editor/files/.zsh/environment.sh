# use vim if possible, otherwise vi
if hash vim 2>/dev/null; then
  export EDITOR=vim
else
  export EDITOR=vi
fi

# use Nova, if possible
if hash nova 2>/dev/null; then
	export VISUAL=nova
fi
