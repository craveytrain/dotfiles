# Dotfiles Development Guidelines for Cursor

Auto-generated context for AI-assisted development. Last updated: 2025-12-15

## Project Overview

This is a dotfiles management system using **ansible-role-dotmodules** for automated deployment across macOS systems. The project uses modular configuration with GNU Stow for file deployment and Homebrew for package management.

**Constitution**: See `docs/policy/CONSTITUTION.md` for governing principles (v1.0.0)

## Active Technologies

- **Automation**: Ansible 2.9+, ansible-role-dotmodules
- **File Deployment**: GNU Stow with --adopt flag
- **Package Management**: Homebrew (packages + casks), Mac App Store (mas)
- **Configuration Format**: YAML (config.yml files)
- **Shell**: Fish shell
- **Version Control**: Git
- **Python Tooling**: UV (package manager), spec-kit (this framework)

## Project Structure

```
dotfiles/
├── modules/                    # Dotfile modules (each tool/app gets one)
│   ├── fish/                   # Fish shell configuration
│   ├── zsh/                    # Zsh shell configuration and shared tools
│   │   ├── config.yml          # Module configuration
│   │   └── files/              # Files to deploy via stow
│   ├── git/                    # Git with aliases and configuration
│   ├── editor/                 # Editor configurations (vim)
│   └── dev-tools/              # Development utilities
├── playbooks/                  # Ansible playbooks
│   ├── deploy.yml              # Main deployment playbook
│   └── inventory               # Ansible inventory (localhost)
├── .cursor/                    # Cursor configuration
│   └── commands/               # Custom slash commands
├── .specify/                   # Spec-kit framework
│   └── .gitkeep               # Placeholder for spec-kit files
├── docs/                       # Documentation
│   └── policy/                 # Governance and policy documents
└── specs/                      # Feature specifications (created as needed)
```

## Module Configuration Format

Every module has a `config.yml` with these optional fields:

```yaml
---
# Module name and description
homebrew_packages:      # Homebrew formulae to install
  - package-name
homebrew_casks:         # Homebrew casks to install
  - cask-name
homebrew_taps:          # Homebrew taps to add
  - tap-name
stow_dirs:              # Directories to deploy via stow (omit if no files/)
  - module-name
mergeable_files:        # Files merged from multiple modules
  - ".zshrc"
  - ".config/file"
```

**Critical Rules**:
- Only include `stow_dirs` if `files/` directory exists
- Always declare `mergeable_files` if contributing to shared configs
- Document modules in README.md

## Commands

### Deployment
```bash
# Install/update Ansible role
ansible-galaxy install -r requirements.yml --force

# Deploy all modules
ansible-playbook -i playbooks/inventory playbooks/deploy.yml

# Dry run (check mode)
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --check
```

### Module Development
```bash
# Create new module
mkdir -p modules/newmodule/files
touch modules/newmodule/config.yml
# Add module to playbooks/deploy.yml install list
```

### Spec-kit Workflow
```bash
# Install spec-kit via UV
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Verify installation
specify check

# Use slash commands in Cursor (Cmd+K)
/speckit.specify     # Create feature spec
/speckit.plan        # Create implementation plan
/speckit.implement   # Execute implementation
```

## Code Style

### YAML (config.yml)
- Use 2-space indentation
- Comments above each section explaining purpose
- Include "Note:" section listing what module provides

### Markdown (README.md)
- H1: Module name (e.g., "# Shell Module")
- Sections: Features, What Gets Installed, Usage, Integration, Configuration
- Code blocks with language specified
- Tables for structured information

### Ansible
- Use ansible-role-dotmodules role
- Declare all dependencies explicitly
- No sudo requirements (use community.general.homebrew modules)
- Idempotent operations only

## Common Patterns

### Adding a New Application Module

**Pattern**: App-only module (no config files)
```yaml
# config.yml
---
homebrew_casks:
  - app-name
# Note: No stow_dirs since no files to deploy
```

**Pattern**: App with config files
```yaml
# config.yml
---
homebrew_casks:
  - app-name
stow_dirs:
  - module-name
mergeable_files:    # Only if contributing to shared configs
  - ".config/file"
```

### Homebrew Package Installation

All packages across all modules are collected and installed together:
- `homebrew_packages` merged from all modules
- `homebrew_casks` merged from all modules  
- `homebrew_taps` merged from all modules

## Troubleshooting

### Stow Conflicts
If deployment fails with stow conflicts:
- Check if files already exist in home directory
- Ensure mergeable files declared in all contributing modules
- Verify `--adopt` flag present in ansible-role-dotmodules

