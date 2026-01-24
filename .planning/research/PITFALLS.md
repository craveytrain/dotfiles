# Common Pitfalls When Adding Configuration Modules to Dotfiles Systems

Research focus: Module-specific mistakes in Ansible + ansible-role-dotmodules + GNU Stow systems

---

## 1. Duplicate Module Entries in Playbook

### Problem
Adding the same module multiple times to the `dotmodules.install` list in the playbook.

### Warning Signs
- Playbook runs succeed but take unexpectedly long
- Homebrew packages reinstall/check twice
- Duplicate log entries during deployment
- Stow warnings about already-linked files

### Real Example
```yaml
# playbooks/deploy.yml - INCORRECT
dotmodules:
  install:
    - git
    - 1password
    - shell
    - 1password  # Duplicate! Already listed above
```

### Prevention Strategy
1. Before adding a module to `dotmodules.install`, grep the playbook:
   ```bash
   grep -n "module-name" playbooks/deploy.yml
   ```
2. Keep modules in alphabetical order for easy visual scanning
3. Review the entire install list before running the playbook
4. Use YAML linting tools to catch duplicates

### Detection Method
```bash
# Detect duplicate modules in playbook
grep "^        - " playbooks/deploy.yml | sort | uniq -d
```

### Phase to Address
**Planning Phase** - Before creating module config.yml, check playbook structure

---

## 2. Missing Module Dependencies

### Problem
Installing a module that depends on packages/tools from another module without ensuring the dependency is installed first or listed in the playbook.

### Warning Signs
- Commands not found during module deployment
- Stow succeeds but configs reference missing binaries
- Tools fail at runtime with "command not found"
- Environment variables reference non-existent paths

### Real Example
```yaml
# modules/node/config.yml
# This module requires mise from dev-tools module
# If dev-tools isn't listed BEFORE node in playbook, mise won't be available
```

Current dependency graph:
- `node` → depends on → `dev-tools` (provides mise)
- `zsh` → depends on → `shell` (provides eza for aliases)
- `editor` → references → shell utilities (eza, ripgrep)

### Prevention Strategy
1. Document dependencies in module README.md "Prerequisites" section
2. Add comment in config.yml noting required modules
3. Order modules in playbook with dependencies first:
   ```yaml
   install:
     - shell        # Provides utilities for other modules
     - dev-tools    # Provides mise
     - node         # Needs mise from dev-tools
     - zsh          # Uses eza from shell
   ```
4. Test deployment on clean system to catch missing dependencies

### Detection Method
```bash
# Check for tool references without package declaration
rg "command.*mise" modules/*/files/ --type-not yml
# Then verify mise is in that module's homebrew_packages or a dependency
```

### Phase to Address
**Planning Phase** - Map dependencies before creating config
**Implementation Phase** - Document in config.yml and README.md
**Testing Phase** - Deploy on clean VM/container

---

## 3. Conflicting Mergeable File Declarations

### Problem
Multiple modules declaring the same file as mergeable with incompatible merge strategies, or forgetting to declare a file as mergeable when it should be shared.

### Warning Signs
- Stow complains about conflicting symlinks
- Merged files missing content from some modules
- Files in `modules/merged/` don't contain expected sections
- Config changes from one module overwrite another's

### Real Example
```yaml
# modules/zsh/config.yml
mergeable_files:
  - '.zshrc'
  - '.zsh/aliases.sh'
  - '.zsh/environment.sh'

# modules/dev-tools/config.yml
mergeable_files:
  - '.zshrc'  # CONFLICT: Same file, both modules contribute
  - '.config/fish/config.fish'

# modules/editor/config.yml
mergeable_files:
  - '.zsh/aliases.sh'  # OK: Multiple modules can contribute to same file
  - '.zsh/environment.sh'
```

Current mergeable files (from existing modules):
- `.zshrc` - zsh, dev-tools
- `.zsh/aliases.sh` - zsh, editor
- `.zsh/environment.sh` - zsh, shell, editor
- `.config/fish/config.fish` - shell, dev-tools, editor
- `.config/mise/config.toml` - dev-tools, node

### Prevention Strategy
1. Before declaring mergeable file, check if other modules already use it:
   ```bash
   rg "mergeable_files" modules/*/config.yml -A 5
   ```
