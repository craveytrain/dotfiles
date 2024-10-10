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
