# shellcheck shell=zsh
# dev-tools module - mise-en-place runtime manager activation

export MISE_TRUSTED_CONFIG_PATHS="$HOME/.config/mise/conf.d"
eval "$(mise activate zsh)"
