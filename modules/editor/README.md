# Editor Configuration Module

This module provides Vim editor configuration with shell integration for both Fish and Zsh.

## Core Features

The module delivers:

- **Vim editor** with customized settings
- **Shell integration** for consistent `EDITOR` environment variable
- **Cross-shell compatibility** with mergeable configuration files

## Installation Components

**Homebrew packages installed:**
- vim

**Configuration files:**
- `.vimrc` or `.config/vim/` - Vim configuration settings
- `.config/fish/config.fish` - Fish shell EDITOR settings (mergeable)
- `.zsh/aliases.sh` - Zsh editor aliases (mergeable)
- `.zsh/environment.sh` - Zsh EDITOR environment variable (mergeable)

## Vim Configuration

The module includes a custom `.vimrc` with sensible defaults for development work. Configuration may include:

- Syntax highlighting
- Line numbers
- Indentation settings
- Search improvements
- Custom key mappings

## Shell Integration

The module sets the `EDITOR` environment variable across both Fish and Zsh shells, ensuring:
- Git uses Vim for commit messages
- Other CLI tools respect your editor preference
- Consistent editing experience across shells

## Basic Vim Usage

### Essential Commands

**Normal mode:**
- `i` - enter insert mode
- `ESC` - return to normal mode
- `:w` - save file
- `:q` - quit
- `:wq` - save and quit
- `:q!` - quit without saving

**Navigation:**
- `h j k l` - left, down, up, right
- `gg` - go to top of file
- `G` - go to bottom of file
- `0` - beginning of line
- `$` - end of line

**Editing:**
- `dd` - delete line
- `yy` - copy line
- `p` - paste
- `u` - undo
- `Ctrl+r` - redo

## Advanced Features

### Search and Replace
```vim
/pattern          " Search forward
?pattern          " Search backward
:s/old/new/g      " Replace in line
:%s/old/new/g     " Replace in file
```

### Multiple Files
```vim
:e filename       " Edit file
:bn               " Next buffer
:bp               " Previous buffer
:bd               " Close buffer
```

## Customization

Edit your `.vimrc` to add personal configurations:
```vim
set number              " Show line numbers
set expandtab           " Use spaces instead of tabs
set tabstop=2           " 2 spaces per tab
set shiftwidth=2        " 2 spaces for indentation
```

## Plugin Management

Consider adding a plugin manager like vim-plug to extend functionality:
- File explorers (NERDTree)
- Fuzzy finding (fzf)
- Git integration (vim-fugitive)
- Language support

## Troubleshooting

**Verify Vim installation:**
```bash
vim --version
```

**Check editor environment variable:**
```bash
echo $EDITOR
```

**Test Vim configuration:**
```bash
vim -u ~/.vimrc
```

**Common issues:**
- If arrow keys produce characters, your terminal may need configuration
- If colors don't work, ensure your terminal supports 256 colors
- Configuration not loading: verify file location and permissions
