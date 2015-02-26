export PROMPT_COMMAND=__prompt_command

# Returns prompt encoded color.
# Takes 1 optional argument.
# If argument is provided, return color prompt. If argument is omitted, return reset.
get_prompt_color () {
	if [[ -n $1 ]]; then
		echo "\e[38;5;$1m"
	else
		echo '\e[0m'
	fi
}

# Memo-ized var
SEPARATOR=""

# Begin a segment
# Takes two arguments, foreground and message. Foreground can be omitted,
# rendering default foreground.
prompt_segment () {
	local fg
	local message

	# If 2 params, 1st one is foreground
	if [[ -n $2 ]]; then
		# insert color supporting 256 colors
		fg="$(get_prompt_color $1)"
		message="$2"
	else
		fg="$(get_prompt_color)"
		message="$1"
	fi

	# color the prompt, spit out the message and reset the colors
	echo -n "$SEPARATOR$fg$message$(get_prompt_color)"

	# Let this run after the first run
	SEPARATOR=" "
}

build_prompt () {
	local EXIT="$?"

	# If exit status is non-zero show an x in red
	if [ $EXIT != 0 ]; then
		prompt_segment 1 '✘'
	fi

	if [[ -n "$SSH_CONNECTION" ]]; then
		# username in blue
		prompt_segment 4 '\u'
		prompt_segment 'at'
		# hostname in magenta
		prompt_segment 5 '\h'
		prompt_segment 'in'
	fi

	# Working directory in cyan
	prompt_segment 6 '\w'

	# If in a git repo
	git_ref="$(git symbolic-ref HEAD 2>&1)"
	if [[ $git_ref != fatal* ]]; then
		# git branch in yellow and commit hash in default
		prompt_segment 3 "⭠ $(git_branch_name $git_ref) [$(get_prompt_color)$(git_commit_hash)$(get_prompt_color 3)]"

		# If git symbols has anything, show it in red
		local git_symbols="$(git_status)"
		if [[ $git_symbols != "" ]]; then
			prompt_segment 1 "$git_symbols"
		fi
	fi

	# cursor prompt in light blue
	prompt_segment 12 "\n❯ "
}

git_branch_name () {
	echo "${git_ref#refs/heads/}"
}

git_commit_hash () {
	echo "$(git rev-parse --short HEAD)"
}

git_status () {
	local symbols
	local git_st="$(git diff --name-status 2>&1)"

	# If untracked files
	[[ "$(git ls-files --others --exclude-standard $(git rev-parse --show-cdup))" != "" ]] && symbols+="?"

	# If modified files
	[[ $(echo "$git_st" | egrep -c "^M") != 0 ]] && symbols+="✱"

	# If modified files
	[[ $(echo "$git_st" | egrep -c "^D") != 0 ]] && symbols+="✖"

	# If added files
	[[ "$(git diff --staged --name-status)" != "" ]] && symbols+="✚"

	# If stashed
	[[ "$(git stash list)" != "" ]] && symbols+="s"

	echo "$symbols"
}

# helper function
count_lines() { echo "$1" | egrep -c "^$2" ; }

__prompt_command () {
	export PS1="$(build_prompt)"
	export PS2="❯ "
}
