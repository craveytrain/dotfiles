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
