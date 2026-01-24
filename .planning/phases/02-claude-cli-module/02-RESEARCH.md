# Phase 2: Claude CLI Module - Research

**Researched:** 2026-01-24
**Domain:** Claude Code CLI configuration management and dotfiles synchronization
**Confidence:** HIGH

## Summary

This phase adds a Claude CLI configuration module to synchronize Claude Code settings, agents, commands, and memory files across machines. Claude Code (version 2.1.19 as of research) is available via Homebrew cask `claude-code` and stores configuration in `~/.claude/` directory with a well-documented hierarchy of settings scopes.

The key challenge is distinguishing between files that SHOULD be synced (settings, agents, commands, rules, CLAUDE.md) versus files that MUST NOT be synced (local settings with machine-specific paths, authentication state, session data, caches). The official documentation clearly delineates these scopes.

**Primary recommendation:** Create a module that syncs `settings.json`, `agents/`, `commands/`, `rules/`, and `CLAUDE.md` while documenting that `settings.local.json` and authentication must be configured per-machine.

## Standard Stack

The established tools for this domain:

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| claude-code | 2.1.19+ | Homebrew cask | Official distribution, provides `claude` binary |
| ansible-role-dotmodules | current | Module deployment | Existing pattern in this dotfiles repo |
| GNU Stow | 2.x | Symlink management | Used by all existing modules |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Homebrew | 4.x | Package management | macOS package installation |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Homebrew cask | Native install script | Native has auto-updates, but Homebrew integrates with existing module pattern |
| Stow for all ~/.claude | Selective stow | Some files (settings.local.json, caches) MUST NOT be synced |

**Installation:**
```bash
brew install --cask claude-code
```

## Architecture Patterns

### Recommended Module Structure
```
modules/claude/
├── config.yml                      # Module config for ansible-role-dotmodules
├── README.md                       # Module documentation with auth instructions
└── files/
    └── .claude/
        ├── settings.json           # User-level settings (synced)
        ├── CLAUDE.md               # User-level memory (synced)
        ├── agents/                 # Custom agents (synced)
        │   └── *.md
        ├── commands/               # Custom slash commands (synced)
        │   └── *.md
        └── rules/                  # User-level rules (synced)
            └── *.md
```

### Pattern 1: Selective Configuration Sync
**What:** Only sync shareable user-level configuration, not machine-specific or sensitive files
**When to use:** Always - this is the core pattern
**Why:** Claude Code has explicit scopes (user vs local) that define what should/shouldn't be shared

Files to SYNC:
- `settings.json` - User preferences (status line, model preferences without paths)
- `CLAUDE.md` - User memory/instructions
- `agents/*.md` - Custom agent definitions
- `commands/**/*.md` - Custom slash commands
- `rules/*.md` - User-level rules

Files to NEVER SYNC:
- `settings.local.json` - Contains machine-specific paths, AWS profiles, permissions
- `.claude.json` (in home dir) - OAuth tokens, MCP servers with local paths
- `history.jsonl` - Session history
- `stats-cache.json` - Local statistics
- `projects/` - Per-project trust state
- `cache/`, `debug/`, `file-history/`, `todos/`, `plans/` - Session data

### Pattern 2: Config-Only Module
**What:** Module provides configuration files only, software installed via Homebrew cask
**When to use:** When software installation is separate from configuration
**Example:**
```yaml
# config.yml
---
homebrew_casks:
  - claude-code

stow_dirs:
  - claude
```

### Anti-Patterns to Avoid
- **Syncing settings.local.json:** Contains machine-specific paths and AWS profiles
- **Syncing .claude.json:** Contains OAuth tokens and machine-specific MCP server paths
- **Syncing caches/session data:** Creates conflicts and bloats the repo
- **Hardcoding absolute paths in settings.json:** Use relative paths or env vars where possible

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Claude installation | Custom script | `homebrew_casks: [claude-code]` | Existing module pattern handles casks |
| Config deployment | Copy scripts | GNU Stow via `stow_dirs` | Existing pattern, maintains symlinks |
| Agent management | Manual file copying | Stow symlinks to agents/ | Changes sync immediately |

**Key insight:** The existing ansible-role-dotmodules pattern handles everything. Just define the module structure correctly.

## Common Pitfalls

