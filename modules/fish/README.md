# Fish Shell Module

This module provides a complete Fish shell environment with plugin management via Fisher.

## Core Features

The module provides:

- **Fish shell** with intelligent autosuggestions and syntax highlighting
- **Fisher plugin manager** for extending functionality
- **Custom configuration** merged with other module settings
- **Shell registration** automatically adds Fish to `/etc/shells`

## Installation Components

**Homebrew packages installed:**
- fish
- fisher

**Configuration files:**
- `.config/fish/config.fish` - Main Fish configuration (mergeable with other modules)

**Shell registration:**
- Automatically registers Fish shell in `/etc/shells` for system use

## Post-Deployment Setup

After running the Ansible playbook, complete the Fisher setup:

1. **Launch Fish shell:**
   ```bash
   fish
   ```

2. **Install Fisher plugins:**
   ```fish
   fisher update
   ```

This installs all Fisher plugins defined in your `config.fish` file.

## Fish Features

### Autosuggestions
Fish suggests commands as you type based on history and completions:
- Press **→** (right arrow) to accept suggestion
- Press **Alt+→** to accept one word at a time

### Syntax Highlighting
Commands are colored as you type:
- **Green** - valid command
- **Red** - invalid command or path
- **Blue** - existing path or file

### Web-based Configuration
Launch Fish's web interface for visual configuration:
```fish
fish_config
```

## Configuration Management

Fish configuration is mergeable, meaning multiple modules can contribute settings to your `config.fish` file. This allows modular configuration management across different tools and environments.

## Local Configuration

The fish module supports local configuration overrides via `config.local.fish`. This file is **not tracked in version control** and allows machine-specific settings.

### How It Works

**File location**: `~/.config/fish/config.local.fish` (in your Fish config directory - create this file manually)

**Format**: Fish shell script (same syntax as `config.fish`)

**Loading**: The base `config.fish` automatically sources `~/.config/fish/config.local.fish` at the end if it exists via conditional source. Settings in the local file are loaded last, overriding base configuration.

**Creation**: Create this file manually in your Fish config directory when you need machine-specific settings. If the file doesn't exist, Fish loads normally without errors.

### When to Use Local Configuration

Create `~/.config/fish/config.local.fish` when you need:
- Machine-specific PATH additions (work directories, custom tools)
- Private environment variables (API keys, credentials, tokens)
- Custom abbreviations for specific workflows or projects
- Work-specific proxy settings or configurations
- Environment variable overrides for tools like npm, mise, bat

### Example 1: Machine-Specific PATH

This is useful for adding work directories or project-specific tools to your PATH.

Create `~/.config/fish/config.local.fish`:

```fish
# Add work tools to PATH
fish_add_path ~/work/tools/bin
fish_add_path ~/projects/scripts

# Add custom binaries
fish_add_path ~/.local/bin
```

Fish's `fish_add_path` ensures paths are only added once and handles duplicates intelligently.

### Example 2: Private Environment Variables

Store sensitive credentials and API keys that shouldn't be in version control.

```fish
# API keys and tokens
set -gx GITHUB_TOKEN "ghp_xxxxxxxxxxxxxxxxxxxx"
set -gx API_KEY "your-secret-api-key"
set -gx AWS_PROFILE "work-profile"

# Work-specific settings
set -gx WORK_PROXY "http://proxy.company.com:8080"
set -gx HTTP_PROXY "$WORK_PROXY"
set -gx HTTPS_PROXY "$WORK_PROXY"
```

Note: `set -gx` sets global exported variables (equivalent to `export` in bash/zsh).

### Example 3: Machine-Specific Abbreviations and Functions

Add shortcuts for your specific workflow or projects.

```fish
# Project navigation
abbr work "cd ~/Work/main-project"
abbr personal "cd ~/Projects/personal"

# Machine-specific shortcuts
abbr vpn-connect "sudo openvpn --config ~/work.ovpn"
abbr ssh-work "ssh -i ~/.ssh/work_key user@work-server"

# Custom functions
function deploy
    cd ~/Work/deployment
    ./deploy.sh $argv
end
```

### Example 4: Environment Variable Overrides for Tools

Override configuration for tools that don't support local config files (see dev-tools module for available variables).

```fish
# npm overrides
set -gx NPM_CONFIG_REGISTRY "https://registry.company.com"
set -gx NPM_CONFIG_PREFIX "$HOME/.npm-global"

# mise overrides
set -gx MISE_LOG_LEVEL "debug"
set -gx MISE_DATA_DIR "$HOME/.local/share/mise-custom"

# bat overrides
set -gx BAT_THEME "Monokai Extended Light"
set -gx BAT_STYLE "numbers,changes,header"
```

### How to Create

Create the file manually in your Fish config directory:

```fish
# Create the directory if it doesn't exist
mkdir -p ~/.config/fish

# Create the local config file
vim ~/.config/fish/config.local.fish

# Add your machine-specific settings
fish_add_path ~/work/bin
set -gx GITHUB_TOKEN "ghp_xxxxxxxxxxxxxxxxxxxx"
```

The file will be automatically loaded on your next Fish session.

### Reload Configuration

After creating or modifying `config.local.fish`:

```fish
# Reload fish configuration
source ~/.config/fish/config.fish

# Or restart the shell
exec fish
```

### Verify It Works

Check that your local config is being loaded:

```fish
# Check if file exists
test -f ~/.config/fish/config.local.fish; and echo "Local config exists"; or echo "No local config"

# Verify environment variables
echo $PATH  # Should include your custom paths
env | grep YOUR_VARIABLE  # Check specific variables

# Check abbreviations
abbr | grep work  # List your custom abbreviations
```

## Making Fish Your Default Shell

To set Fish as your default shell:
```bash
chsh -s /opt/homebrew/bin/fish
```

Or if Fish is installed via system package manager:
```bash
chsh -s /usr/local/bin/fish
```

## Troubleshooting

**Verify Fish installation:**
```bash
which fish
fish --version
```

**Check if Fish is registered:**
```bash
cat /etc/shells | grep fish
```

**Fisher not working:**
Ensure you've run `fisher update` from within a Fish shell session.
