#!/usr/bin/env bash

# Create a data URL from an image (works for other file types too, if you tweak the Content-Type afterwards)
dataurl () {
  echo "data:image/${1##*.};base64,$(openssl base64 -in "$1")" | tr -d '\n' | pbcopy
}

headers () {
  curl -IL "$@"
}

# Status web server
# Takes an optional argument of port, otherwise defaults to '8080'
serve () {
  if [[ $OSTYPE == linux* ]]; then
    python2 -m SimpleHTTPServer "${1:-8080}"
  else
    python -m SimpleHTTPServer "${1:-8080}"
  fi
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