### Pitfall 1: Syncing Machine-Specific Settings
**What goes wrong:** settings.local.json contains AWS profiles, machine-specific paths, permission rules with absolute paths
**Why it happens:** All settings look the same at first glance
**How to avoid:** Only stow the `.claude/` subdirectory with carefully selected files, NOT all of ~/.claude/
**Warning signs:** Paths like `/Users/username/` in synced files, AWS_PROFILE values

### Pitfall 2: Forgetting Post-Deployment Authentication
**What goes wrong:** User deploys module but Claude Code doesn't work because auth state isn't synced
**Why it happens:** Auth tokens are machine-specific and cannot be synced
**How to avoid:** Document authentication step clearly in README.md
**Warning signs:** Claude Code prompts for login after deployment

### Pitfall 3: Stow Conflicts with Existing ~/.claude Directory
**What goes wrong:** Stow fails because ~/.claude already exists with non-symlinked files
**Why it happens:** Claude Code creates ~/.claude on first run before module deployment
**How to avoid:** Document that existing ~/.claude contents may need backup/merging
**Warning signs:** `stow --no-folding` errors about existing directories

### Pitfall 4: Syncing Hooks with Hardcoded Paths
**What goes wrong:** hooks/ files contain absolute paths to scripts or node modules
**Why it happens:** Hooks often reference machine-specific locations
**How to avoid:** Either don't sync hooks, or ensure they use relative paths/env vars
**Warning signs:** Commands like `node "/Users/specific-user/.claude/hooks/script.js"`

## Code Examples

### Module config.yml
```yaml
# Source: Existing ghostty module pattern
---
# Claude Code CLI configuration module
# Provides Claude Code settings, agents, and commands

homebrew_casks:
  - claude-code

stow_dirs:
  - claude
```

### Recommended settings.json (syncable)
```json
{
  "statusLine": {
    "type": "static",
    "content": "Claude Code"
  }
}
```
Note: Avoid `type: "command"` with absolute paths. Use static or ensure commands are portable.

### Example CLAUDE.md (user memory)
```markdown
# User Preferences

- Prefer TypeScript over JavaScript
- Use 2-space indentation
- Always run tests before committing
```

### Agent file format
```markdown
---
name: example-agent
description: Description of what this agent does
tools: Read, Write, Bash, Glob, Grep
color: cyan
---

<role>
Agent instructions here...
</role>
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual config copying | Dotfiles sync via Stow | Current | Enables consistent config across machines |
| Native install only | Homebrew cask available | Recent | Integrates with existing Homebrew patterns |

**Current best practice:**
- Claude Code 2.1.19 supports both native and Homebrew installation
- Configuration hierarchy: Managed > CLI > Local > Project > User
- User-level settings in `~/.claude/settings.json` are designed to be shareable
- Local settings in `settings.local.json` are designed to be machine-specific

## Open Questions

Things that couldn't be fully resolved:

1. **hooks/ directory portability**
   - What we know: Hooks can reference absolute paths to scripts
   - What's unclear: Whether user wants to sync hooks and if so, how to make them portable
   - Recommendation: Start without syncing hooks. Add later if needed with portable paths.

2. **MCP server configuration (.claude.json)**
   - What we know: MCP servers are configured in ~/.claude.json with potentially machine-specific paths
   - What's unclear: Whether user uses MCP servers that need syncing
   - Recommendation: Don't sync .claude.json initially. MCP config can be added per-machine.

3. **Existing ~/.claude content handling**
   - What we know: User already has substantial ~/.claude directory
   - What's unclear: Which existing files should be migrated into the module
   - Recommendation: Phase implementation should audit existing content and migrate selectively

## Sources

### Primary (HIGH confidence)
- https://code.claude.com/docs/en/settings - Official settings documentation
- https://code.claude.com/docs/en/memory - Official memory/CLAUDE.md documentation
- https://code.claude.com/docs/en/quickstart - Installation methods
- Homebrew formula: `brew info claude-code` - Version 2.1.19, cask installation

### Secondary (MEDIUM confidence)
- Existing dotfiles modules (ghostty, git) - Pattern verification
- Local ~/.claude directory inspection - Current user configuration structure

### Tertiary (LOW confidence)
- None - all findings verified with official sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Verified with Homebrew and official docs
- Architecture: HIGH - Derived from official settings/memory documentation
- Pitfalls: MEDIUM - Based on inspection of user's current setup + documentation

**Research date:** 2026-01-24
**Valid until:** 30 days (Claude Code is actively developed but config format is stable)
