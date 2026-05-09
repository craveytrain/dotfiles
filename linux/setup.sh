#!/usr/bin/env bash
# Minimal Linux server setup for occasional SSH management.
# Idempotent: safe to re-run.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 1. apt packages
sudo apt-get update
sudo apt-get install -y jq ripgrep direnv shellcheck vim git stow

# 2. starship prompt (skip if already installed)
if ! command -v starship >/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# 3. symlink configs
mkdir -p ~/.bashrc.d ~/.config/git
ln -sfn "$SCRIPT_DIR/bashrc.d/dotfiles.sh"               ~/.bashrc.d/dotfiles.sh
ln -sfn "$SCRIPT_DIR/starship.toml"                      ~/.config/starship.toml
ln -sfn "$REPO_DIR/modules/git/files/.config/git/config" ~/.config/git/config
ln -sfn "$REPO_DIR/modules/git/files/.config/git/ignore" ~/.config/git/ignore
ln -sfn "$REPO_DIR/modules/editor/files/.vimrc"          ~/.vimrc

# 4. wire ~/.bashrc to source ~/.bashrc.d/dotfiles.sh (idempotent)
HOOK='[ -f ~/.bashrc.d/dotfiles.sh ] && source ~/.bashrc.d/dotfiles.sh'
grep -qxF "$HOOK" ~/.bashrc || printf '\n%s\n' "$HOOK" >> ~/.bashrc

echo "Done. Open a new shell or run: source ~/.bashrc"
