# Coding Standards

This document defines coding standards and best practices for this dotfiles repository.

## YAML Standards

### Configuration Files

- Use 2-space indentation
- Use `---` YAML document separator at the top
- Use descriptive comments
- Keep line length under 100 characters when possible

### Example

```yaml
---
# Shell configuration module
homebrew_packages:
  - fish
  - fisher
  - bat

stow_dirs:
  - shell
```

## Ansible Playbook Standards

### Structure

- Use descriptive task names
- Group related tasks
- Use variables for configuration
- Include error handling

### Example

```yaml
---
- name: Deploy dotfiles
  hosts: localhost
  connection: local
  vars:
    dotmodules:
      repo: "file://{{ playbook_dir }}/../modules"
      dest: "{{ ansible_env.HOME }}/.dotmodules"
      install:
        - shell
        - git
  roles:
    - getfatday.dotmodules
```

## Module Structure Standards

### Directory Structure

```
module-name/
├── config.yml         # Module configuration
└── files/             # Dotfiles to deploy
    ├── .config/       # Configuration files
    └── .*rc           # Shell configs
```

### Naming Conventions

- Module names: lowercase, hyphen-separated (e.g., `dev-tools`)
- File names: follow standard dotfile conventions
- Config files: use descriptive names

## Documentation Standards

### README Requirements

Each module should be documented in the main README with:
- Description
- Key tools/packages
- Configuration options
- Usage examples

### Inline Comments

- Comment complex configurations
- Explain non-obvious choices
- Document platform-specific code
- Include references when applicable

## Testing Standards

### Before Committing

- Run playbook with `--check` flag
- Verify idempotency (run twice)
- Test on clean environment when possible
- Check for linting errors

### Validation

```bash
# Check syntax
ansible-playbook --syntax-check playbooks/deploy.yml

# Dry run
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --check

# Verbose output
ansible-playbook -i playbooks/inventory playbooks/deploy.yml -v
```

## Git Standards

### Commit Messages

- Use descriptive commit messages
- Reference issues when applicable
- Follow conventional commit format when possible

### Branch Strategy

- Use feature branches for new modules
- Keep main branch deployable
- Tag releases appropriately

## Security Standards

### Secrets Management

- Never commit secrets or API keys
- Use environment variables for sensitive data
- Document required environment variables
- Use `.gitignore` appropriately

### File Permissions

- Maintain appropriate file permissions
- Document permission requirements
- Use Ansible's file module for permission management

## conf.d Convention

Modules contribute shell configuration via **conf.d fragments**. These are small, focused config files placed in shell-specific `conf.d/` directories. GNU Stow deploys them as symlinks, and shells source them at startup. This means config edits are live on `git pull` without running Ansible again.

### Prefix Ranges

Fragments use a numeric prefix to control load order. Lower numbers load first.

| Range | Purpose | Current Modules |
|-------|---------|-----------------|
| 00-19 | Core shell config (shell-specific foundations) | zsh (10), fish (10) |
| 20-49 | Reserved for future core modules | (unused) |
| 50-69 | Module features (utilities, editor, aliases) | editor (50), shell (50) |
| 70-79 | Reserved for future feature modules | (unused) |
| 80-99 | Late-loading (runtime managers, tools needing PATH) | dev-tools (80) |

Runtime managers like mise go high (80+) because they may depend on PATH being set by earlier fragments. Core shell config goes low (10) because other fragments may depend on environment variables or shell options set there.

### Fragment Naming Pattern

Each shell type has its own directory and naming convention:

- **Zsh:** `NN-module-description.sh` in `files/.zsh/conf.d/`
- **Fish:** `NN-module-description.fish` in `files/.config/fish/conf.d/`
- **Mise:** `module-name.toml` in `files/.config/mise/conf.d/` (no numeric prefix, mise has no ordering concerns)

### Fragment Header Format

Every fragment starts with an attribution header.

**Zsh fragments:**

```sh
# shellcheck shell=zsh
# {module} module - {brief description}

# ... configuration content
```

The `shellcheck` directive on line 1 tells linters to treat the file as zsh. Line 2 identifies the owning module.

**Fish fragments:**

```fish
# {module} module - {brief description}

# ... configuration content
```

No shellcheck directive needed. Fish is natively supported by linters.

**Mise fragments:**

```toml
# {module} module - {brief description}
# Managed by dotfiles {module} module

[tools]
# ... tool definitions
```

Each mise fragment is standalone TOML with its own `[tools]` or `[settings]` headers.

### End-to-End Example: Adding a "python" Module

Here's how a hypothetical "python" module would add conf.d fragments.

**1. Create the zsh fragment** at `modules/python/files/.zsh/conf.d/50-python-env.sh`:

```sh
# shellcheck shell=zsh
# python module - pyenv environment setup

export PYENV_ROOT="$HOME/.pyenv"
```

**2. Create the fish fragment** at `modules/python/files/.config/fish/conf.d/50-python-env.fish`:

```fish
# python module - pyenv environment setup

set -gx PYENV_ROOT $HOME/.pyenv
```

**3. Create the mise fragment** at `modules/python/files/.config/mise/conf.d/python.toml`:

```toml
# python module - python version management
# Managed by dotfiles python module

[tools]
python = "3.12"
```

**4. Add stow_dirs to config.yml** at `modules/python/config.yml`:

```yaml
---
# Python development module

homebrew_packages:
  - pyenv

stow_dirs:
  - python
```

**5. Add module to playbook** in `playbooks/deploy.yml`:

```yaml
install:
  - python
```

**6. Deploy.** Running the playbook (or `stow python` manually) creates symlinks:

```
~/.zsh/conf.d/50-python-env.sh        -> modules/python/files/.zsh/conf.d/50-python-env.sh
~/.config/fish/conf.d/50-python-env.fish -> modules/python/files/.config/fish/conf.d/50-python-env.fish
~/.config/mise/conf.d/python.toml      -> modules/python/files/.config/mise/conf.d/python.toml
```

The next time you open a shell, the fragments are sourced automatically.

---

**Last Updated:** 2026-03-11

