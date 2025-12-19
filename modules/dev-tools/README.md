# Development Tools Module

This module provides essential command-line development utilities for modern software development workflows.

## Core Features

The module delivers:

- **Runtime management** with mise (asdf alternative)
- **Code quality tools** for shell scripts and GitHub Actions
- **Networking utilities** for debugging and analysis
- **Data processing** tools for JSON and text
- **Shell integration** with mergeable configuration files

## Installation Components

**Homebrew packages installed:**
- mise - Polyglot runtime manager (Node, Ruby, Python, etc.)
- jq - Command-line JSON processor
- shellcheck - Shell script static analysis
- actionlint - GitHub Actions workflow linter
- bat - Cat clone with syntax highlighting
- ngrep - Network packet grep
- nmap - Network exploration and security auditing

**Configuration files:**
- `.zshrc` - Zsh mise integration (mergeable)
- `.config/fish/config.fish` - Fish mise integration (mergeable)
- Additional tool-specific configs in `.config/`

## Key Tools

### mise
Modern runtime version manager supporting multiple languages:

**Basic usage:**
```bash
mise install node@20              # Install Node.js 20
mise install python@3.11          # Install Python 3.11
mise use -g node@20               # Set global Node version
mise use python@3.11              # Set local project version
```

**Per-project versions:**
Create `.mise.toml` in your project:
```toml
[tools]
node = "20"
python = "3.11"
```

**List installed tools:**
```bash
mise list
```

### jq
Process JSON data from command line:

```bash
echo '{"name":"John","age":30}' | jq '.name'
curl api.example.com/data | jq '.items[]'
cat data.json | jq '.[] | select(.active == true)'
```

### shellcheck
Analyze shell scripts for common issues:

```bash
shellcheck script.sh              # Check script
shellcheck -f json script.sh      # JSON output
shellcheck -x script.sh           # Follow sourced files
```

### actionlint
Validate GitHub Actions workflows:

```bash
actionlint                        # Check .github/workflows/
actionlint workflow.yml           # Check specific file
actionlint -color                 # Colored output
```

### bat
Enhanced cat with syntax highlighting and Git integration:

```bash
bat file.js                       # View with syntax highlighting
bat -A file.txt                   # Show all characters
bat --style=plain file.md         # Plain output
```

### ngrep
Network packet analyzer with grep-like interface:

```bash
sudo ngrep -q 'HTTP'              # Monitor HTTP traffic
sudo ngrep -W byline port 80      # Watch port 80
```

### nmap
Network scanning and security auditing:

```bash
nmap localhost                    # Scan local ports
nmap -A example.com               # Aggressive scan
nmap -sn 192.168.1.0/24          # Network discovery
```

## mise Configuration

After installation, activate mise in your shell (already configured via mergeable files):

**Verify activation:**
```bash
mise doctor
```

**Configure default tools:**
```bash
mise use -g node@lts              # Latest LTS Node
mise use -g python@latest         # Latest Python
```

## Shell Integration

The module automatically configures mise activation in both Fish and Zsh via mergeable configuration files, ensuring seamless runtime management across shells.

## Local Configuration

Some tools in this module (npm, mise, bat) don't support local config files but respect environment variables that override their base configuration. You can set these environment variables in your shell's local config file.

**How it works**:
1. Create your shell's local config file manually when needed:
   - For zsh: `~/.zshrc.local`
   - For fish: `~/.config/fish/config.local.fish`
2. Add environment variables to override tool configurations (see examples below)
3. Environment variables take precedence over config file settings
4. Restart your shell or source the local config file to apply changes

**Note**: Local config files are not tracked in version control. Create them manually based on the examples below when you need machine-specific overrides.

### npm Configuration Overrides

Override npm settings via environment variables in your shell local config:

**Zsh** (`~/.zshrc.local` - create this file manually):
```bash
# Override npm registry
export NPM_CONFIG_REGISTRY=https://registry.example.com

# Override npm cache directory
export NPM_CONFIG_CACHE=~/.npm-cache-custom

# Override npm prefix directory
export NPM_CONFIG_PREFIX=~/.npm-global

# Override npm init defaults
export NPM_CONFIG_INIT_AUTHOR_NAME="Your Name"
export NPM_CONFIG_INIT_AUTHOR_EMAIL="your.email@example.com"
```

