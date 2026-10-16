# shellcheck shell=zsh
# dev-tools module - mise-en-place runtime manager activation
#
# Shims mode: see the fish fragment for why full activation leaks a frozen,
# wrong-version PATH into child processes.

export MISE_TRUSTED_CONFIG_PATHS="$HOME/.config/mise/conf.d"
eval "$(mise activate zsh --shims)"
