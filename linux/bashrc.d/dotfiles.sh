# Sourced from ~/.bashrc on Linux servers.
# Mirrors a small, server-appropriate subset of the Mac zsh/fish setup.

HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

export DOTFILES="$HOME/dotfiles"
export EDITOR=vim
export VISUAL=vim

# Override the diff-so-fancy pager from the shared gitconfig (not installed on Linux).
# Editor is handled via $VISUAL/$EDITOR — git falls back to those automatically.
export GIT_PAGER='less -R'

alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias pubkey='cat ~/.ssh/*.pub'
alias mkdir='mkdir -p'
alias df='df -kh'
alias du='du -kh'
alias dot='cd $DOTFILES'

e() { ${VISUAL:-${EDITOR:-vim}} "$@"; }

command -v direnv   >/dev/null && eval "$(direnv hook bash)"
command -v starship >/dev/null && eval "$(starship init bash)"
