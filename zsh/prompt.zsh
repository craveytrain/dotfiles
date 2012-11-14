# load version control helpers
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:hg:*' branchformat '%b%F{reset}[%r%F{reset}]'
zstyle ':vcs_info:*' hgrevformat '%F{yellow}%12.12h'
zstyle ':vcs_info:*' stagedstr '%F{green}+%F{reset}'
zstyle ':vcs_info:*' unstagedstr '%F{red}*%F{reset}'

git_dirty () {
	git_st=$(git status --porcelain 2> /dev/null | tail -n 1)
	if [[ $git_st == "" ]] then
		zstyle ':vcs_info:git:*' formats ' on %F{green}%b%F{reset}[%F{yellow}%7.7i%F{reset}]%c%u'
		zstyle ':vcs_info:git:*' actionformats ' on %F{green}%b%F{reset}[%F{yellow}%7.7i%F{reset}|%F{red}%a%F{reset}]%c%u'
	else
		zstyle ':vcs_info:git:*' formats ' on %F{red}%b%F{reset}[%F{yellow}%7.7i%F{reset}]%c%u'
		zstyle ':vcs_info:git:*' actionformats ' on %F{red}%b%F{reset}[%F{yellow}%7.7i%F{reset}|%F{red}%a%F{reset}]%c%u'
	fi
}

hg_dirty () {
	hg_st=$(hg status 2> /dev/null | tail -n 1)
	if [[ $hg_st == "" ]] then
		zstyle ':vcs_info:hg:*' formats ' on %F{green}%b%F{reset}%c%u'
		zstyle ':vcs_info:hg:*' actionformats ' on %F{green}%b%F{reset}|%a%c%u'
	else
		zstyle ':vcs_info:hg:*' formats ' on %F{red}%b%F{reset}%c%u'
		zstyle ':vcs_info:hg:*' actionformats ' on %F{red}%b%F{reset}%c%u'
	fi
}

get_directory_name () {
	echo "%F{cyan}${PWD/#$HOME/~}%F{reset}"
}

get_username () {
	echo "%F{blue}%n%F{reset}"
}

get_hostname () {
	echo "%F{magenta}%m%F{reset}"
}

# Right prompt magic
rprompt () {
	RPROMPT=""

	if which rbenv > /dev/null; then
		if [ "$(rbenv version-name)" != "system" ]; then
			RPROMPT="$RPROMPT rbenv: %F{yellow}$(rbenv version-name)%F{reset}"
		fi
	fi

	if [ -z "$VIRTUALENV" ]; then
		RPROMPT="$RPROMPT $VIRTUALENV"
	fi

	if [ -z "$RPROMPT" ]; then
		RPROMPT="$(todo_prompt)"
	fi

	export RPROMPT
}

# Don't show anything if the count is zero
todo_prompt () {
	if $(which todo &> /dev/null); then
		num=$(echo $(todo ls | wc -l))
		#compensate for the extra 2 lines of cruft
		let todos=num-2

		if [ $todos -gt 0 ]; then
			if [ $todos -eq 1 ]; then
				label="todo "
			else
				label="todos"
			fi

			echo "%F{yellow}$todos%F{reset} $label"
		fi
	fi
}

if [[ -n "$SSH_CONNECTION" ]] then
	export PROMPT=$'$(get_username) at $(get_hostname) in $(get_directory_name)${vcs_info_msg_0_}\n› '
else
	export PROMPT=$'in $(get_directory_name)${vcs_info_msg_0_}\n› '
fi

export PROMPT2=$'› '

precmd() {
	title "zsh" "%m" "%55<...<%~"
	git_dirty
	hg_dirty
	vcs_info
	rprompt
	print -Pn "\e]2; %~/ \a"
}
