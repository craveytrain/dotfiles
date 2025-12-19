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

## Local Configuration

The git module supports local configuration overrides via `.gitconfig.local`. This file is **not tracked in version control** and allows machine-specific settings.

### How It Works

**File location**: `~/.gitconfig.local` (in your home directory - create this file manually)

**Format**: Standard Git config format (same as `.gitconfig`)

**Loading**: The base `.gitconfig` automatically includes `~/.gitconfig.local` if it exists via the `[include]` directive. Settings in the local file override base configuration.

**Creation**: Create this file manually in your home directory when you need machine-specific settings. If the file doesn't exist, Git loads normally without errors.

### When to Use Local Configuration

Create `~/.gitconfig.local` when you need:
- Different user identity on work vs. personal machines
- Machine-specific signing keys or GPG settings
- Custom aliases for specific workflows
- Company-specific Git settings (e.g., custom remote URLs)

### Example 1: Machine-Specific User Identity

This is the most common use case - maintaining different identities on different machines.

Create `~/.gitconfig.local`:

```ini
[user]
    name = Your Name (Work Laptop)
    email = work@company.com
    signingkey = ABC123DEF456
```

This overrides the base user settings for this machine only, while leaving your dotfiles repository unchanged.

### Example 2: Machine-Specific Signing Key

Add GPG signing configuration for this machine:

```ini
[user]
    signingkey = 1234567890ABCDEF

[commit]
    gpgsign = true
```

### Example 3: Custom Work Aliases

Add machine-specific aliases for work workflows:

```ini
[alias]
    work-push = !git push origin $(git rev-parse --abbrev-ref HEAD)
    sync-main = !git checkout main && git pull origin main

[url "https://github.company.com/"]
    insteadOf = company:
```

### How to Create

Create the file manually in your home directory:

```bash
# Create the local config file
vim ~/.gitconfig.local

# Add your machine-specific settings
[user]
    name = Your Name (Work Laptop)
    email = work@company.com
```

The file will be automatically loaded on your next Git command.

### Verify It Works

Check that your local config is being loaded:

```bash
# Show all config with sources
git config --list --show-origin | grep gitconfig.local

# Check effective user identity
git config user.name
git config user.email
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