**Fish** (`~/.config/fish/config.local.fish` - create this file manually):
```fish
# Override npm registry
set -gx NPM_CONFIG_REGISTRY https://registry.example.com

# Override npm cache directory
set -gx NPM_CONFIG_CACHE ~/.npm-cache-custom

# Override npm prefix directory
set -gx NPM_CONFIG_PREFIX ~/.npm-global

# Override npm init defaults
set -gx NPM_CONFIG_INIT_AUTHOR_NAME "Your Name"
set -gx NPM_CONFIG_INIT_AUTHOR_EMAIL "your.email@example.com"
```

**Precedence**: Environment variables > per-project `.npmrc` > per-user `~/.npmrc` > global config

**Available Variables**:
- `NPM_CONFIG_REGISTRY` - Override npm registry URL
- `NPM_CONFIG_PREFIX` - Override global install prefix
- `NPM_CONFIG_CACHE` - Override cache directory
- `NPM_CONFIG_INIT_AUTHOR_NAME` - Override default author name
- `NPM_CONFIG_INIT_AUTHOR_EMAIL` - Override default author email

### mise Configuration Overrides

Override mise settings via environment variables:

**Zsh** (`~/.zshrc.local`):
```bash
# Override mise config file location
export MISE_CONFIG_FILE=~/.config/mise/config-custom.toml

# Override mise data directory (where tools are installed)
export MISE_DATA_DIR=~/.local/share/mise-custom

# Override mise log level
export MISE_LOG_LEVEL=debug
```

**Fish** (`~/.config/fish/config.local.fish`):
```fish
# Override mise config file location
set -gx MISE_CONFIG_FILE ~/.config/mise/config-custom.toml

# Override mise data directory (where tools are installed)
set -gx MISE_DATA_DIR ~/.local/share/mise-custom

# Override mise log level
set -gx MISE_LOG_LEVEL debug
```

**Available Variables**:
- `MISE_CONFIG_FILE` - Override default config file location (`~/.config/mise/config.toml`)
- `MISE_DATA_DIR` - Override data directory (`~/.local/share/mise` or `$XDG_DATA_HOME/mise`)
- `MISE_LOG_LEVEL` - Control logging verbosity (e.g., "debug", "info", "warn", "error")

### bat Configuration Overrides

Override bat settings via environment variables:

**Zsh** (`~/.zshrc.local`):
```bash
# Override bat theme (run `bat --list-themes` to see available themes)
export BAT_THEME=Dracula

# Override bat style (e.g., "numbers,changes,grid")
export BAT_STYLE="numbers,changes"

# Override bat pager
export BAT_PAGER="less -R"
```

**Fish** (`~/.config/fish/config.local.fish`):
```fish
# Override bat theme (run `bat --list-themes` to see available themes)
set -gx BAT_THEME Dracula

# Override bat style (e.g., "numbers,changes,grid")
set -gx BAT_STYLE "numbers,changes"

# Override bat pager
set -gx BAT_PAGER "less -R"
```

**Available Variables**:
- `BAT_THEME` - Override theme (run `bat --list-themes` to see available themes)
- `BAT_STYLE` - Override style (e.g., "numbers,changes,header")
- `BAT_PAGER` - Override pager setting

**Precedence**: Command-line options > environment variables > config file

**Note**: Create your shell's local config file manually (`~/.zshrc.local` or `~/.config/fish/config.local.fish`) and add the environment variables you need. See the zsh or fish module READMEs for instructions on creating local config files.

## Troubleshooting

**Verify installations:**
```bash
mise --version
jq --version
shellcheck --version
actionlint --version
bat --version
```

**mise not working:**
```bash
mise doctor                       # Diagnose issues
which mise                        # Verify installation
```

**Tools not in PATH:**
Ensure shell configuration is loaded:
```bash
exec zsh                          # Reload Zsh
exec fish                         # Reload Fish
```

**JSON parsing errors with jq:**
Validate JSON first:
```bash
cat data.json | jq empty          # Check if valid JSON
```

**nmap/ngrep require sudo:**
These tools need elevated privileges for network analysis:
```bash
sudo nmap localhost
sudo ngrep -q 'pattern'
```