2. Ensure file content uses clear section markers (comments) for each module
3. Understand merge mechanism - ansible-role-dotmodules concatenates content
4. For shell configs, use sourcing pattern instead of merging when appropriate
5. Document which modules contribute to each mergeable file

### Detection Method
```bash
# List all mergeable files and their modules
for config in modules/*/config.yml; do
  echo "=== $(dirname $config) ==="
  grep -A 10 "mergeable_files:" "$config" | grep "  - " || echo "None"
done
```

### Phase to Address
**Planning Phase** - Research existing mergeable files before design
**Implementation Phase** - Add clear section comments in file content
**Testing Phase** - Verify merged output contains all expected sections

---

## 4. Stow Directory Structure Mismatches

### Problem
Files in `modules/<name>/files/` not mirroring the expected home directory structure, causing Stow to create incorrect symlinks or fail.

### Warning Signs
- Stow errors about "cannot stow file over directory"
- Symlinks created in wrong locations
- Config files not appearing in home directory
- Extra nested directories in home directory

### Real Example
```
# INCORRECT structure
modules/ghostty/files/ghostty/config
# Stow would create: ~/ghostty/config (wrong!)

# CORRECT structure
modules/ghostty/files/.config/ghostty/config
# Stow creates: ~/.config/ghostty/config (correct!)
```

Current working patterns:
```
modules/zsh/files/.zshrc           → ~/.zshrc
modules/zsh/files/.zsh/aliases.sh  → ~/.zsh/aliases.sh
modules/git/files/.gitconfig       → ~/.gitconfig
modules/git/files/.config/gh/config.yml → ~/.config/gh/config.yml
```

### Prevention Strategy
1. Always start files/ structure with `.` for home directory files
2. Match XDG Base Directory structure: `.config/app-name/` for modern apps
3. Test with single file before adding entire module
4. Check existing modules for similar app types (GUI vs CLI, etc.)
5. Review Stow manual for directory folding/unfolding behavior

### Detection Method
```bash
# Check if files/ contains proper structure
ls -la modules/new-module/files/
# Should see dotfiles (.zshrc, .config) not plain dirs (zshrc, config)
```

### Phase to Address
**Implementation Phase** - Create files/ structure correctly from start
**Testing Phase** - Deploy and verify symlink locations with `ls -la ~/`

---

## 5. Platform-Specific Paths in Configs

### Problem
Hardcoding paths that differ between architectures (Intel vs ARM Mac, Linux vs macOS) or assuming specific Homebrew installation locations.

### Warning Signs
- Configs work on development machine but fail on others
- PATH references to `/usr/local/bin` instead of `/opt/homebrew/bin`
- Architecture-specific binary paths in scripts
- Hardcoded user home directories

### Real Example
```bash
# INCORRECT - Intel Mac specific
export PATH="/usr/local/bin:$PATH"

# CORRECT - Works on both Intel and ARM
export PATH="$(brew --prefix)/bin:$PATH"

# INCORRECT - Hardcoded user
source /Users/mcravey/.p10k.zsh

# CORRECT - Uses variable
source ~/.p10k.zsh
```

### Prevention Strategy
1. Use `$(brew --prefix)` for Homebrew paths
2. Use `~` or `$HOME` for home directory references
3. Use shell variables: `$XDG_CONFIG_HOME` instead of `~/.config`
4. Avoid absolute paths where possible - use PATH lookup
5. Document platform constraints clearly (project accepts Apple Silicon only)

### Detection Method
```bash
# Find hardcoded Homebrew paths
rg "(/usr/local|/opt/homebrew)" modules/*/files/

# Find hardcoded home directories
rg "/Users/[a-z]+" modules/*/files/
```

### Phase to Address
**Implementation Phase** - Use dynamic paths from start
**Code Review Phase** - Grep for hardcoded paths before committing

---

## 6. Missing Shell Registration Configuration

### Problem
Adding a new shell module (fish, zsh, bash variants) without configuring the `register_shell` directive, preventing shell from being added to `/etc/shells`.

### Warning Signs
- New shell installed but can't be set as default
- `chsh` command fails with "invalid shell"
- Shell works when invoked manually but not as login shell
- `/etc/shells` missing the shell's Homebrew path

### Real Example
```yaml
# modules/fish/config.yml - CORRECT
homebrew_packages:
  - fish
stow_dirs:
  - fish
register_shell: fish  # This is required!

# modules/new-shell/config.yml - INCORRECT (missing register_shell)
homebrew_packages:
  - new-shell
stow_dirs:
  - new-shell
# Missing: register_shell: new-shell
```

