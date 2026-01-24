# Claude Code CLI Module

**Module for Claude Code configuration synchronization**

Synchronizes custom statusline and settings across machines.

## Core Features

- **Statusline sync** - Custom p10k-style git status in Claude Code statusline
- **Settings sync** - Base settings.json with statusline configuration

## Installation Components

**Files Deployed:**
- `~/.claude/statusline.js` - Custom statusline with git status display
- `~/.claude/settings.json` - Claude Code settings with statusline config

**Software Required:**
- Claude Code CLI (install manually from https://claude.ai/download)

## Prerequisites

- **Claude Code** - Must be installed manually (not via Homebrew due to corp IT restrictions)
- **Node.js** - Required for statusline.js execution
- **Nerd Font** - For git icons in statusline

## Deployment

Module is automatically deployed when included in `playbooks/deploy.yml`:

```yaml
dotmodules:
  install:
    - claude
```

Run the deployment playbook:

```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass
```

## Configuration

### Editing Statusline

Since files are symlinked, edits can be made directly in the module:

```bash
vim modules/claude/files/.claude/statusline.js
```

Changes are immediately reflected in `~/.claude/`.

### Syncing Changes

After editing, commit and push to sync across machines:

```bash
git add modules/claude/files/.claude/
git commit -m "Update Claude statusline"
git push
```

## Post-Deployment Setup

1. Install Claude Code manually from https://claude.ai/download
2. Authenticate: run `claude` and follow prompts
3. The statusline is automatically configured via the synced settings.json

## Files

```text
modules/claude/
├── config.yml                        # Module configuration
├── README.md                         # This file
└── files/
    └── .claude/
        ├── settings.json             # Claude Code settings
        └── statusline.js             # Custom statusline with git info
```

## Statusline Features

The statusline.js provides:
- Model name display
- Directory name
- Git branch/tag/commit with icons
- Ahead/behind remote counts
- Staged/unstaged/untracked file counts
- Stash count
- Merge/rebase/cherry-pick action indicators
- Context window usage percentage with color coding

## What Is NOT Synced

| Path | Reason |
|------|--------|
| `settings.local.json` | Authentication tokens and machine-specific settings |
| `agents/` | Manage locally per machine |
| `commands/` | Manage locally per machine |
| `get-shit-done/` | GSD framework (manage locally) |
| `hooks/` | May have machine-specific paths |

## References

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

---
*Module follows dotfiles Constitutional principles: modular, idempotent, documented*
