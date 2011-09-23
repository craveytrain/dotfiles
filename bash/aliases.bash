# Dir navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'

# Utilities
alias d="du -h -d=1"
alias df="df -h"
alias h="history"
alias localip="ipconfig getifaddr en1"
alias ip="curl -s http://checkip.dyndns.com/ | sed 's/[^0-9\.]//g'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
alias grep='GREP_COLOR="1;37;45" LANG=C grep --color=auto'
