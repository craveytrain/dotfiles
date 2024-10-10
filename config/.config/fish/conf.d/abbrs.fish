#
# abbrs - Set abbrs
#

abbr -a dot cd $DOTFILES

# Go up multiple directories
abbr -a dotdot --regex '^\.\.+$' --function multicd

# Check my ip
abbr -a ip dig +short myip.opendns.com @resolver1.opendns.com

# Copies public key to clipboard
abbr -a pubkey "cat ~/.ssh/*.pub | pbcopy; echo '=> Public key copied to clipboard.'"

# Create directories recursively
abbr -a mkdir mkdir -p

# Resource Usage
abbr -a df df -kh
abbr -a du du -kh

# Copy static server code to cwd
abbr -a serveme cp -r $DOTFILES/bin/.bin/serve .
