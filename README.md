# Dotfiles

Personal macOS configuration managed with Ansible, Homebrew, and GNU Stow. The deployed files are symlinks into this repository, so most configuration changes take effect after `git pull` and a shell or application restart.

## Daily use

```bash
cd ~/dotfiles
git pull
```

Re-run deployment only when a module or its packages changed:

```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass
```

On a machine where sudo is restricted:

```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --skip-tags register_shell
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
   ansible-galaxy install -r requirements.yml
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass
   ```

   Use `--skip-tags register_shell` instead of `--ask-become-pass` on a BeyondTrust-managed or otherwise restricted machine.

3. Finish the per-machine setup:

   ```fish
   fisher update
   tide configure --auto --style=Lean --prompt_colors='True color' \
     --show_time=No --lean_prompt_height='Two lines' \
     --prompt_connection=Disconnected --prompt_spacing=Sparse \
     --icons='Many icons' --transient=No
   mise install
   ```

4. On an unrestricted machine, make Fish the login shell:

   ```bash
   chsh -s /opt/homebrew/bin/fish
   ```

Optional history sync:

```bash
atuin login -u <username>
atuin sync
```

Use `atuin register -u <username> -e <email>` instead of `login` for a new account.

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
