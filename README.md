# Dotfiles Repository

A comprehensive dotfiles management system using the `ansible-role-dotmodules` role for automated system configuration and dotfile deployment.

**Governance**: See [Constitution v1.0.0](docs/policy/CONSTITUTION.md) for project principles  
**AI-Assisted Development**: Integrated with GitHub Spec-Kit for spec-driven development

## Overview

This repository contains modular dotfile configurations that can be deployed using Ansible automation. Each module is self-contained and can be mixed and matched to create a personalized development environment.

## Repository Structure

```
dotfiles/
├── .cursor/           # Cursor IDE commands and configuration
│   └── commands/      # Custom Cursor commands
├── .specify/          # Spec-Kit specifications (auto-managed)
├── docs/              # Documentation and policy
│   └── policy/        # Governance and policy documents
│       ├── CONSTITUTION.md    # Core principles (v1.0.0)
│       ├── GOVERNANCE.md      # Governance model
│       ├── CODING_STANDARDS.md # Coding standards
│       └── CHANGELOG.md       # Change history
├── modules/           # Dotfile modules (each with config.yml and files/)
│   ├── shell/         # Common shell utilities (eza, ripgrep, etc.)
│   ├── fish/          # Fish shell configuration and functions
│   ├── zsh/           # Zsh shell configuration and prompt theme
│   ├── git/           # Git configuration and tools
│   ├── editor/        # Editor configurations (vim)
│   ├── dev-tools/     # Development utilities (mise, eslint, prettier, etc.)
│   └── fonts/         # System fonts for development
├── playbooks/         # Ansible playbooks for deployment
│   ├── deploy.yml     # Main deployment playbook
│   └── inventory      # Ansible inventory file
├── CURSOR.md          # Cursor AI and Spec-Kit development guide
├── requirements.yml   # Ansible Galaxy requirements
└── README.md          # This file
```

## Module Structure

Each module follows this structure:

```
module-name/
├── config.yml         # Module configuration (Homebrew packages, stow dirs, etc.)
└── files/             # Dotfiles to be deployed
    ├── .config/       # Configuration files
    ├── .bin/          # Binary/script files
    └── .*rc           # Shell configuration files
```

## Usage

### Prerequisites

* macOS (required for Homebrew integration)
* Ansible 2.9+
* GNU Stow (for dotfile deployment)
* Homebrew (for package management)

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

2. **Install the ansible-role-dotmodules role:**
   ```bash
   ansible-galaxy install -r requirements.yml
   ```

3. **Run the playbook:**
   ```bash
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass
   ```

### Available Modules

| Module        | Description                    | Key Tools                                   |
| ------------- | ------------------------------ | ------------------------------------------- |
| shell         | Common shell utilities         | eza, ripgrep, tldr, trash, wget, stow      |
| fish          | Fish shell configuration       | fish, fisher, tide                          |
| zsh           | Zsh shell configuration        | powerlevel10k                               |
| git       | Git configuration         | git, gh, diff-so-fancy, difftastic          |
| editor    | Editor configurations     | vim                                         |
| dev-tools | Development tools         | mise, jq, shellcheck, actionlint, 1password, bat |
| fonts     | System fonts              | Fira Code, Hack Nerd Font, Inconsolata, Input |

## Configuration

Each module's `config.yml` file defines:

* **Homebrew packages** to install
* **Homebrew taps** to add
* **Homebrew casks** to install
* **Stow directories** for dotfile deployment

Example `config.yml`:

```yaml
---
# Shell common utilities module
homebrew_packages:
  - eza
  - ripgrep
  - tldr
  - trash
  - wget
  - stow

homebrew_taps:
  - homebrew/bundle
  - homebrew/services

homebrew_taps:
  - homebrew/bundle
  - homebrew/services

stow_dirs:
  - zsh

mergeable_files:
  - '.zshrc'  # Merged with other modules' contributions
```

## Updating Dotfiles

After making changes to your dotfiles:

1. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Update dotfiles"
   ```

2. **Re-run the playbook** to apply changes:
   ```bash
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass
   ```

## Module Management

### Enable/Disable Modules

Edit `playbooks/deploy.yml` and modify the `install` list:

```yaml
install:
  - fish
  - zsh
  - git
  # - editor  # Comment out to disable
  - dev-tools
