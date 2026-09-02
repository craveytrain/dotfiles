# Shell Utilities Module

This module provides shell-agnostic command-line utilities that enhance productivity across both Fish and Zsh shells.

## Core Features

The module delivers essential modern command-line tools:

- **Shell history** with atuin (searchable, syncable, shared by fish and zsh)
- **Modern file listing** with eza (enhanced ls replacement)
- **Fast code search** with ripgrep (grep alternative)
- **Simplified documentation** via tldr (concise man pages)
- **Safe file deletion** using trash (prevents accidental data loss)
- **File downloading** with wget
- **Dotfile management** via stow (symlink manager)

## Installation Components

**Homebrew packages installed:**
- atuin, eza, ripgrep, tldr, trash, wget, stow

**Configuration files:**
- `.config/fish/conf.d/zz-shell-atuin.fish` - atuin init for fish
- `.zsh/conf.d/80-shell-atuin.sh` - atuin init for zsh

## Key Tools

### eza
Modern replacement for `ls` with better defaults and colors:
- `eza` - basic listing
- `eza -l` - detailed listing
- `eza -la` - include hidden files
- `eza --tree` - tree view

### atuin
Replaces Ctrl-R in both shells with a searchable, optionally synced history:
- **Ctrl-R** - search history
- `atuin stats` - usage statistics
- `atuin login` / `atuin sync` - sync between machines (optional; history works
  locally without an account)

Up-arrow and the `?` AI binding are deliberately disabled, so up-arrow keeps
fish's prefix search and zsh's `history-search-backward`.

The fish fragment is named `zz-` rather than `80-` on purpose. Fish loads
`conf.d` alphabetically and fisher plugin fragments carry no numeric prefix, so
`fzf.fish` sorts after anything starting with a digit. At `80-` atuin's Ctrl-R
binding would be installed and then silently overwritten. Since atuin and
fzf.fish's history search do the same job, the fragment drops fzf's history
binding and leaves its other bindings (Ctrl-Alt-F/L/S, Ctrl-V) alone.

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

These utilities are automatically available after module deployment and work
with any shell (Fish, Zsh, Bash). The only optional step is `atuin login` if you
want history synced between machines; see QUICKSTART.md.

## Troubleshooting

Verify installation by checking command availability:
```bash
which atuin eza rg tldr trash wget stow
```

All commands should return paths under `/opt/homebrew/bin/` or `/usr/local/bin/`.
