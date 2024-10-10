if status --is-interactive
	#
	# env - Set environment vars.
	#
	# Set environment variables.
	set -gx DOTFILES "$HOME/.dotfiles"

	set -gx XDG_CONFIG_HOME "$HOME/.config"


	# add to path
	eval "$(/opt/homebrew/bin/brew shellenv)"
	fish_add_path ~/.bin

	set -gx CDPATH . ~ (test -e ~/Work; and echo ~/Work)

	# set LS COLORS
	set -gx LS_COLORS 'rs=0:di=00;38;5;39:ex=00;32:ln=00;38;5;5:'

	#
	# abbrs - Set abbrs
	#

	# cd into dotfiles
	abbr dot "cd $DOTFILES"

	# Go up multiple directories
	abbr dotdot --regex '^\.\.+$' --function multicd

	# Check my ip
	abbr ip "dig +short myip.opendns.com @resolver1.opendns.com"

	# Copies public key to clipboard
	abbr pubkey "cat ~/.ssh/*.pub | pbcopy; echo '=> Public key copied to clipboard.'"

	# Create directories recursively
	abbr mkdir "mkdir -p"

	# Resource Usage
	abbr df "df -kh"
	abbr du "du -kh"
end
