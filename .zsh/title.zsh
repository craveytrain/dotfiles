#!/usr/bin/env zsh

autoload -Uz add-zsh-hook
add-zsh-hook preexec _title_preexec
add-zsh-hook precmd _title_precmd

_set_title() {
  # stolen from pure prompt: https://github.com/sindresorhus/pure
	setopt localoptions noshwordsplit

	# Emacs terminal does not support settings the title.
	(( ${+EMACS} )) && return

	case $TTY in
		# Don't set title over serial console.
		/dev/ttyS[0-9]*) return;;
	esac



	# Show hostname if connected via SSH.
  local hostname=
  if [[ -v SSH_CONNECTION ]]; then
    hostname="${(%):-(%m) }"
	fi

	local -a opts
	case $1 in
		expand-prompt) opts=(-P);;
		ignore-escape) opts=(-r);;
	esac

	# Set title atomically in one print statement so that it works when XTRACE is enabled.
	print -n $opts $'\e]0;'${hostname}${2}$'\a'
}

_title_precmd() {
  # Shows the full path in the title.
	# _set_title 'expand-prompt' '%~'
	_set_title 'expand-prompt' "%~"
}

_title_preexec() {
  # Shows the current directory and executed command in the title while a process is active.
	_set_title 'ignore-escape' "$(print -rD $PWD): $2"
}
