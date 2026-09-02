# Quick Start Guide

## Prerequisites

Before you begin, ensure you have:

* **macOS** - This setup is designed for macOS
* **Git** - Already installed on macOS, or install via Xcode Command Line Tools:
  ```bash
  xcode-select --install
  ```
* **Homebrew** - If not installed, get it from [brew.sh](https://brew.sh):
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

## First Time Setup

1. **Clone this repository**:
   ```bash
   git clone https://github.com/craveytrain/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install Ansible**:
   ```bash
   brew install ansible
   ```

3. **Install the required Ansible role**:
   ```bash
   ansible-galaxy install -r requirements.yml
   ```

4. **Deploy your dotfiles**:
   ```bash
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass
   ```

Ansible installs the packages and stows the config symlinks. A few things
can't be automated and need one manual pass.

## Post-Deployment Steps

Run these once per machine, in order.

1. **Install fish plugins.** Ansible installs `fisher` itself but not the
   plugins. From a fish shell:
   ```fish
   fisher update
   ```
   This reads `~/.config/fish/fish_plugins` and installs tide, fzf.fish, done,
   bass, pisces and puffer-fish.

2. **Set the tide prompt baseline.** Tide stores its config in fish universal
   variables, which are per-machine and not in git. This command writes the
   whole baseline and is idempotent:
   ```fish
   tide configure --auto --style=Lean --prompt_colors='True color' \
     --show_time=No --lean_prompt_height='Two lines' \
     --prompt_connection=Disconnected --prompt_spacing=Sparse \
     --icons='Many icons' --transient=No
   ```
   `modules/fish/files/.config/fish/conf.d/10-fish-core.fish` then applies the
   handful of deviations from that baseline on top.

3. **Install the mise-managed runtimes:**
   ```bash
   mise install
   ```

4. **Connect atuin (optional).** Atuin's settings are stowed from the shell
   module, so search behaviour matches on every machine already. This step is
   only needed to sync the history itself between machines:
   ```bash
   atuin login -u <username>    # existing account
   atuin register -u <username> -e <email>   # first machine
   atuin sync
   ```

5. **Set your login shell**, if this is a fresh machine:
   ```bash
   chsh -s /opt/homebrew/bin/fish
   ```

## What Gets Installed

By default, the deployment installs several modules. See [README.md](README.md#available-modules) for the complete list of available modules and what they provide.

## Next Steps

* **Customize your setup** - See [README.md](README.md#customization) to learn how to enable/disable modules or add your own
* **Update your dotfiles** - See [README.md](README.md#updating-dotfiles) for how to make and apply changes
* **Troubleshooting** - See [README.md](README.md#troubleshooting) if you encounter issues

## Quick Troubleshooting

### Check what would be changed (dry-run)
```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass --check
```

### Verbose output
```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass -v
```
