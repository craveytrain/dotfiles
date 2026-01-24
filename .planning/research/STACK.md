# Technology Stack for New Configuration Modules

**Research Date**: 2026-01-23
**Scope**: Adding new tool configurations (Ghostty, Claude CLI) to existing dotfiles system
**Researcher**: Claude Sonnet 4.5

## Executive Summary

The standard 2025 approach for managing additional tool configurations in modular dotfiles systems follows the **XDG Base Directory specification** with **declarative YAML-based module definitions** deployed via **symlink managers** (GNU Stow). This research focuses specifically on adding NEW modules to the EXISTING ansible-role-dotmodules system, not re-implementing the foundation.

**Key Finding**: Configuration modules in 2025 fall into three distinct patterns:
1. **Config-only modules** (Ghostty, bat) - XDG configs without package management
2. **CLI tool modules** (Claude CLI, 1Password CLI) - Homebrew cask + optional config
3. **Development environment modules** (mise, node) - Package manager + version config files

## Module Structure Patterns

### Pattern 1: Config-Only Module (Ghostty Terminal)

**When to use**: Terminal emulators, GUI applications with portable configs, tools installed outside Homebrew

**Structure**:
```
modules/ghostty/
├── config.yml          # Module metadata
├── README.md           # Documentation
└── files/              # Stow root (mirrors home directory)
    └── .config/
        └── ghostty/
            └── config  # Plain text key=value format
```

**config.yml**:
```yaml
---
# Ghostty terminal configuration module
stow_dirs:
  - ghostty
```

**Rationale**:
- Ghostty installed manually via .dmg (not in Homebrew)
- Configuration lives in XDG location `~/.config/ghostty/config`
- Single config file, no merging needed
- Similar pattern to existing git module (`.config/gh/`)

**Confidence**: HIGH - Ghostty config format is stable, XDG standard is universal

### Pattern 2: CLI Tool with Homebrew Cask (Claude CLI)

**When to use**: Command-line tools distributed via Homebrew cask, optional configuration files

**Structure**:
```
modules/claude-cli/
├── config.yml
├── README.md
└── files/              # Optional - only if config files exist
    └── .config/
        └── claude/
            └── config.yml
```

**config.yml**:
```yaml
---
# Claude CLI configuration module
homebrew_casks:
  - claude-cli  # Hypothetical - verify actual package name

stow_dirs:
  - claude-cli  # Only if config files exist
```

**Rationale**:
- Claude CLI may be distributed as Homebrew cask (verify in 2026)
- Configuration location follows XDG: `~/.config/claude/`
- Similar to 1password module (cask-only) or git module (cask + config)

**Confidence**: MEDIUM - Claude CLI distribution method and config location need verification

**Verification needed**:
1. Check if Claude CLI is available via Homebrew in 2026
2. Verify configuration file location (XDG vs application-specific)
3. Confirm config file format (YAML, TOML, or plain text)

### Pattern 3: Development Tool Module (Existing Reference)

**When to use**: Version managers, language runtimes, dev tools with complex config

**Structure** (example: mise/node pattern):
```
modules/node/
├── config.yml
├── README.md
└── files/
    ├── .config/
    │   └── mise/
    │       └── config.toml
    └── .tool-versions
```

**config.yml**:
```yaml
---
# Node.js development module
homebrew_packages:
  - node  # Or installed via mise

stow_dirs:
  - node

mergeable_files:
  - '.config/mise/config.toml'
```

**Rationale**: Already implemented; reference pattern for complex tools

## config.yml Specification

### Required Fields

**`stow_dirs`** (list of strings):
```yaml
stow_dirs:
  - module-name
```
- Defines subdirectories in `files/` to symlink
- Each entry maps to a directory: `files/<stow_dir>/*` → `~/*`
- Standard convention: use module name as stow_dir name

### Optional Fields

