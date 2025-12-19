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

---

**Last Updated:** 2025-12-15

