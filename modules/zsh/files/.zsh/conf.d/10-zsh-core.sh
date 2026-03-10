# shellcheck shell=zsh
# zsh module - core environment, aliases, functions, and shell options

# --- Environment ---

# export nice, clean platform names
case "$OSTYPE" in
  solaris*) PLATFORM="SOLARIS" ;;
  darwin*)  PLATFORM="OSX" ;;
  linux*)   PLATFORM="LINUX" ;;
  bsd*)     PLATFORM="BSD" ;;
  msys*)    PLATFORM="WINDOWS" ;;
  *)        PLATFORM="unknown: $OSTYPE" ;;
esac
export PLATFORM

# Nerd Font support detection
# Override: export NERD_FONT=0 to disable, NERD_FONT=1 to force enable
if [ -z "$NERD_FONT" ]; then
  case "${TERM_PROGRAM:-}" in
    ghostty|iTerm.app|WezTerm|WarpTerminal)
      NERD_FONT=1
      ;;
    Apple_Terminal)
      NERD_FONT=0
      ;;
    *)
      NERD_FONT=0
      ;;
  esac
  export NERD_FONT
fi

export PAGER='less'

# Define colors for BSD ls
export LSCOLORS='exfxbxdxcxegedabagacad'
export CLICOLOR=1

# Define colors for GNU ls
export LS_COLORS='di=34:ln=35:so=31:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# if dircolors or gdircolors, run them
hash dircolors 2>/dev/null && eval "$(dircolors -b "$HOME/.zsh/dir_colors")"
hash gdircolors 2>/dev/null && eval "$(gdircolors -b "$HOME/.zsh/dir_colors")"

# Grep
export GREP_COLOR='1;90;103'           # BSD.
export GREP_COLORS="mt=$GREP_COLOR" # GNU.

# Browser
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

CDPATH=".:~"
add_to_cdpath() {
  if [[ -d "$1" ]]; then
    cdpath+=$1
    CDPATH="$CDPATH:$1"
  fi
}
add_to_cdpath "$HOME/Work"
add_to_cdpath "$HOME/Projects"

# include env file, if available
if [ -f $HOME/.env ]; then
  # shellcheck source=$HOME/.env
  . $HOME/.env
fi

# --- Aliases ---

# Check my ip
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# Concatenate and print content of files (add line numbers)
alias catn="cat -n"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to clipboard.'"

# Change dir to $DOTFILES
alias dot="cd \$DOTFILES"

# shellcheck disable=SC2139
alias mkdir="${aliases[mkdir]:-mkdir} -p"

# if eza is installed, used it
if whence eza >/dev/null; then
	alias ls="eza -F -x"
	alias l='eza -1a --icons'		# Lists in one column, hidden files.
	alias lt='eza -T --icons'		# Lists in tree structure.
	alias ll='eza -lh --icons --git --git-repos'	# Lists human readable sizes.
	alias la='ll -a'		# Lists human readable sizes, hidden files.
	alias lk='ll -s=size -r'	# Lists sorted by size, largest first.
	alias lu='ll -s=modified -r --time-style=relative'	# Lists sorted by modified timestamp, most recent first.
fi

alias sl='ls'				# I often screw this up.

# Resource Usage
alias df='df -kh'
alias du='du -kh'

# shellcheck disable=SC2139
alias grep="${aliases[grep]:-grep} --color=auto"

# --- Functions ---

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

## Create or attach to a named tmux session
## Usage: mux [session-name]
## Defaults to "main" if no session name is provided
mux () {
  local session="${1:-main}"
  tmux new-session -A -s "$session"
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

# --- Shell Options ---

# Correct commands.
setopt CORRECT
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.

# Reload profile
alias reload!="exec zsh"

autoload zmv
# This does the same thing as the first command, but with automatic conversion
# of the wildcards into the appropriate syntax.  If you combine this with
# noglob, you don't even need to quote the arguments.  For example,
#
# Usage: mmv *.c.orig orig/*.c
alias zmv='noglob zmv -W'
alias zcp='zmv -C'
alias zln='zmv -L'

# auto change directory
setopt auto_cd

# History search with up/down arrows (fish-like behavior)
# Type partial command, then up/down to search matching history
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Rationalise dot - expands ... to ../.. as you type (fish-like)
# Works with both "cd ...." and just "...." (with auto_cd)
rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot
