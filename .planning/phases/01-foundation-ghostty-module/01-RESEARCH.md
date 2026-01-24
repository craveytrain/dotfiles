# Phase 1: Foundation & Ghostty Module - Research

**Researched:** 2026-01-24
**Domain:** Ansible-based dotfiles deployment with ansible-role-dotmodules
**Confidence:** HIGH

## Summary

Phase 1 involves fixing a simple tech debt issue (duplicate 1password entry in deploy.yml) and creating a configuration-only Ghostty terminal module. This is well-trodden territory for this codebase - the patterns are established, documented, and validated through 9 existing modules.

The Ghostty module follows the simplest possible pattern: a config-only module with no Homebrew dependencies, no mergeable files, and no shell registration. It's nearly identical to the fonts module (config-only, no files to stow) but even simpler since it does have a config file to deploy.

Existing research from SpecKit (specs/001-ghostty-module/) has already validated the approach and identified the git module as the closest pattern match. The ansible-role-dotmodules role is mature, well-documented, and handles all the complexity of module processing, merging, and stow deployment.

**Primary recommendation:** Follow the established module pattern with stow_dirs configuration. Use Homebrew cask for optional Ghostty installation. Copy existing config from ~/.config/ghostty/config to the module files directory.

## Standard Stack

The established stack for this codebase and phase:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Ansible | 2.9+ | Automation framework | Infrastructure as code standard; idempotent, declarative configuration management |
| ansible-role-dotmodules | latest (git) | Module processing engine | Custom role specifically built for this modular dotfiles pattern; handles merging, stow, and Homebrew |
| GNU Stow | latest via Homebrew | Symlink manager | Industry standard for dotfile deployment; creates clean, reversible symlinks |
| Homebrew | 4.0+ | Package manager | macOS standard package manager; provides consistent software installation |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| community.general | latest | Ansible Homebrew modules | Required for Homebrew integration (homebrew, homebrew_cask, homebrew_tap modules) |
| geerlingguy.mac | >=1.0.0 | macOS system config | Optional; only needed if using Mac App Store (mas) functionality |
| Ghostty | 1.2.3 | Terminal emulator | Target application for this module; installed separately or via Homebrew cask |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| GNU Stow | Direct symlinks via Ansible | Loses conflict detection, directory folding, easy rollback |
| ansible-role-dotmodules | Custom Ansible tasks | Would need to reimplement merging, conflict resolution, and module ordering |
| Homebrew | MacPorts, Nix | Homebrew is macOS standard; existing codebase already committed to it |
| YAML config | Shell scripts | Violates Constitution principle #8 (Declarative Over Imperative) |

**Installation:**
```bash
# Install Ansible collections (already in requirements.yml)
ansible-galaxy install -r requirements.yml

# GNU Stow already installed via shell module
# Homebrew is prerequisite (must be installed before running playbook)
```

## Architecture Patterns

### Recommended Project Structure
```
modules/ghostty/
├── config.yml           # Module metadata (stow_dirs configuration)
├── README.md            # Module documentation
└── files/               # Files to deploy via stow
    └── .config/
        └── ghostty/
            └── config   # Ghostty configuration file
```

### Pattern 1: Config-Only Module (Stow Deployment)
**What:** Module that only deploys configuration files via GNU Stow, with no Homebrew packages, no merging, no shell registration.

**When to use:** When configuration files are standalone and don't need to merge with other modules. Perfect for application-specific config that lives in its own directory.

**Example:**
```yaml
# modules/ghostty/config.yml
---
# Ghostty terminal configuration module
# Provides Ghostty terminal emulator configuration

stow_dirs:
  - ghostty
```

**How it works:**
1. ansible-role-dotmodules reads config.yml
2. Uses GNU Stow to symlink files/ directory contents to home directory
3. Result: ~/.config/ghostty/config → ~/.dotmodules/ghostty/files/.config/ghostty/config

**Source:** Validated pattern from git module (modules/git/config.yml) and fonts module (modules/fonts/config.yml)

### Pattern 2: Module with Optional Homebrew Installation
**What:** Module that can optionally install software via Homebrew while deploying configuration.

