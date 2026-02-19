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

## Start a local LLM server via llama-server
## Usage: llama-serve [model-name]
## Defaults to qwen3-8b if no model name is provided
llama-serve () {
  local model="${1:-qwen3-8b}"
  local file flags

  case "$model" in
    qwen3-8b)
      file="$HOME/models/Qwen_Qwen3-8B-Q4_K_M.gguf"
      flags="--port 8080 -ngl 99 --reasoning-budget 0 --reasoning-format none -c 8192"
      ;;
    *)
      echo "Unknown model: $model"
      echo "Available models:"
      echo "  qwen3-8b"
      return 1
      ;;
  esac

  llama-server -m "$file" $flags
}
