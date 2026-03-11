# dev-tools module - mise runtime manager activation

set -gx MISE_TRUSTED_CONFIG_PATHS "$HOME/.config/mise/conf.d"
if status --is-interactive
    mise activate fish | source
end
