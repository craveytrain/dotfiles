# Zsh Shell Module

This module provides a modern Zsh shell environment with Powerlevel10k prompt theme and custom configurations.

## Core Features

The module delivers:

- **Zsh shell** with advanced completion and line editing
- **Powerlevel10k prompt** for fast, customizable shell prompts
- **Custom aliases** for enhanced productivity
- **Environment configuration** with mergeable settings
- **Integration** with eza for modern file listing (from shell module)

## Installation Components

**Homebrew packages installed:**
- zsh
- powerlevel10k

**Configuration files:**
- `.zshrc` - Main Zsh configuration (mergeable)
- `.zsh/aliases.sh` - Custom shell aliases (mergeable)
- `.zsh/environment.sh` - Environment variables and settings (mergeable)

## Mergeable Configuration

This module uses mergeable configuration files, allowing other modules (like git, editor, dev-tools) to contribute their own aliases and environment settings without conflicts.

## Powerlevel10k Prompt

Powerlevel10k provides a highly customizable and fast prompt with:
- Git status integration
- Command execution time
- Exit code indicators
- Background job notifications
- Directory truncation

### Initial Setup

On first launch, Powerlevel10k will run its configuration wizard:
```bash
zsh
```

Follow the interactive prompts to customize your prompt appearance.

### Reconfigure Prompt

To reconfigure your prompt at any time:
```bash
p10k configure
```

## Common Aliases

The module may include productivity aliases. Check `.zsh/aliases.sh` for available shortcuts.

Common patterns:
- Modern `ls` alternatives using eza (from shell module)
- Git shortcuts (from git module if installed)
- Editor shortcuts (from editor module if installed)

## Environment Configuration

The `.zsh/environment.sh` file contains shell-wide environment variables and settings that apply across your Zsh sessions.

## Making Zsh Your Default Shell

Zsh is typically the default shell on modern macOS. To verify or set:
```bash
echo $SHELL
```

To change to Zsh if needed:
```bash
chsh -s /bin/zsh
```

## Configuration Loading

Zsh loads configuration in this order:
1. `.zshenv` - Environment variables
2. `.zprofile` - Login shell configuration
3. `.zshrc` - Interactive shell configuration (main config)
4. `.zlogin` - Login shell final setup
5. `.zshrc.local` - Local configuration (machine-specific overrides, loaded at end of `.zshrc`)

## Local Configuration

The zsh module supports local configuration overrides via `.zshrc.local`. This file is **not tracked in version control** and allows machine-specific settings.

### How It Works

**File location**: `~/.zshrc.local` (in your home directory - create this file manually)

**Format**: Zsh shell script (same syntax as `.zshrc`)

**Loading**: The base `.zshrc` automatically sources `~/.zshrc.local` at the end if it exists via conditional source. Settings in the local file are loaded last, overriding base configuration.

**Creation**: Create this file manually in your home directory when you need machine-specific settings. If the file doesn't exist, Zsh loads normally without errors.

### When to Use Local Configuration

Create `~/.zshrc.local` when you need:
- Machine-specific PATH additions (work directories, custom tools)
- Private environment variables (API keys, credentials, tokens)
- Custom aliases for specific workflows or projects
- Work-specific proxy settings or configurations
- Environment variable overrides for tools like npm, mise, bat

### Example 1: Machine-Specific PATH

This is useful for adding work directories or project-specific tools to your PATH.

Create `~/.zshrc.local`:

```bash
# Add work tools to PATH
export PATH="$HOME/work/tools/bin:$PATH"
export PATH="$HOME/projects/scripts:$PATH"

# Add custom binaries
export PATH="$HOME/.local/bin:$PATH"
```

### Example 2: Private Environment Variables

Store sensitive credentials and API keys that shouldn't be in version control.

```bash
# API keys and tokens
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
export API_KEY="your-secret-api-key"
export AWS_PROFILE="work-profile"

# Work-specific settings
export WORK_PROXY="http://proxy.company.com:8080"
export HTTP_PROXY="$WORK_PROXY"
export HTTPS_PROXY="$WORK_PROXY"
```

### Example 3: Machine-Specific Aliases and Functions

Add shortcuts for your specific workflow or projects.

```bash
# Project navigation
alias work="cd ~/Work/main-project"
alias personal="cd ~/Projects/personal"

# Machine-specific shortcuts
alias vpn-connect="sudo openvpn --config ~/work.ovpn"
alias ssh-work="ssh -i ~/.ssh/work_key user@work-server"

# Custom functions
deploy() {
    cd ~/Work/deployment && ./deploy.sh "$@"
}
```

### Example 4: Environment Variable Overrides for Tools

Override configuration for tools that don't support local config files (see dev-tools module for available variables).

```bash
# npm overrides
export NPM_CONFIG_REGISTRY="https://registry.company.com"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# mise overrides
export MISE_LOG_LEVEL="debug"
export MISE_DATA_DIR="$HOME/.local/share/mise-custom"

# bat overrides
export BAT_THEME="Monokai Extended Light"
export BAT_STYLE="numbers,changes,header"
```

### How to Create

Create the file manually in your home directory:

```bash
# Create the local config file
vim ~/.zshrc.local

# Add your machine-specific settings
export PATH="$HOME/work/bin:$PATH"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
```

The file will be automatically loaded on your next Zsh session.

### Reload Configuration

After creating or modifying `.zshrc.local`:

```bash
# Reload zsh configuration
source ~/.zshrc

# Or restart the shell
exec zsh
```

### Verify It Works

Check that your local config is being loaded:

```bash
# Check if file exists and is being sourced
test -f ~/.zshrc.local && echo "Local config exists" || echo "No local config"

# Verify environment variables
echo $PATH  # Should include your custom paths
env | grep YOUR_VARIABLE  # Check specific variables
```

## Troubleshooting

**Verify Zsh installation:**
```bash
zsh --version
```

**Check Powerlevel10k:**
```bash
echo $POWERLEVEL9K_MODE
```

**Reload configuration:**
```bash
source ~/.zshrc
```

Or simply:
```bash
exec zsh
```

**Mergeable files not working:**
Ensure the ansible-role-dotmodules is properly processing mergeable files during deployment.