**`homebrew_packages`** (list of strings):
```yaml
homebrew_packages:
  - package-name
  - another-package
```
- CLI tools installed via `brew install`
- Only include if package exists in Homebrew core taps

**`homebrew_casks`** (list of strings):
```yaml
homebrew_casks:
  - cask-name
```
- GUI applications or binary distributions
- Use for Claude CLI, 1Password CLI, fonts

**`homebrew_taps`** (list of strings):
```yaml
homebrew_taps:
  - tap-name/repo
```
- Third-party Homebrew repositories
- Only needed for packages not in core

**`mergeable_files`** (list of strings):
```yaml
mergeable_files:
  - '.zshrc'
  - '.config/fish/config.fish'
  - '.config/mise/config.toml'
```
- Files that multiple modules contribute to
- ansible-role-dotmodules merges with headers showing source module
- Use sparingly - prefer isolated configs

**`register_shell`** (string):
```yaml
register_shell: fish  # or zsh, bash
```
- Automatically add shell to `/etc/shells`
- Requires sudo (can skip with `--skip-tags register_shell`)
- Only for shell modules (fish, zsh)

### Field Ordering Convention

```yaml
---
# Module comment/description
homebrew_taps:      # 1. Taps (if needed)
  - ...
homebrew_packages:  # 2. Packages
  - ...
homebrew_casks:     # 3. Casks
  - ...
stow_dirs:          # 4. Stow deployment
  - ...
mergeable_files:    # 5. Cross-module files
  - ...
register_shell: ... # 6. Shell registration (shells only)
```

**Confidence**: HIGH - Pattern extracted from 10 existing modules

## Configuration File Locations (2025 Standard)

### XDG Base Directory Specification

**Primary locations**:
- `~/.config/<tool>/` - Primary config location (XDG_CONFIG_HOME)
- `~/.local/bin/` - User scripts and executables
- `~/.local/share/<tool>/` - Application data (less common for configs)

**Legacy locations** (avoid for new tools):
- `~/.<toolname>rc` - Dotfiles in home directory root
- `~/.<toolname>/` - Tool-specific directory in home

### Config Format by Tool Type

| Tool Type | Format | Example | Notes |
|-----------|--------|---------|-------|
| Terminal emulator | Plain text key=value | Ghostty `config` | Simple, human-readable |
| CLI tool | YAML or TOML | Claude CLI (unknown) | Check tool docs |
| Version manager | TOML | mise `config.toml` | Industry standard for version specs |
| Shell | Shell script | `.zshrc`, `.bashrc` | Sourced by shell |
| Git-like tools | INI/Git config | `.gitconfig` | Git config format |
| Modern CLI tools | YAML | GitHub CLI `config.yml` | Increasingly common |

**Confidence**: HIGH - XDG Base Directory is well-established standard

## Deployment Integration

### Adding to Playbook

**File**: `playbooks/deploy.yml`

**Current install list**:
```yaml
install:
  - git
  - fonts
  - 1password
  - shell
  - fish
  - zsh
  - dev-tools
  - node
  - editor
  - 1password  # Duplicate - needs fixing
```

**Add new modules**:
```yaml
install:
  - git
  - fonts
  - 1password
  - shell
  - fish
  - zsh
  - dev-tools
  - node
  - editor
  - ghostty        # NEW: Terminal config
  - claude-cli     # NEW: CLI tool
```

**Ordering considerations**:
- **Dependencies first**: If module B depends on module A, list A first
- **No hard dependencies**: Most config modules are independent
- **Convention**: Group by category (shells together, dev tools together)

**Confidence**: HIGH - Clear pattern from existing playbook

### Testing New Modules

**Pre-deployment checklist**:
1. Create module directory: `modules/<name>/`
2. Add `config.yml` with required fields
3. Create `files/` directory mirroring home structure
4. Add configuration files to `files/`
5. Write `README.md` documenting module

