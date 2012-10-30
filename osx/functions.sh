# OS X Only

# make rm move to trash instead of traditional delete
rm () {
  local file_path
  for file_path in "$@"; do
    # ignore any arguments
    if [[ "$file_path" = -* ]]; then :
    else
      local dst=${file_path##*/}
      # append the time if necessary
      while [ -e ~/.Trash/"$dst" ]; do
        dst="$dst "$(date +%H-%M-%S)
      done
      mv "$file_path" ~/.Trash/"$dst"
    fi
  done
}

# growl
growl () {
	echo -e $'\e]9;'${1}'\007';
	return;
}