### Prevention Strategy
1. For any shell module, always add `register_shell: <shell-name>` to config.yml
2. Understand this requires sudo - incompatible with BeyondTrust restrictions
3. Use `--skip-tags register_shell` flag for restricted environments
4. Document in module README that shell registration requires admin privileges
5. Test on restricted environment to ensure graceful degradation

### Detection Method
```bash
# Check which modules register shells
rg "register_shell:" modules/*/config.yml
```

### Phase to Address
**Planning Phase** - Identify if module is a shell
**Implementation Phase** - Add register_shell directive to config.yml
**Documentation Phase** - Note admin requirement in README

---

## 7. Homebrew Package Name Mismatches

### Problem
Using incorrect package names in `homebrew_packages` list - either typos, wrong formula name, or using cask name instead of formula.

### Warning Signs
- Ansible playbook fails with "No available formula with the name"
- Package installs under different name than expected
- Cask required but formula specified (or vice versa)
- Command not found after successful Homebrew installation

### Real Example
```yaml
# INCORRECT
homebrew_packages:
  - github-cli  # Wrong! Actual formula is 'gh'
  - vim-plug    # Wrong! This is installed via curl, not Homebrew
  - nodejs      # Wrong! Actual formula is 'node'

# CORRECT
homebrew_packages:
  - gh          # GitHub CLI
  - vim         # vim-plug installed separately via autoload
  - node        # Node.js
```

### Prevention Strategy
1. Verify package name before adding to config.yml:
   ```bash
   brew search package-name
   brew info package-name
   ```
2. Check if package is formula or cask:
   ```bash
   brew info --formula package-name
   brew info --cask package-name
   ```
3. For casks, use separate `homebrew_cask_packages` if supported by role
4. Test install manually before adding to module
5. Check package's actual binary name vs formula name

### Detection Method
```bash
# Test package names in config
for pkg in $(grep "^  - " modules/new-module/config.yml | cut -d'-' -f2); do
  brew info "$pkg" 2>&1 | grep -q "Error:" && echo "Invalid: $pkg"
done
```

### Phase to Address
**Implementation Phase** - Verify each package name before adding
**Testing Phase** - Deploy on test system to catch errors

---

## 8. Ignoring Local Override Patterns

### Problem
Not providing or documenting local override mechanisms (`.local` files), causing users to modify tracked files for machine-specific settings.

### Warning Signs
- Git shows modifications to committed config files
- Machine-specific settings scattered across tracked configs
- Merge conflicts when pulling updates
- Secrets/credentials committed to repository
- Users complain about overwritten local changes

### Real Example
```bash
# modules/zsh/files/.zshrc - INCORRECT
export GITHUB_TOKEN="ghp_xxxx"  # Secret in tracked file!
export PATH="$HOME/work/bin:$PATH"  # Machine-specific in tracked file!

# modules/zsh/files/.zshrc - CORRECT
# Load local config if it exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Then in ~/.zshrc.local (untracked)
export GITHUB_TOKEN="ghp_xxxx"
export PATH="$HOME/work/bin:$PATH"
```

Current override patterns:
- `.zshrc.local` - sourced at end of .zshrc
- `.zshenv.local.zsh` - sourced in .zshenv
- `.config/fish/config.local.fish` - sourced in config.fish

### Prevention Strategy
1. Always add local override sourcing to main config files
2. Use conditional sourcing: `[[ -f ~/.config.local ]] && source ~/.config.local`
3. Document local override pattern in module README
4. Add `.local` files to `.gitignore` (should already be there)
5. Provide examples of local overrides in README
6. Never commit machine-specific or secret values to tracked files

### Detection Method
```bash
# Check if main config has local sourcing
rg "\.local" modules/*/files/
rg "source.*local" modules/*/files/

# Check for potential secrets in tracked files
rg "(token|password|key|secret)" modules/*/files/ -i
```

### Phase to Address
**Planning Phase** - Design local override strategy
**Implementation Phase** - Add local sourcing to config files
**Documentation Phase** - Document override pattern with examples

---

## 9. Mergeable Files Without Section Markers

### Problem
Creating mergeable files without clear section comments, making it impossible to identify which module contributed which content.