**Deployment test**:
```bash
# Dry run (check for conflicts)
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --check --diff

# Deploy with verbose output
ansible-playbook -i playbooks/inventory playbooks/deploy.yml -v

# Skip shell registration if on restricted machine
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --skip-tags register_shell
```

**Verification**:
1. Check symlinks exist: `ls -la ~/.config/ghostty/config`
2. Verify symlink target: `readlink ~/.config/ghostty/config`
3. Test tool loads config: Open Ghostty and verify settings applied

**Confidence**: HIGH - Standard Ansible testing workflow

## Dependencies and Prerequisites

### Already Available (No Action Needed)

- **Ansible 2.9+** - Installed
- **ansible-role-dotmodules** - Installed via `requirements.yml`
- **GNU Stow** - Installed via shell module
- **Homebrew** - User's macOS package manager
- **Git** - For version control

### Tool-Specific Dependencies

**Ghostty**:
- No dependencies - config-only module
- Ghostty must be installed manually (not via Homebrew as of 2025)
- Configuration applies when Ghostty is present

**Claude CLI**:
- Verify Homebrew cask availability (as of 2026)
- May require authentication setup (similar to `op signin` for 1Password)
- Check official docs: https://docs.anthropic.com/claude/reference/cli

**Future tools**:
- Always check Homebrew availability: `brew search <tool>`
- Verify config location in tool's documentation
- Check for version managers or plugin systems

**Confidence**: MEDIUM-HIGH - Ghostty confirmed, Claude CLI needs verification

## Local Override Pattern

### Supporting Machine-Specific Customization

**Pattern**: All base configs source `.*.local` files if they exist

**Example** (Ghostty):
```
# In modules/ghostty/files/.config/ghostty/config
# Base configuration tracked in git
theme = nord
font-family = "Input Mono"

# On user's machine: ~/.config/ghostty/config.local (not tracked)
# Machine-specific overrides
theme = solarized-light  # Override for bright office
```

**Implementation**:
1. Base config includes directive to load local file (if tool supports)
2. If tool doesn't support includes, document in README.md
3. Local files added to `.gitignore` via pattern: `**/*.local*`

**Tools with native include support**:
- Git: `[include] path = ~/.gitconfig.local`
- Zsh: `[ -f ~/.zshrc.local ] && source ~/.zshrc.local`
- Fish: `test -f ~/.config/fish/config.local.fish; and source ~/.config/fish/config.local.fish`
- Vim: `if filereadable(expand("~/.vimrc.local")) | source ~/.vimrc.local | endif`

**Tools without native includes**:
- Document environment variable overrides in README
- Example: bat theme via `BAT_THEME` environment variable

**Confidence**: HIGH - Established pattern across all existing modules

## Specific Recommendations

### Ghostty Terminal Configuration Module

**Module name**: `ghostty`

**Structure**:
```
modules/ghostty/
├── config.yml
├── README.md
└── files/
    └── .config/
        └── ghostty/
            ├── config       # Main config
            └── themes/      # Optional: custom themes directory
```

**config.yml**:
```yaml
---
# Ghostty terminal configuration module
# Provides Ghostty terminal emulator configuration

stow_dirs:
  - ghostty
```

**README.md sections**:
1. Overview - What Ghostty is, why in dotfiles
2. Installation - Manual .dmg install (not Homebrew)
3. Configuration - Key settings explanation
4. Local Overrides - How to customize per-machine
5. Keybindings - Document custom keybindings
6. Themes - Theme selection and customization

**Migration steps**:
1. Copy existing `~/.config/ghostty/config` to `modules/ghostty/files/.config/ghostty/config`
2. Backup original: `mv ~/.config/ghostty ~/.config/ghostty.backup`
3. Add `ghostty` to `playbooks/deploy.yml` install list
4. Run playbook: `ansible-playbook -i playbooks/inventory playbooks/deploy.yml`
5. Verify: `ls -la ~/.config/ghostty/config` shows symlink

