# Check my ip
alias ip="curl -s http://checkip.dyndns.com/ | sed 's/[^0-9\.]//g'"

# Concatenate and print content of files (add line numbers)
alias catn="cat -n"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
