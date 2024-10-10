#!/usr/bin/env sh

# Create a data URL from an image (works for other file types too, if you tweak the Content-Type afterwards)
dataurl () {
  echo "data:image/${1##*.};base64,$(openssl base64 -in "$1")" | tr -d '\n' | pbcopy
}

headers () {
  curl -IL "$@"
}

# All the dig info, 'cause I can never remember it
digg () {
  dig +nocmd "$1" any +multiline +noall +answer
}

## Print a horizontal rule
rule () {
  printf "%$(tput cols)s\n"|tr " " "─"
}

## What is running on provided port
## Currently mac only
port () {
  lsof -n -i4TCP:"$1" | grep LISTEN
}

lanscan () {
  IP="$(ipconfig getifaddr en0)"
  nmap -sn $IP/24
}