**Confidence**: HIGH - Clear pattern, standard location, stable config format

### Claude CLI Configuration Module

**Module name**: `claude-cli`

**Pending research**:
1. **Distribution method** - Verify if available via Homebrew cask in 2026
2. **Configuration location** - Check if `~/.config/claude/` or tool-specific
3. **Config format** - YAML, TOML, JSON, or plain text
4. **Authentication** - Similar to 1Password (`op signin`) or token-based

**Provisional structure** (subject to verification):
```
modules/claude-cli/
├── config.yml
├── README.md
└── files/               # Only if config files exist
    └── .config/
        └── claude/
            └── config.yml  # Hypothetical
```

**Provisional config.yml**:
```yaml
---
# Claude CLI configuration module
homebrew_casks:
  - claude-cli  # VERIFY: Actual package name

stow_dirs:
  - claude-cli  # Only if config files exist
```

**Recommended next steps**:
1. Check Homebrew: `brew search claude`
2. Install Claude CLI manually to discover config location
3. Run `claude --help` or `claude config` to find config commands
4. Check XDG locations: `ls ~/.config/claude/`, `ls ~/.claude/`
5. Review official docs: https://docs.anthropic.com/

**Confidence**: LOW - Needs verification before implementation

**Alternative if not in Homebrew**:
- Manual installation docs in README.md
- Config-only module (like Ghostty)
- Installation verification step in README

### General Pattern for Future Modules

**Decision tree**:

```
1. Is tool available in Homebrew?
   YES → Include homebrew_packages or homebrew_casks
   NO  → Document manual installation in README.md

2. Does tool have configuration files?
   YES → Continue to step 3
   NO  → Simple package-only module (like fonts)

3. Where does config live?
   ~/.config/<tool>/ → Use XDG pattern (preferred)
   ~/.<tool>rc       → Use legacy dotfile pattern
   Other             → Document in README.md

4. Do multiple modules need to contribute to same file?
   YES → Use mergeable_files (rare)
   NO  → Standard stow_dirs pattern (preferred)

5. Are there machine-specific settings?
   YES → Document local override pattern in README.md
   NO  → Standard deployment
```

**Confidence**: HIGH - Distilled from 10 existing modules

## Version Verification (2025/2026 Current)

### Ansible & Deployment

- **Ansible**: 2.9+ (current stable is 2.17 as of 2025)
- **ansible-role-dotmodules**: Using git source (latest from craveytrain/ansible-role-dotmodules)
- **GNU Stow**: 2.3+ via Homebrew (latest stable)
- **Homebrew**: 4.x (current stable)

### Configuration Standards

- **XDG Base Directory Specification**: Version 0.8 (2021, stable)
- **YAML**: 1.2 (widespread support in Ansible 2.9+)
- **TOML**: 1.0.0 (stable since 2021, used by mise)

### Tool-Specific Versions

- **Ghostty**:
  - Version: Check https://ghostty.org/ for latest
  - Config format: Plain text key=value (stable)
  - Location: `~/.config/ghostty/config` (XDG standard)

- **Claude CLI**:
  - Version: Unknown - requires verification
  - Distribution: Check https://docs.anthropic.com/claude/reference/cli
  - Config: Unknown - needs research

**Confidence**: HIGH for standards, MEDIUM for tool-specific (Ghostty confirmed, Claude needs verification)

## Rationale: Why These Patterns?

### XDG Base Directory Specification

**Why**:
- Industry standard since 2010, universal adoption in 2025
- Keeps home directory clean (no dotfile clutter)
- Predictable locations for backup/sync tools
- Better separation of config, data, and cache

**Evidence**: All modern CLI tools (GitHub CLI, mise, bat) use `~/.config/`

**Confidence**: HIGH

### GNU Stow for Symlinks

