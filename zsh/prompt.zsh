# load version control helpers
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' branchformat '%b:%r'
zstyle ':vcs_info:*' stagedstr '%F{green}+%F{reset}'
zstyle ':vcs_info:*' unstagedstr '%F{red}*%F{reset}'
zstyle ':vcs_info:*' check-for-changes true

git_dirty() {
	st=$(/usr/bin/git status 2>/dev/null | tail -n 1)
	if [[ $st != "" ]] then
		if [[ $st == "nothing to commit (working directory clean)" ]] then
			zstyle ':vcs_info:*' formats ' on (%F{green}%b%F{reset})%c%u'
			zstyle ':vcs_info:*' actionformats ' on (%F{green}%b|%a%F{reset})%c%u'
		else
			zstyle ':vcs_info:*' formats ' on (%F{red}%b%F{reset})%c%u'
			zstyle ':vcs_info:*' actionformats ' on (%F{red}%b|%a%F{reset})%c%u'
		fi
	fi
}

directory_name () {
	echo "%F{cyan}${PWD/#$HOME/~}%F{reset}"
}
``
username () {
	echo "%F{blue}%n%F{reset}"
}

hostname () {
	echo "%F{magenta}%m%F{reset}"
}

# Don't show anything if the count is zero
todo(){
	if $(which todo.sh &> /dev/null); then
		num=$(echo $(todo.sh ls | wc -l))
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

if [[ -n $SSH_CONNECTION ]] then
	export PROMPT=$'$(username) at $(hostname) in $(directory_name)${vcs_info_msg_0_}\n› '
else
	export PROMPT=$'in $(directory_name)${vcs_info_msg_0_}\n› '
fi

export PROMPT2=$'› '

export RPROMPT='$(todo)'

precmd() {
	title "zsh" "%m" "%55<...<%~"
	git_dirty
	vcs_info
	print -Pn "\e]2; %~/ \a"
}

