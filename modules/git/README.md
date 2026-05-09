# Git Configuration Module

This module establishes a comprehensive Git development environment with enhanced diff tools and GitHub CLI integration.

> **Migration note (May 2026):** Git config moved to the XDG layout (`~/.config/git/config`) from the legacy `~/.gitconfig` location. Re-run the Ansible playbook to refresh symlinks. If you had a `~/.gitconfig.local` with machine-specific identity, move it manually:
> ```bash
> mv ~/.gitconfig.local ~/.config/git/local
> ```

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

**Configuration files (XDG layout):**
- `~/.config/git/config` — main git configuration
- `~/.config/git/ignore` — global gitignore (auto-detected by git)
- `~/.config/git/macos` — Mac-only settings (auto-included; ignored on other OSes)
- `~/.config/git/local` — machine-specific overrides (auto-included; create manually)

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

The `~/.config/git/config` file includes sensible defaults for:

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

The git module supports local configuration overrides via `~/.config/git/local`. This file is **not tracked in version control** and allows machine-specific settings.

### How It Works

**File location**: `~/.config/git/local` (in your home directory - create this file manually)

**Format**: Standard Git config format (same as `~/.config/git/config`)

**Loading**: The base `~/.config/git/config` automatically includes `~/.config/git/local` if it exists via the `[include]` directive. Settings in the local file override base configuration.

**Creation**: Create this file manually in your home directory when you need machine-specific settings. If the file doesn't exist, Git loads normally without errors.

### When to Use Local Configuration

Create `~/.config/git/local` when you need:
- Different user identity on work vs. personal machines
- Machine-specific signing keys or GPG settings
- Custom aliases for specific workflows
- Company-specific Git settings (e.g., custom remote URLs)

### Example 1: Machine-Specific User Identity

This is the most common use case - maintaining different identities on different machines.

Create `~/.config/git/local`:

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
vim ~/.config/git/local

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
git config --list --show-origin | grep "config/git/local"

# Check effective user identity
git config user.name
git config user.email
```

## Git Aliases

Check your `~/.config/git/config` for configured aliases. Common patterns include:

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

Or set it as your default diff tool in `~/.config/git/config`.

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
Ensure your `~/.config/git/config` properly references the diff tool paths:
```bash
which diff-so-fancy
which difftastic
```