### Missing Packages
If packages don't install:
- Check configuration reduction in ansible-role-dotmodules
- Ensure list merging uses accumulation, not replacement
- Verify `homebrew_packages`/`homebrew_casks` present in final_config

### Module Not Deploying
- Verify module in `playbooks/deploy.yml` install list
- Check `config.yml` syntax
- Don't declare `stow_dirs` without `files/` directory

## Dependencies

**Required Tools**:
- macOS (required for Homebrew)
- Ansible 2.9+
- GNU Stow
- Homebrew
- Git

**Python Tools** (via UV):
- spec-kit (specify CLI)

**Ansible Roles**:
- ansible-role-dotmodules (from github.com/getfatday/ansible-role-dotmodules)

**Ansible Collections**:
- community.general (for Homebrew modules)

## Architecture Decisions

### Why ansible-role-dotmodules?
Provides modular dotfile management with:
- Module aggregation (collects all config.yml files)
- File merging (handles shared configs)
- Stow deployment automation
- Homebrew package aggregation

### Why GNU Stow?
- Creates symlinks to version-controlled files
- No file duplication
- Easy to update (edit source, changes reflected immediately)
- `--adopt` flag handles conflicts

## Best Practices

### When Adding Modules
1. Use `/speckit.specify` to define what the module does
2. Use `/speckit.plan` to plan the implementation
3. Follow constitution principles (all 8 required)
4. Test deployment before committing
5. Document thoroughly in README.md

### When Modifying ansible-role-dotmodules
- Test changes locally first
- Update both source repo and dotfiles repo
- Reinstall role: `ansible-galaxy install -r requirements.yml --force`
- Verify deployment still works

## Spec-Kit Integration

**Installation**: Spec-Kit is installed via UV (Python tool manager), not as a Cursor extension:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
specify check  # Verify installation
```

Custom slash commands available in Cursor (press `Cmd+K`):

- `/speckit.constitution` - Update project principles
- `/speckit.specify` - Create feature specifications  
- `/speckit.clarify` - Interactive requirement clarification
- `/speckit.plan` - Generate implementation plans
- `/speckit.tasks` - Break down into actionable tasks
- `/speckit.implement` - Execute implementation
- `/speckit.analyze` - Verify cross-artifact consistency
- `/speckit.checklist` - Quality validation gates

**Note**: These commands work through Cursor's AI chat interface when Spec-Kit CLI is installed via UV. They are not provided by a Cursor extension.

## Example Workflows

### Adding a New Browser Module

```
# 1. Create specification
/speckit.specify Add Firefox Developer Edition module with developer tools,
privacy-focused settings, and integration with development workflow

# 2. Create plan
/speckit.plan Install via Homebrew Cask, no config files needed since Firefox
manages its own profiles

# 3. Generate tasks
/speckit.tasks

# 4. Implement
/speckit.implement
```

### Adding a Development Tool Module

```
# 1. Specify
/speckit.specify Add PostgreSQL module with automated backups, performance
tuning, and connection pooling configuration

# 2. Clarify requirements
/speckit.clarify

# 3. Plan
/speckit.plan Use Homebrew for PostgreSQL 15, create config files for 
postgresql.conf, setup automated backup script

# 4. Generate tasks
/speckit.tasks

# 5. Implement
/speckit.implement
```

## Repository Principles

All development must comply with the 8 core principles defined in the [Constitution](docs/policy/CONSTITUTION.md):

1. **Modularity**: Keep modules self-contained
2. **Idempotency**: Ansible playbooks must be safe to run multiple times
3. **Automation-First**: Prefer automated setup over manual steps
4. **Cross-Platform Awareness**: Consider macOS, Linux compatibility
5. **Configuration Merging**: Handle configuration conflicts intelligently
6. **Documentation-First**: Document before implementing
7. **Version Control**: All configurations in Git
8. **Declarative Over Imperative**: Use declarative configs where possible

## Quick Reference

### File Locations
- Constitution: `docs/policy/CONSTITUTION.md`
- Module configs: `modules/*/config.yml`
- Deployment playbook: `playbooks/deploy.yml`
- Ansible inventory: `playbooks/inventory`

### Important Paths
- Dotmodules destination: `~/.dotmodules/`
- Stowed files: Symlinked from `~/.dotmodules/*/files/`
- UV tools: `~/.local/bin/`

### Git Workflow
- Main branch: `main`
- All changes pushed to origin
- Clean working tree maintained

---

**Note**: This file provides context to Cursor AI for better assistance with dotfiles development.