**When to use:** When the software is available via Homebrew and you want to automate installation.

**Example:**
```yaml
# modules/ghostty/config.yml (with optional Homebrew)
---
# Ghostty terminal configuration module

homebrew_casks:
  - ghostty

stow_dirs:
  - ghostty
```

**Why this matters:** Ghostty is available via Homebrew cask. The module can optionally include installation, though it's not required (users may install Ghostty manually).

**Source:** ansible-role-dotmodules README.md section "Module Configuration"

### Pattern 3: Fixing deploy.yml Duplicate Entries
**What:** Remove duplicate module entries from the dotmodules.install list.

**When to use:** When the same module appears twice in the install list (tech debt).

**Example:**
```yaml
# BEFORE (playbooks/deploy.yml - lines 16-26)
dotmodules:
  install:
    - git
    - fonts
    - 1password      # First occurrence (line 19)
    - shell
    - fish
    - zsh
    - dev-tools
    - node
    - editor
    - 1password      # Duplicate (line 26) ← REMOVE THIS

# AFTER
dotmodules:
  install:
    - git
    - fonts
    - 1password      # Single occurrence
    - shell
    - fish
    - zsh
    - dev-tools
    - node
    - editor
    - ghostty        # New module added
```

**Source:** Direct observation from deploy.yml analysis

### Anti-Patterns to Avoid
- **Don't use mergeable_files for single-app configs:** Ghostty config doesn't need to merge with other modules. Using mergeable_files would add unnecessary complexity and attribution headers.
- **Don't create custom symlink tasks:** GNU Stow handles all symlink creation automatically when stow_dirs is specified.
- **Don't modify deployed files directly:** Users should edit files in modules/ghostty/files/, not the symlinked versions in home directory (though they're the same due to symlinks).
- **Don't skip module README:** Every module needs documentation explaining what it does and any post-deployment steps.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Symlinking dotfiles | Custom Ansible file tasks | GNU Stow via stow_dirs | Stow handles nested directories, conflict detection, directory folding, and provides clean rollback |
| Installing Homebrew packages | Shell commands in tasks | homebrew_packages in config.yml | ansible-role-dotmodules handles idempotency, error handling, and uses official Ansible modules |
| Merging configs from multiple modules | Cat/append in shell | mergeable_files in config.yml | Role provides attribution headers, conflict detection, and proper merge directory management |
| Module ordering and dependencies | Manual task ordering | List order in deploy.yml | Role processes modules in order specified in install list |
| Creating symlink parent directories | mkdir tasks | GNU Stow automatic creation | Stow creates parent directories automatically with --no-folding for nested files |

**Key insight:** ansible-role-dotmodules abstracts away all the complexity of dotfile deployment. Module config.yml files are pure declarations of desired state. Don't bypass the abstraction by writing custom tasks.

## Common Pitfalls

### Pitfall 1: Forgetting to Add Module to deploy.yml
**What goes wrong:** Module is created but never gets deployed because it's not in the dotmodules.install list.

**Why it happens:** Module structure is complete and looks correct, but Ansible doesn't know to process it.

**How to avoid:** After creating the module, immediately add it to playbooks/deploy.yml in the dotmodules.install list.

**Warning signs:** Running the playbook doesn't show the module name in output; config files aren't symlinked to home directory.

### Pitfall 2: Wrong Directory Structure in files/
**What goes wrong:** Files aren't symlinked to the expected location because the files/ directory structure doesn't mirror the home directory.

**Why it happens:** Misunderstanding how GNU Stow works - it expects files/ to contain the exact directory structure that should appear in home.

**How to avoid:** For ~/.config/ghostty/config, create modules/ghostty/files/.config/ghostty/config (full path from home directory).

**Warning signs:** Files appear in wrong locations or aren't symlinked at all; stow reports conflicts or errors.

### Pitfall 3: Using mergeable_files for Non-Shared Files
**What goes wrong:** Single-app configuration files get unnecessary merge markers and end up in modules/merged/ instead of being directly symlinked.

**Why it happens:** Misunderstanding when to use mergeable_files vs stow_dirs. Mergeable files are for shared configs like .zshrc that multiple modules contribute to.

