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


# if eza is installed, used it
if whence eza >/dev/null; then
	alias ls="eza -F -x"
	alias l='eza -1a --icons'		# Lists in one column, hidden files.
	alias lt='eza -T --icons'		# Lists in one column, hidden files.
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

# cd up directories
alias -g ...='../..'
alias -g ....='../../..'
