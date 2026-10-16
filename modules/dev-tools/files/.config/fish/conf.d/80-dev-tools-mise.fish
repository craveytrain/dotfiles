# dev-tools module - mise runtime manager activation
#
# Shims mode, unconditionally. Full `mise activate` bakes the resolved tool dir
# (e.g. installs/node/latest/bin) into PATH for the cwd at startup, and every
# child inherits that frozen PATH: GUI apps launched from the shell, agent
# harnesses, non-interactive shells. Shims re-resolve per cwd on each
# invocation, so a project's .nvmrc / mise.toml wins everywhere.
#
# Homebrew's mise formula also ships share/fish/vendor_conf.d/mise-activate.fish,
# which runs full activation unless this variable is 0. Fish sources all conf.d
# files in filename order, so this fragment ("80-…") runs before "mise-activate".

set -gx MISE_FISH_AUTO_ACTIVATE 0
set -gx MISE_TRUSTED_CONFIG_PATHS "$HOME/.config/mise/conf.d"
mise activate fish --shims | source
