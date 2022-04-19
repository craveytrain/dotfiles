dotfiles-dir="$HOME/.new-dot"

# TODO: figure out how to update subtrees
git --git-dir=$dotfiles-dir --work-tree=$HOME fetch powerlevel10k
git --git-dir=$dotfiles-dir --work-tree=$HOME subtree pull --prefix .zsh/prompt/external powerlevel10k master --squash
