#!/usr/bin/env zsh
# why subtree? https://www.atlassian.com/git/tutorials/git-subtree

declare -A subtrees=(
	["zsh/.zsh/prompt/external/powerlevel10k"]="https://github.com/romkatv/powerlevel10k.git"
	["zsh/.zsh/completion/external/zsh-completions"]="https://github.com/zsh-users/zsh-completions.git"
	["zsh/.zsh/completion/external/zsh-better-npm-completion"]="https://github.com/lukechilds/zsh-better-npm-completion.git"
	["zsh/.zsh/prompt-benchmark"]="https://github.com/romkatv/zsh-prompt-benchmark.git"
	["zsh/.zsh/alias-tips"]="https://github.com/djui/alias-tips.git"
	["zsh/.zsh/autosuggestions/external/zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
	["zsh/.zsh/syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
	["zsh/.zsh/history-substring-search/external/zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
)

# iterate over subtrees
for dir url in ${(kv)subtrees}; do
	# if path exists, pull
	if [ -d $dir ]; then
		git subtree pull --prefix $dir $url master --squash
	# else add
	else
		git subtree add --prefix $dir $url master --squash
	fi
done
