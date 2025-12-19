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