```

### Add a New Module

1. Create module directory: `modules/my-module/`
2. Add `config.yml` with Homebrew packages and stow_dirs
3. Add `files/` directory with your dotfiles
4. Add module name to `install` list in `playbooks/deploy.yml`

## Customization

### Adding New Modules

1. Create a new directory in `modules/`
2. Add a `config.yml` file with your configuration
3. Create a `files/` directory with your dotfiles
4. Add the module to your playbook's `install` list in `playbooks/deploy.yml`

### Modifying Existing Modules

1. Edit the module's `config.yml` to change dependencies
2. Modify files in the `files/` directory
3. Re-run your playbook to apply changes

## How It Works

1. **Module Processing**: Each module is processed independently
2. **Configuration Aggregation**: All module configurations are merged
3. **Dependency Resolution**: Homebrew packages, taps, and casks are collected
4. **Dotfile Deployment**: GNU Stow deploys all dotfiles
5. **Package Installation**: Homebrew installs all dependencies

## Benefits

* **Modular**: Mix and match modules for different setups
* **Automated**: One command sets up your entire environment
* **Reproducible**: Same setup across multiple machines
* **Version Controlled**: All configurations in Git
* **Conflict Resolution**: Intelligent handling of configuration conflicts

## Troubleshooting

### Common Issues

1. **Missing dependencies**: Ensure all required Ansible roles are installed
2. **Stow conflicts**: Check for existing dotfiles that might conflict
3. **Homebrew issues**: Ensure Homebrew is properly installed

### Debug Mode

Run with verbose output to see what's happening:

```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass -v
```

## Development with Spec-Kit

This repository uses GitHub Spec-Kit for spec-driven development with Cursor AI.

**Note:** Spec-Kit commands require the GitHub Spec-Kit extension to be installed in Cursor. The commands are provided by the extension, not by files in this repository.

### Installing Spec-Kit

Spec-Kit is installed via UV (Python tool manager), not as a Cursor extension:

```bash
# Install UV if not already installed
brew install uv

# Install Spec-Kit CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Verify installation
specify check
```

Once installed, the `/speckit.*` slash commands will be available in Cursor's AI chat (press `Cmd+K`).

For detailed usage instructions, see [CURSOR.md](CURSOR.md).

### Quick Start

Once the Spec-Kit extension is installed, press `Cmd+K` in Cursor and use slash commands:

1. **Create specification**: `/speckit.specify Add Firefox module with developer edition`
2. **Create plan**: `/speckit.plan Install via Homebrew, configure for development`
3. **Generate tasks**: `/speckit.tasks`
4. **Implement**: `/speckit.implement`

### Available Commands

These commands are provided by the GitHub Spec-Kit extension:

* `/speckit.constitution` - View/update project principles
* `/speckit.specify` - Create feature specifications
* `/speckit.clarify` - Interactive requirement clarification
* `/speckit.plan` - Generate implementation plans
* `/speckit.tasks` - Break down into actionable tasks
* `/speckit.implement` - Execute implementation
* `/speckit.analyze` - Verify cross-artifact consistency
* `/speckit.checklist` - Quality validation gates

See `CURSOR.md` for comprehensive development guidelines and patterns.

## Policy Documents

This repository is governed by a set of policy documents:

- **[Constitution](docs/policy/CONSTITUTION.md)** - Core principles and governance framework (v1.0.0)
- **[Governance Model](docs/policy/GOVERNANCE.md)** - Decision-making and change processes
- **[Coding Standards](docs/policy/CODING_STANDARDS.md)** - Code quality and style guidelines
- **[Changelog](docs/policy/CHANGELOG.md)** - History of changes and versions

All contributions must comply with the principles defined in the Constitution.

## Migration from Old Structure

If you were using the old `bootstrap.sh` script, the new structure is fully compatible. The Ansible playbook replaces the bootstrap script and provides the same functionality with additional benefits:

* Automated dependency management
* Idempotent operations
* Better error handling
* Cross-platform support (with configuration)

## Credits

Thanks to [getfatday](https://github.com/getfatday/dotfiles) for the ansible-role-dotmodules structure and inspiration.

## License

MIT License - see LICENSE file for details.
