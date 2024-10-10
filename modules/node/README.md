# Node Module

Node.js development module for managing Node.js and pnpm versions via mise, along with npm configuration.

## Overview

This module provides:
- Node.js version management via mise
- pnpm version management via mise
- NPM configuration defaults via .npmrc

## Prerequisites

- **dev-tools module**: Must be installed first as it provides mise via Homebrew
- **mise**: Must be available in PATH (installed by dev-tools module)

## Configuration

### Mise Configuration

Node and pnpm versions are specified in `.config/mise/config.toml`:

```toml
[tools]
node = "latest"  # Always use latest Node.js version
pnpm = "latest"  # Always use latest pnpm
```

### NPM Configuration

NPM settings are configured in `.npmrc`:

```ini
save-exact=false
save=true
engine-strict=false
progress=true
audit-level=moderate
update-notifier=true
```

## Usage

After deployment, mise will automatically manage node and pnpm versions based on the configuration.

### Checking Active Versions

```bash
# Show all active tool versions
mise current

# Show specific tool version
mise current node
mise current pnpm
```

### Updating Tool Versions

1. Edit the configuration file:
   ```bash
   vim modules/node/files/.config/mise/config.toml
   ```

2. Change the version:
   ```toml
   [tools]
   node = "latest"  # Or pin to specific: "22.9.0"
   pnpm = "latest"  # Or pin to specific: "9.1.0"
   ```

3. Redeploy:
   ```bash
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml
   ```

4. Verify:
   ```bash
   mise current node
   ```

### Updating NPM Configuration

1. Edit .npmrc:
   ```bash
   vim modules/node/files/.npmrc
   ```

2. Modify settings:
   ```ini
   save-exact=true
   audit-level=high
   ```

3. Redeploy:
   ```bash
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml
   ```

4. Verify:
   ```bash
   npm config list
   ```

## Dependencies

This module depends on the `dev-tools` module for mise installation. The dev-tools module installs mise via Homebrew, which must be available before this module can function properly.

## Installation Order

In `playbooks/deploy.yml`, ensure `dev-tools` appears before `node` in the install list:

```yaml
install:
  - dev-tools  # Must come before node (provides mise)
  - node       # Depends on mise from dev-tools
```

## Configuration Merging

The mise configuration file (`.config/mise/config.toml`) is a mergeable file, meaning it combines settings from multiple modules:

- **dev-tools module**: Provides Python version and mise settings
- **node module**: Provides Node.js and pnpm versions

The merged configuration is created automatically during deployment and deployed to `~/.config/mise/config.toml`.

### Merge Precedence

- Files are concatenated in module installation order (from `deploy.yml`)
- Later modules' sections appear after earlier modules
- For TOML tables, later definitions may override earlier ones for the same tool
- Module-specific settings take precedence over global settings

### Viewing Merged Configuration

```bash
# View the effective merged configuration
mise config ls

# View the merged file directly
cat ~/.config/mise/config.toml
```

## Troubleshooting

### mise not found

**Problem**: `mise: command not found`

**Solution**:
```bash
# Ensure dev-tools module is installed
grep -A 10 "install:" playbooks/deploy.yml | grep dev-tools

# If missing, add dev-tools to deploy.yml and redeploy
ansible-playbook -i playbooks/inventory playbooks/deploy.yml
```

### Configuration not merging

**Problem**: Changes to node module config not appearing in `~/.config/mise/config.toml`

**Solution**:
```bash
# Check merged config
cat modules/merged/.config/mise/config.toml

# Verify mergeable_files directive
cat modules/node/config.yml | grep -A 2 mergeable_files

# Redeploy with verbose output
ansible-playbook -vvv -i playbooks/inventory playbooks/deploy.yml
```

### Version not activating

**Problem**: `mise current` shows wrong version

**Solution**:
```bash
# Check mise doctor for issues
mise doctor

# Reinstall the specific version
mise install node@22

# Clear mise cache if needed
rm -rf ~/.local/share/mise/installs/node

# Reinstall
mise install
```

### NPM settings not applied

**Problem**: `npm config list` doesn't show .npmrc settings

**Solution**:
```bash
# Verify symlink exists
ls -la ~/.npmrc

# Check symlink target
readlink ~/.npmrc
# Should point to: ~/.dotmodules/node/files/.npmrc

# Re-create symlink if needed
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --tags stow
```

## Configuration Reference

### Mise Version Specifiers

You can specify versions in several ways:

```toml
[tools]
node = "22"        # Major version (allows 22.x.y)
node = "22.9"      # Minor version (allows 22.9.x)
node = "22.9.0"    # Exact version
node = "lts"       # Latest LTS version
node = "latest"    # Latest version (any)
```

### NPM Configuration Options

Common settings you might want to customize:

```ini
# Package installation
save-exact=false           # Use ranges (^1.0.0) or exact (1.0.0)
save=true                  # Auto-save to package.json

# Engine enforcement
engine-strict=false        # Fail if Node version doesn't match

# Security
audit-level=moderate       # none|low|moderate|high|critical

# UI
progress=true              # Show progress bar
loglevel=warn              # silent|error|warn|info|verbose|silly

# Performance
prefer-offline=false       # Use cache when possible
```

## Advanced Usage

### Multiple Node Versions

If you work with multiple Node versions across projects:

1. Set a reasonable default in dotfiles:
   ```toml
   # modules/node/files/.config/mise/config.toml
   [tools]
   node = "latest"  # Default to latest
   ```

2. Override per project:
   ```toml
   # ~/projects/legacy-app/.mise.toml
   [tools]
   node = "18.19.0"  # Older project needs Node 18
   ```

3. Override per directory tree:
   ```toml
   # ~/projects/.mise.toml (affects all projects in ~/projects/)
   [tools]
   node = "20"  # Default for all projects
   ```

### Machine-Specific NPM Config

For settings that shouldn't be in version control (auth tokens, private registries):

```bash
# Create ~/.npmrc.local (git-ignored)
cat > ~/.npmrc.local <<EOF
//registry.npmjs.org/:_authToken=npm_xxxxxxxxxxxxx
//npm.company.com/:_authToken=company_token_here
EOF

# NPM reads both ~/.npmrc (from dotfiles) and ~/.npmrc.local
npm config list
```

## Examples

### Daily Development

```bash
# Start working on a project
cd ~/projects/myapp

# mise automatically activates configured versions
node --version  # Uses version from mise

# Install project dependencies
pnpm install

# Run development server
pnpm dev
```

### Setting Up New Machine

```bash
# Clone dotfiles
git clone <your-dotfiles-repo> ~/dotfiles
cd ~/dotfiles

# Run deployment
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass

# Activate mise in current shell
eval "$(mise activate zsh)"

# Verify everything works
mise doctor
mise current
```

### Contributing Changes

```bash
# Make changes to node module
vim modules/node/files/.config/mise/config.toml

# Test changes
ansible-playbook -i playbooks/inventory playbooks/deploy.yml
mise current

# Commit changes
git add modules/node/
git commit -m "feat(node): update Node.js to version 23"
git push
```
