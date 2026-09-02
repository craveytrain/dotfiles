# Dotfiles

Personal macOS configuration managed with Ansible, Homebrew, and GNU Stow. The deployed files are symlinks into this repository, so most configuration changes take effect after `git pull` and a shell or application restart.

## Daily use

```bash
cd ~/dotfiles
git pull
```

Re-run deployment only when a module or its packages changed:

```bash
./deploy
```

On a machine where sudo is restricted:

```bash
./deploy --restricted
```

## Set up a new Mac

1. Install the Xcode command line tools and [Homebrew](https://brew.sh/):

   ```bash
   xcode-select --install
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Clone and deploy:

   ```bash
   git clone https://github.com/craveytrain/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   brew install ansible
   ./deploy
   ```

   `./deploy` installs the required public Ansible collection when it is missing. Use `./deploy --restricted` on a BeyondTrust-managed or otherwise restricted machine.

3. Set the Tide prompt baseline, from Fish:

   ```fish
   tide configure --auto --style=Lean --prompt_colors='True color' \
     --show_time=No --lean_prompt_height='Two lines' \
     --prompt_connection=Disconnected --prompt_spacing=Sparse \
     --icons='Many icons' --transient=No
   ```

   This one is manual by design: it writes per-machine universal variables as a one-time baseline, and the tracked `10-fish-core.fish` applies shared adjustments on top. Re-running it would discard those. Fish plugins and mise tool versions need no manual step — deployment installs both.

4. On an unrestricted machine, make Fish the login shell:

   ```bash
   chsh -s /opt/homebrew/bin/fish
   ```

## Modules

The enabled modules are listed in `playbooks/deploy.yml`.

| Module | Provides |
| --- | --- |
| `1password` | 1Password CLI |
| `claude` | Claude Code settings and hooks |
| `dev-tools` | mise, direnv, bat, jq, linters, and network tools |
| `editor` | Vim |
| `fish` | Fish, Fisher, Tide, plugins, and functions |
| `fonts` | Coding and Nerd Fonts |
| `ghostty` | Ghostty and its configuration |
| `git` | Git, GitHub CLI, diff tools, and shared config |
| `shell` | Shared command-line utilities and Atuin |
| `tmux` | tmux and its configuration |
| `zsh` | Zsh, Powerlevel10k, and shell plugins |

Each module's README covers only its special setup and the files it owns.

## Local overrides

Keep machine-specific values and secrets out of this repository:

| Tool | Local file |
| --- | --- |
| Fish | `~/.config/fish/config.local.fish` |
| Git | `~/.config/git/local` |
| Vim | `~/.vimrc.local` |
| Zsh | `~/.config/zsh/.zshrc.local` |

## More

- [Reference](docs/REFERENCE.md): dry runs, troubleshooting, architecture, and module development
- [Linux server setup](linux/README.md): separate minimal Debian/Pi OS path
- `modules/*/README.md`: module-specific notes
