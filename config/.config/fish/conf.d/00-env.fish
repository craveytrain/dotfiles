#
# env - Set environment vars.
#
# Set environment variables.
set -gx DOTFILES "$HOME/.dotfiles"

# add to path
eval "$(/opt/homebrew/bin/brew shellenv)"
fish_add_path ~/.bin

set -gx CDPATH . ~ (test -e ~/Work; and echo ~/Work)