**How to avoid:** Use mergeable_files only when multiple modules need to write to the same file. For app-specific configs, use stow_dirs.

**Warning signs:** Config file has module attribution headers when it shouldn't; file appears in modules/merged/ directory.

### Pitfall 4: Modifying Deployed Files Instead of Source
**What goes wrong:** User edits ~/.config/ghostty/config (the symlink) thinking it's a regular file, changes work but aren't committed to the repo.

**Why it happens:** Forgetting that deployed files are symlinks. Editing symlinks edits the source, but the source might not be in the expected location.

**How to avoid:** Document in module README that files are symlinked, and changes should be made in the module, committed, and pushed to sync across machines.

**Warning signs:** Changes work on one machine but don't appear on others after git pull; git status doesn't show the expected file changes.

### Pitfall 5: Stow Conflicts with Existing Files
**What goes wrong:** First deployment fails because ~/.config/ghostty/ already exists and contains files.

**Why it happens:** User has existing Ghostty config that wasn't migrated to the module before first deployment.

**How to avoid:** Before first deployment, copy existing config to the module, remove original, then run playbook. Or handle conflicts by backing up and removing existing files.

**Warning signs:** Stow reports conflicts; symlinks aren't created; playbook fails with stow error messages.

## Code Examples

Verified patterns from official sources:

### Module config.yml (Basic Stow-Only)
```yaml
# Source: modules/git/config.yml (existing module)
---
# Ghostty terminal configuration module
# Provides Ghostty terminal emulator configuration

stow_dirs:
  - ghostty
```

### Module config.yml (With Optional Homebrew Installation)
```yaml
# Source: ansible-role-dotmodules README.md + modules/1password/config.yml pattern
---
# Ghostty terminal configuration module
# Provides Ghostty terminal emulator configuration and optional installation

homebrew_casks:
  - ghostty

stow_dirs:
  - ghostty
```

### Adding Module to deploy.yml
```yaml
# Source: playbooks/deploy.yml (existing playbook)
---
- name: Deploy dotfiles using ansible-role-dotmodules
  hosts: localhost
  tags:
    - dotfiles
  vars:
    dotmodules:
      repo: 'file://{{ playbook_dir }}/../modules'
      dest: '{{ ansible_env.HOME }}/.dotmodules'
      install:
        - git
        - fonts
        - 1password          # Removed duplicate that was at end of list
        - shell
        - fish
        - zsh
        - dev-tools
        - node
        - editor
        - ghostty            # New module added
  roles:
    - role: ansible-role-dotmodules
```

### Module README.md Structure
```markdown
# Source: modules/1password/README.md (existing module)
# Ghostty Terminal Module

This module provides Ghostty terminal emulator configuration for consistent terminal appearance across machines.

## Core Features

The module delivers:

- **Ghostty configuration** for consistent colors, fonts, and behavior
- **Automatic sync** across machines via git + Ansible deployment
- **Symlink-based deployment** via GNU Stow (edit files in repo, changes reflect immediately)

## Installation Components

**Configuration files:**
- ~/.config/ghostty/config (symlinked to modules/ghostty/files/.config/ghostty/config)

**Optional Homebrew casks:**
- ghostty (if homebrew_casks is included in config.yml)

## Prerequisites

To use this module:
- Ghostty terminal emulator installed (manual install or via module's optional Homebrew cask)

## Initial Setup

### Manual Ghostty Installation

If not using the optional Homebrew cask, download and install Ghostty from:
https://ghostty.org/download

### Deployment

The module is automatically deployed when running the main playbook:
```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml
```

## Configuration

Edit configuration in `modules/ghostty/files/.config/ghostty/config`. Changes are immediately visible since files are symlinked.

## Customization

Common customizations:

**Change font:**
```
font-family = MonoLisa Nerd Font
font-size = 14
```

**Change theme colors:**
```
background = #1e1e3f
foreground = #ffffff
palette = 0=#000000  # Black
palette = 1=#e43937  # Red
# ... etc
```

**Adjust window padding:**
```
window-padding-x = 8
window-padding-y = 8
```

## Documentation

For comprehensive Ghostty configuration options:
https://ghostty.org/docs/config
```

