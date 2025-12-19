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
