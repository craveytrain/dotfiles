# Git Configuration Module

This module establishes a comprehensive Git development environment with enhanced diff tools and GitHub CLI integration.

## Core Features

The module provides:

- **Git version control** with optimized configuration
- **GitHub CLI (gh)** for repository and workflow management
- **Enhanced diff tools** with diff-so-fancy and difftastic
- **Custom Git configuration** including aliases, colors, and behaviors

## Installation Components

**Homebrew packages installed:**
- git
- gh (GitHub CLI)
- diff-so-fancy (readable diffs with better formatting)
- difftastic (structural diff tool that understands syntax)

**Configuration files:**
- `.gitconfig` - Git configuration with user settings, aliases, and diff tools
- Additional Git-related dotfiles in `.config/git/`

## GitHub CLI (gh)

The GitHub CLI provides command-line access to GitHub features:

### Authentication
```bash
gh auth login
```

### Common Commands
```bash
gh repo clone owner/repo          # Clone repository
gh repo create my-new-repo        # Create new repository
gh pr list                         # List pull requests
gh pr create                       # Create pull request
gh pr checkout 123                 # Checkout PR #123
gh issue list                      # List issues
gh issue create                    # Create new issue
```

## Enhanced Diff Tools

### diff-so-fancy
Provides human-readable diffs with:
- Better color schemes
- Clearer headers and markers
- Improved readability for code reviews

### difftastic
Structural diff tool that:
- Understands code syntax
- Shows semantic differences
- Supports multiple languages
- Highlights actual changes more accurately

## Git Configuration

The `.gitconfig` file includes sensible defaults for:

- **User settings** - name, email (configure these for your identity)
- **Color output** - enhanced readability for status, diff, branch
- **Aliases** - productivity shortcuts
- **Diff tools** - integration with diff-so-fancy or difftastic
- **Merge strategies** - conflict resolution preferences

### Configure Your Identity

After installation, set your Git identity:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Git Aliases

Check your `.gitconfig` for configured aliases. Common patterns include:

```bash
git st                  # Status
git co                  # Checkout
git br                  # Branch
git ci                  # Commit
git unstage            # Remove from staging area
```

## Using Difftastic

To use difftastic for a specific diff:
```bash
git difftool
```

Or set it as your default diff tool in `.gitconfig`.

## Troubleshooting

**Verify installations:**
```bash
git --version
gh --version
diff-so-fancy --version
difftastic --version
```

**Check Git configuration:**
```bash
git config --list
```

**GitHub CLI not authenticated:**
Run `gh auth login` and follow the interactive prompts.

**Diff tools not working:**
Ensure your `.gitconfig` properly references the diff tool paths:
```bash
which diff-so-fancy
which difftastic
```