### Migrating Existing Config to Module
```bash
# Source: Best practice from codebase structure analysis
# Step 1: Create module structure
mkdir -p modules/ghostty/files/.config/ghostty

# Step 2: Copy existing config to module
cp ~/.config/ghostty/config modules/ghostty/files/.config/ghostty/config

# Step 3: Backup and remove original (prevents stow conflict)
mv ~/.config/ghostty ~/.config/ghostty.backup

# Step 4: Create config.yml
cat > modules/ghostty/config.yml << 'EOF'
---
# Ghostty terminal configuration module
stow_dirs:
  - ghostty
EOF

# Step 5: Add to deploy.yml and run playbook
# (After adding ghostty to install list)
ansible-playbook -i playbooks/inventory playbooks/deploy.yml

# Step 6: Verify symlink
ls -la ~/.config/ghostty/config
# Should show: ~/.config/ghostty/config -> /Users/mcravey/.dotmodules/ghostty/files/.config/ghostty/config
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual config copying | ansible-role-dotmodules with stow | Codebase established pattern | Automated, idempotent, version-controlled config management |
| Single monolithic repo | Modular organization | Codebase established pattern | Independent modules that can be selectively deployed |
| Direct symlinks | GNU Stow | Codebase established pattern | Conflict detection, nested directory support, easy rollback |
| Shell scripts | Declarative YAML | Constitution v1.0.0 (principle #8) | Easier to read, maintain, and reason about |

**Current practices:**
- Modules are config-only declarations in YAML
- ansible-role-dotmodules handles all processing
- GNU Stow manages all symlink creation
- Homebrew integration via community.general collection
- Constitutional principles guide all decisions

**Deprecated/outdated:**
- Custom symlink tasks in modules - use stow_dirs instead
- Shell scripts for file deployment - use declarative config.yml
- Manual package installation - use homebrew_packages/homebrew_casks

## Open Questions

None - all patterns are well-established and documented. The existing SpecKit research (specs/001-ghostty-module/research.md) has already validated the approach, and the ansible-role-dotmodules README provides comprehensive documentation of all capabilities.

## Sources

### Primary (HIGH confidence)
- ansible-role-dotmodules README.md (~/.ansible/roles/ansible-role-dotmodules/README.md) - Official role documentation
- Existing module configs (modules/*/config.yml) - 9 working examples
- playbooks/deploy.yml - Current deployment configuration
- docs/policy/CONSTITUTION.md v1.0.0 - Project principles
- Ghostty installed locally (version 1.2.3) - Verified config location and format
- Homebrew cask database (brew info ghostty) - Verified Ghostty availability

### Secondary (MEDIUM confidence)
- specs/001-ghostty-module/research.md - Prior SpecKit research validating approach
- .planning/codebase/ARCHITECTURE.md - Codebase analysis from GSD mapping
- .planning/codebase/STRUCTURE.md - Directory layout and conventions
- .planning/codebase/STACK.md - Technology stack documentation

### Tertiary (LOW confidence)
- None required - all findings verified through primary sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All components are established in codebase, versions verified, patterns proven
- Architecture: HIGH - 9 existing modules demonstrate patterns, ansible-role-dotmodules extensively documented
- Pitfalls: HIGH - Based on actual code patterns, Constitution principles, and common Stow/Ansible issues

**Research date:** 2026-01-24
**Valid until:** 90 days (2026-04-24) - Stable patterns, established codebase, slow-moving tech stack

**Research scope:**
- ✅ Module structure and patterns (git, fonts, 1password modules analyzed)
- ✅ ansible-role-dotmodules capabilities (README fully reviewed)
- ✅ Ghostty configuration location and format (verified locally)
- ✅ Homebrew availability (verified via brew info)
- ✅ Deploy.yml structure and duplicate fix (analyzed existing file)
- ✅ Constitution compliance (all 8 principles checked)
- ✅ Stow behavior and conflict handling (documented in role README)

**Caveats:**
- Ghostty is a newer terminal emulator (1.2.3 stable) but config format is simple key=value
- Homebrew cask installation is optional - module works regardless of installation method
- First deployment requires handling existing config files (backup/remove before stow)