**Why**:
- Declarative: Files stay in repo, symlinks point to them
- Reversible: `stow -D` removes all symlinks cleanly
- Conflict detection: Won't overwrite existing files
- Battle-tested: 30+ years of development

**Alternatives considered**:
- Direct file copying: Not reversible, no sync
- Rsync: One-way sync, loses git connection
- Custom scripts: Reinventing Stow poorly

**Confidence**: HIGH - Stow is the standard in dotfiles community

### Modular Architecture

**Why**:
- Independent deployment: Enable/disable modules per machine
- Clear ownership: Each tool's config in its own module
- Easier testing: Test one module without affecting others
- Collaboration-friendly: Multiple people can work on different modules

**Evidence**: Consistent pattern across Ansible Galaxy dotfiles roles

**Confidence**: HIGH

### YAML for Module Metadata

**Why**:
- Ansible-native: No conversion needed
- Human-readable: Easy to review and edit
- Structured: Clear field definitions and validation
- Comments: Document decisions inline

**Alternatives**:
- JSON: Less human-friendly, no comments
- TOML: Not Ansible-native
- INI: Limited structure

**Confidence**: HIGH - Ansible standard

## Quality Gates

### Pre-Implementation Checklist

- [ ] Verified tool installation method (Homebrew vs manual)
- [ ] Confirmed configuration file location (XDG vs legacy)
- [ ] Identified configuration file format (YAML, TOML, plain text)
- [ ] Checked for dependencies on other modules
- [ ] Reviewed existing modules for similar patterns
- [ ] Tested configuration locally before committing

### Post-Implementation Verification

- [ ] Module deploys without errors on clean machine
- [ ] Symlinks created in correct locations
- [ ] Tool loads configuration successfully
- [ ] No conflicts with existing modules
- [ ] README.md documents all configuration options
- [ ] Local override pattern documented (if applicable)
- [ ] Module added to playbook install list

**Confidence**: HIGH - Based on existing module development workflow

## Open Questions

1. **Claude CLI Distribution**:
   - Is Claude CLI available via Homebrew in 2026?
   - What is the package name?
   - **Resolution**: Check `brew search claude` and https://docs.anthropic.com/

2. **Claude CLI Configuration**:
   - Where does configuration live?
   - What format is used?
   - **Resolution**: Install manually and explore `~/.config/` and `~/.claude/`

3. **Authentication Workflow**:
   - Does Claude CLI require signin like 1Password?
   - Are credentials stored in config or keychain?
   - **Resolution**: Review official documentation and test installation

4. **Future Module Discovery**:
   - What other tools in home directory need modules?
   - **Resolution**: Audit `~/.config/` for unexpected directories

**Next Steps**:
1. Implement Ghostty module (high confidence, clear pattern)
2. Research Claude CLI (pending verification)
3. Audit home directory for additional configs

## Sources & References

**Existing Codebase**:
- `/Users/mcravey/dotfiles/modules/*/config.yml` - 10 module examples
- `/Users/mcravey/dotfiles/README.md` - Module structure documentation
- `/Users/mcravey/dotfiles/.planning/codebase/STACK.md` - Current tech stack
- `/Users/mcravey/dotfiles/.planning/codebase/ARCHITECTURE.md` - System architecture

**Standards**:
- XDG Base Directory Specification: https://specifications.freedesktop.org/basedir-spec/
- GNU Stow Manual: https://www.gnu.org/software/stow/manual/
- Ansible Documentation: https://docs.ansible.com/

**Tool Documentation**:
- Ghostty: https://ghostty.org/docs/config
- Claude CLI: https://docs.anthropic.com/claude/reference/cli (pending verification)
- ansible-role-dotmodules: https://github.com/craveytrain/ansible-role-dotmodules

---

**Analysis completed**: 2026-01-23
**Confidence level**: HIGH for Ghostty, MEDIUM for Claude CLI (needs verification)
**Recommended action**: Implement Ghostty module immediately, research Claude CLI before implementation