### Warning Signs
- Merged files become hard to debug
- Can't tell which module owns specific config lines
- Difficult to remove module contributions later
- Merge conflicts when updating modules
- Duplicate configurations from multiple modules

### Real Example
```bash
# modules/git/files/.zsh/aliases.sh - INCORRECT
alias gs="git status"
alias gc="git commit"

# modules/dev-tools/files/.zsh/aliases.sh - INCORRECT
alias bat="bat --theme=nord"

# When merged: Can't tell which module added what!
```

```bash
# modules/git/files/.zsh/aliases.sh - CORRECT
# =============================================================================
# Git Module - Git Aliases
# =============================================================================
alias gs="git status"
alias gc="git commit"

# modules/dev-tools/files/.zsh/aliases.sh - CORRECT
# =============================================================================
# Dev-Tools Module - Tool Aliases
# =============================================================================
alias bat="bat --theme=nord"

# When merged: Clear ownership of each section
```

### Prevention Strategy
1. Use distinctive section header format for each module's contribution:
   ```bash
   # =============================================================================
   # <Module Name> - <Section Purpose>
   # =============================================================================
   ```
2. Add section footer if content is substantial
3. Include date/version in header if helpful
4. Group related configs within section
5. Leave blank line between module sections

### Detection Method
```bash
# Check if mergeable files have section headers
for file in $(rg "mergeable_files:" modules/*/config.yml -A 5 | grep "  - " | cut -d'-' -f2-); do
  echo "=== $file ==="
  find modules/*/files/ -path "*$file" -exec grep -l "# =====" {} \;
done
```

### Phase to Address
**Implementation Phase** - Add section markers to all mergeable content
**Code Review Phase** - Verify markers before merging

---

## 10. Missing Post-Deployment Steps

### Problem
Modules requiring manual post-deployment steps (plugin installations, shell restarts, configuration wizards) without documenting them, leading to incomplete setups.

### Warning Signs
- Configs deployed but features don't work
- Users report "nothing happened" after deployment
- Plugins listed but not installed
- Shell doesn't reflect new configuration
- Interactive setup never triggered

### Real Example
```yaml
# modules/fish/config.yml
# Post-deployment comment exists - GOOD
# Post-deployment: After running the playbook, log into a fish shell and run
# `fisher update` to install all fisher plugins defined in your config.fish

# modules/vim/config.yml - MISSING post-deployment docs
# vim-plug installed but plugins not fetched automatically
# User doesn't know to run :PlugInstall
```

Common post-deployment steps:
- Fisher plugin installation for Fish
- vim-plug `:PlugInstall` for Vim
- Powerlevel10k configuration wizard for Zsh
- Shell restart: `exec zsh` or `exec fish`
- mise tool installation: `mise install`

