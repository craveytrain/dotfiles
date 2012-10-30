# Utilities
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