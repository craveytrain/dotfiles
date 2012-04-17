# Dir navigation
alias -g 2..='../..'
alias -g 3..='../../..'
alias -g 4..='../../../..'

# Utilities
# ls with those helpful little trailing characters
alias ls="ls -F"
# disk usage of current folder
alias d="du -h -d=1"
# Disk free space (human readable numbers)
alias df="df -h"
# Show history
alias h="history"
# Check my ip
alias ip="curl -s http://checkip.dyndns.com/ | sed 's/[^0-9\.]//g'"
# Colorize grep
alias grep='GREP_COLOR="1;37;45" LANG=C grep --color=auto'
# Concatenate and print content of files (add line numbers)
alias catn="cat -n"
# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
