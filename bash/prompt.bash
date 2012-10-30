RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
PURPLE="\e[0;35m"
CYAN="\e[0;36m"
WHITE="\e[0;37m"
RESET="\e[0m"

directory_name () {
	echo "\[$CYAN\]\w\[$RESET\]"
}

username () {
	echo "\[$BLUE\]\u\[$RESET\]"
}

hostname () {
	echo "\[$PURPLE\]\h\[$RESET\]"
}

git_branch_name () {
	ref=$(git symbolic-ref HEAD 2>/dev/null)
	if [[ $ref == "" ]]; then
		echo "#$(git describe)"
	else
		echo "${ref#refs/heads/}"
	fi
}

git_commit_hash () {
	echo "[$YELLOW$(git rev-parse --short HEAD)$RESET]"
}

git_branch () {
	st=$(git status 2>/dev/null | tail -n 1)
	if [[ $st == "" ]]; then
		echo ""
	else
		if [[ $st == "nothing to commit (working directory clean)" ]]; then
			echo -e " on $GREEN$(git_branch_name)$RESET$(git_commit_hash)"
		else
			echo -e " on $RED$(git_branch_name)$RESET$(git_commit_hash)"
		fi
	fi
}

if [[ -n "$SSH_CONNECTION" ]]; then
	export PS1="$(username) at $(hostname) in $(directory_name)\$(git_branch)\n› "
else
	export PS1="in $(directory_name)\n› "
fi


export PS2="› "