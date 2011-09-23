# OS X Only

# growl support
growl() { 
	echo -e $'\e]9;'${1}'\007' ; return ; 
}

# make rm move to trash instead of traditional delete
rm () {
  local path
  for path in "$@"; do
    # ignore any arguments
    if [[ "$path" = -* ]]; then :
    else
      local dst=${path##*/}
      # append the time if necessary
      while [ -e ~/.Trash/"$dst" ]; do
        dst="$dst "$(date +%H-%M-%S)
      done
      mv "$path" ~/.Trash/"$dst"
    fi
  done
}