### Prevention Strategy
1. Document post-deployment steps in config.yml header comment
2. Add detailed "Post-Deployment" section to module README
3. Consider adding post-install Ansible tasks for automatable steps
4. Provide exact commands users need to run
5. Explain why each step is necessary
6. Note if steps require interactive input (can't be automated)

### Detection Method
```bash
# Check if modules document post-deployment
rg "post.?deploy" modules/*/config.yml -i
rg "post.?install" modules/*/README.md -i
```

### Phase to Address
**Planning Phase** - Identify manual steps during design
**Implementation Phase** - Add automation where possible
**Documentation Phase** - Document remaining manual steps clearly

---

## 11. BeyondTrust Privilege Escalation Issues

### Problem
Module requires `sudo` or `/etc/` modifications in BeyondTrust-restricted environment, causing deployment failures without graceful fallback.

### Warning Signs
- Playbook fails with "permission denied" on `/etc/shells`
- Homebrew installation blocked for privileged locations
- Service configurations fail to apply
- System-wide settings can't be modified
- No skip mechanism for privileged operations

### Real Example
```yaml
# Shell registration requires sudo to modify /etc/shells
# Without --skip-tags register_shell, deployment fails in BeyondTrust environment

# INCORRECT - No fallback mechanism
- name: Register shell in /etc/shells
  lineinfile:
    path: /etc/shells
    line: "{{ shell_path }}"
  become: yes  # Fails in restricted environment!

# CORRECT - Tagged for optional skip
- name: Register shell in /etc/shells
  lineinfile:
    path: /etc/shells
    line: "{{ shell_path }}"
  become: yes
  tags:
    - register_shell  # Can skip with --skip-tags register_shell
```

### Prevention Strategy
1. Tag all privileged operations with descriptive tags
2. Document required privileges in module README
3. Provide skip instructions for restricted environments:
   ```bash
   ansible-playbook playbooks/deploy.yml --skip-tags register_shell
   ```
4. Test deployment with `--check` flag first
5. Avoid system-wide modifications when user-level alternatives exist
6. Document what functionality is lost when skipping privileged steps

### Detection Method
```bash
# Find privileged operations
rg "become: yes" modules/*/
rg "sudo" modules/*/files/
rg "/etc/" modules/*/
```

### Phase to Address
**Planning Phase** - Identify privilege requirements early
**Implementation Phase** - Tag privileged tasks appropriately
**Documentation Phase** - Document skip flags and consequences

---

## 12. Module Ordering Dependencies in Playbook

### Problem
Modules listed in wrong order in playbook, causing runtime failures when later modules depend on earlier ones being fully configured.

### Warning Signs
- Intermittent deployment failures
- "Command not found" during deployment
- Environment variables not set when needed
- Symlinks reference non-existent targets
- Merge operations fail due to missing base files

### Real Example
```yaml
# INCORRECT order
dotmodules:
  install:
    - node         # Fails! Needs mise from dev-tools
    - dev-tools    # Too late - node already tried to use mise
    - editor       # Fails! References eza from shell
    - shell        # Too late - editor already deployed

# CORRECT order
dotmodules:
  install:
    - git          # No dependencies
    - fonts        # No dependencies
    - shell        # Provides utilities for others
    - dev-tools    # Provides mise for node
    - node         # Uses mise from dev-tools
    - fish         # Uses shell utilities
    - zsh          # Uses shell utilities
    - editor       # Uses shell utilities
```

Dependency graph:
```
shell (base utilities)
  ├── zsh (uses eza)
  ├── fish (uses utilities)
  └── editor (references utilities)

dev-tools (provides mise)
  └── node (uses mise)

git (independent)
fonts (independent)
1password (independent)
```

### Prevention Strategy
1. Create dependency graph before adding new module
2. List modules in playbook with dependencies first
3. Document dependencies in module README "Prerequisites"
4. Use topological ordering: if A depends on B, B comes first
5. Group modules by layer:
   - Layer 1: No dependencies (git, fonts, 1password)
   - Layer 2: Base utilities (shell, dev-tools)
   - Layer 3: Depends on Layer 2 (node, zsh, fish, editor)

### Detection Method
```bash
# Check playbook order vs dependency graph
cat playbooks/deploy.yml | grep "^        - " | nl

# Manually verify each module's prerequisites
for module in $(grep "^        - " playbooks/deploy.yml | cut -d'-' -f2); do
  echo "=== $module ==="
  rg "prerequisite|depend|require" modules/$module/README.md -i || echo "None documented"
done
```

### Phase to Address
**Planning Phase** - Map dependencies before implementation
**Integration Phase** - Add module to playbook in correct position
**Testing Phase** - Deploy on clean system to verify order

---

## 13. Conflicting Stow Directories

### Problem
Multiple modules trying to stow the same directory name, or stow directory name conflicting with existing dotfiles structure.

### Warning Signs
- Stow errors: "cannot stow over existing directory"
- Symlinks from one module overwrite another's
- Directory exists but not a symlink when it should be
- Module deployment succeeds but files missing

### Real Example
```yaml
# modules/shell/config.yml
stow_dirs:
  - shell

# modules/new-module/config.yml - CONFLICT!
stow_dirs:
  - shell  # Same directory name as shell module!
```

Current stow directories in use:
- git
- fonts
- shell
- fish
- zsh
- dev-tools
- node
- editor
- 1password

### Prevention Strategy
1. Name stow directory same as module name (convention)
2. Check existing stow_dirs before naming:
   ```bash
   rg "stow_dirs:" modules/*/config.yml -A 2
   ```
3. Use unique, descriptive directory names
4. Understand Stow's directory folding behavior
5. Keep one stow directory per module unless absolutely necessary

### Detection Method
```bash
# Find duplicate stow directory names
rg "stow_dirs:" modules/*/config.yml -A 5 | grep "  - " | sort | uniq -d
```

### Phase to Address
**Planning Phase** - Choose unique stow directory name
**Implementation Phase** - Verify uniqueness before creating

---

## 14. Forgetting to Create README.md

### Problem
Creating module with config.yml and files/ but no README.md documenting purpose, features, usage, or troubleshooting.

### Warning Signs
- No documentation of what module does
- Users don't know how to use installed tools
- Post-deployment steps unclear
- Troubleshooting information missing
- Module purpose forgotten over time

### Real Example
```
# INCOMPLETE module structure
modules/new-module/
├── config.yml        # Exists
└── files/            # Exists
    └── .config/...
# Missing: README.md

# COMPLETE module structure
modules/new-module/
├── README.md         # Comprehensive documentation
├── config.yml        # Configuration
└── files/            # Files to deploy
    └── .config/...
```

### Prevention Strategy
1. Create README.md before writing any code
2. Use existing modules as templates (zsh, shell, node have good examples)
3. Include standard sections:
   - Module purpose and description
   - Core features
   - Installation components (packages, configs)
   - Usage examples
   - Post-deployment steps
   - Troubleshooting
   - Dependencies/prerequisites
4. Document local override patterns
5. Explain any non-obvious configurations

### Detection Method
```bash
# Find modules missing README
for module in modules/*/; do
  [[ ! -f "$module/README.md" ]] && echo "Missing README: $module"
done
```

### Phase to Address
**Planning Phase** - Draft README outline during design
**Implementation Phase** - Write README alongside code
**Documentation Phase** - Review and expand README

---

## 15. Not Testing on Clean System

### Problem
Only testing module deployment on development machine with existing configurations, missing issues that appear on fresh installations.

### Warning Signs
- "Works on my machine" syndrome
- Users report failures on fresh installs
- Dependencies not captured in config
- Assumed existing tools or paths
- Hardcoded references to local setup

### Prevention Strategy
1. Test on fresh macOS VM or container
2. Use GitHub Actions / CI pipeline for testing
3. Document test procedure in module README
4. Create test playbook with only new module
5. Test both fresh install and update scenarios
6. Verify with clean home directory (no existing dotfiles)

### Detection Method
```bash
# Create isolated test
ansible-playbook -i playbooks/inventory playbooks/deploy.yml \
  --limit localhost \
  --tags dotfiles \
  --extra-vars "dotmodules={install: [new-module]}" \
  --check
```

### Phase to Address
**Testing Phase** - Required before considering module complete
**Code Review Phase** - Require test evidence in PR

---

## Summary: Critical Checkpoints by Phase

### Planning Phase
- [ ] Research existing mergeable files
- [ ] Map module dependencies
- [ ] Identify privilege requirements
- [ ] Choose unique stow directory name
- [ ] Plan local override strategy
- [ ] Draft README outline

### Implementation Phase
- [ ] Verify Homebrew package names
- [ ] Use dynamic paths (no hardcoding)
- [ ] Add section markers to mergeable content
- [ ] Add local override sourcing
- [ ] Tag privileged operations
- [ ] Document post-deployment steps

### Integration Phase
- [ ] Check for duplicate playbook entries
- [ ] Verify module ordering in playbook
- [ ] Confirm unique stow directory
- [ ] Review mergeable file conflicts

### Testing Phase
- [ ] Deploy on clean system
- [ ] Test with --skip-tags for restricted environment
- [ ] Verify symlink locations
- [ ] Check merged file contents
- [ ] Confirm dependencies resolved

### Documentation Phase
- [ ] Complete README with all sections
- [ ] Document prerequisites
- [ ] Explain post-deployment steps
- [ ] Provide local override examples
- [ ] Note BeyondTrust skip flags

---

## Quick Reference: Pre-Implementation Checklist

Before creating a new module, run these checks:

```bash
# 1. Check for duplicate modules in playbook
grep -n "module-name" playbooks/deploy.yml

# 2. Find existing mergeable files
rg "mergeable_files:" modules/*/config.yml -A 5

# 3. Check existing stow directories
rg "stow_dirs:" modules/*/config.yml -A 2

# 4. Verify Homebrew package names
brew info package-name

# 5. Review existing module structure
ls -la modules/similar-module/

# 6. Check for hardcoded paths in similar modules
rg "(/usr/local|/opt/homebrew|/Users/)" modules/similar-module/files/
```

This checklist prevents the most common pitfalls before they occur.
