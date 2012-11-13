# Browser Aliases
alias ff="open -a Firefox.app $1"
alias chrome="open -a 'Google Chrome.app' $1"
alias safari="open -a Safari.app $1"

# Flush DNS cache
alias flushdns="dscacheutil -flushcache"

# ls with those helpful little trailing characters
alias ls="ls -F"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# JSC for everyone!
alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc"