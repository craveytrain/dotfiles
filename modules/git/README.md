# Git

Installs Git, GitHub CLI, diff-so-fancy, and difftastic. It stows the shared Git config, global ignore file, GitHub CLI config, macOS-specific settings, and small Git helper scripts.

Set identity and other machine-specific values in `~/.config/git/local`:

```gitconfig
[user]
    name = Your Name
    email = you@example.com
```

The shared config includes that file when present. Authenticate GitHub separately on each machine:

```bash
gh auth login
```
