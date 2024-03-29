#!/usr/bin/env sh

# Check my ip
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# Concatenate and print content of files (add line numbers)
alias catn="cat -n"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to clipboard.'"


# Change dir to $DOTFILES
alias dot="cd \$DOTFILES"

# Copy dotfiles installation command to clipboard
# alias dotme="echo 'curl -Lks https://raw.githubusercontent.com/craveytrain/dotfiles/main/.bin/bootstrap.sh | /bin/bash' | pbcopy | echo '=> Dotfiles bootstrapper copied to clipboard.'"

alias e='${(z)VISUAL:-${(z)EDITOR}}'

# shellcheck disable=SC2139
alias mkdir="${aliases[mkdir]:-mkdir} -p"


# if exa is installed, used it
if whence exa >/dev/null; then
	alias ls="exa -F"
	alias l='ls -1a'		# Lists in one column, hidden files.
	alias ll='ls -lh --git --color-scale'	# Lists human readable sizes.
	alias la='ll -a'		# Lists human readable sizes, hidden files.
	alias lx='ll -s=ext'	# Lists sorted by extension (GNU only).
	alias lk='ll -s=size'	# Lists sorted by size, largest last.
	alias lt='ls -T'		# Lists sorted by date, most recent last.
	alias lta='ls -Ta'		# Lists sorted by date, most recent last.
	alias llt='ll -T'		# Lists sorted by date, most recent last.
else
	if [ $PLATFORM = 'LINUX' ]; then
  		alias ls='ls --color=auto -F'
	elif hash gls 2>/dev/null; then
  		# use GNU ls cause it supports 256 colors and symbols
  		alias ls='gls --color=auto -F'
	else
	  	alias ls="${aliases[ls]:-ls} -F -G"
	fi
	alias l='ls -1A'         # Lists in one column, hidden files.
	alias ll='ls -lh'		 # Lists human readable sizes.
	alias la='ll -A'         # Lists human readable sizes, hidden files.
	alias lx='ll -XB'        # Lists sorted by extension (GNU only).
	alias lk='ll -Sr'        # Lists sorted by size, largest last.
	alias lt='ll -tr'        # Lists sorted by date, most recent last.
	alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
	alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.
fi

# These work across exa and ls
alias lm='la | "$PAGER"'	# Lists human readable sizes, hidden files through pager.
alias sl='ls'				# I often screw this up.

# Resource Usage
alias df='df -kh'
alias du='du -kh'

# shellcheck disable=SC2139
alias grep="${aliases[grep]:-grep} --color=auto"

# cd up directories
alias -g ...='../..'
alias -g ....='../../..'
