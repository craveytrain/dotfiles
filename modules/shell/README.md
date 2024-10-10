# Shell Utilities Module

This module provides shell-agnostic command-line utilities that enhance productivity across both Fish and Zsh shells.

## Core Features

The module delivers essential modern command-line tools:

- **Modern file listing** with eza (enhanced ls replacement)
- **Fast code search** with ripgrep (grep alternative)
- **Simplified documentation** via tldr (concise man pages)
- **Safe file deletion** using trash (prevents accidental data loss)
- **File downloading** with wget
- **Dotfile management** via stow (symlink manager)

## Installation Components

**Homebrew packages installed:**
- eza, ripgrep, tldr, trash, wget, stow

**Homebrew taps:**
- homebrew/bundle
- homebrew/services

**Configuration files:**
- None (this module only provides packages, no config files)

## Key Tools

### eza
Modern replacement for `ls` with better defaults and colors:
- `eza` - basic listing
- `eza -l` - detailed listing
- `eza -la` - include hidden files
- `eza --tree` - tree view

### ripgrep
Blazingly fast code search tool:
- `rg "pattern"` - search in current directory
- `rg -i "pattern"` - case-insensitive search
- `rg -t js "pattern"` - search only JavaScript files

### tldr
Community-driven simplified man pages:
- `tldr tar` - show common tar examples
- `tldr git` - show common git examples

### trash
Safe alternative to `rm`:
- `trash file.txt` - move to trash instead of permanent deletion
- Can be recovered from system trash if needed

### wget
Download files from the web:
- `wget https://example.com/file.zip`
- `wget -c https://example.com/large-file.iso` - resume interrupted downloads

## Usage Notes

These utilities are automatically available after module deployment and work with any shell (Fish, Zsh, Bash). No additional configuration required.

## Troubleshooting

Verify installation by checking command availability:
```bash
which eza ripgrep tldr trash wget stow
```

All commands should return paths under `/opt/homebrew/bin/` or `/usr/local/bin/`.
