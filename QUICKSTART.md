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
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
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
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml
   ```

That's it! Your dotfiles are now deployed and all configured tools are installed.

## What Gets Installed

By default, the deployment installs several modules. See [README.md](README.md#available-modules) for the complete list of available modules and what they provide.

## Next Steps

* **Customize your setup** - See [README.md](README.md#customization) to learn how to enable/disable modules or add your own
* **Update your dotfiles** - See [README.md](README.md#updating-dotfiles) for how to make and apply changes
* **Troubleshooting** - See [README.md](README.md#troubleshooting) if you encounter issues

## Quick Troubleshooting

### Check what would be changed (dry-run)
```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --check
```

### Verbose output
```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml -v
```
