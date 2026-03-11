# Phase 7: Cleanup and Documentation - Research

**Researched:** 2026-03-11
**Domain:** Ansible role cleanup, dotfiles documentation, conf.d conventions
**Confidence:** HIGH

## Summary

Phase 7 is the final cleanup phase of the v1.1 Runtime Includes milestone. All conf.d migrations are complete (zsh in Phase 4, fish in Phase 5, mise in Phase 6). What remains is removing the now-unused merge infrastructure from both the dotfiles repo and the external ansible-role-dotmodules repo, cleaning up stale merged files on disk, and documenting the conf.d convention for future module authors.

The work is straightforward: remove `mergeable_files` from 6 module config.yml files, delete 3 files from the role repo (plus update main.yml), clean up `~/.dotmodules/merged/`, and update README.md and CODING_STANDARDS.md with conf.d documentation.

**Primary recommendation:** Do role cleanup and config.yml cleanup first (functional changes), then documentation (non-breaking). Verify no broken symlinks after cleanup.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions
- Both README.md and CODING_STANDARDS.md get updated
- README.md: update Module Structure section to show conf.d, update "Add a New Module" instructions, remove mergeable_files from config.yml example, update "How It Works" to remove merge/conflict references
- CODING_STANDARDS.md: full conf.d walkthrough including prefix range table, fragment header format, naming pattern, per-shell differences (zsh needs shellcheck directive, fish uses native conf.d, mise has no numeric prefixes), and an end-to-end example of adding a new module with conf.d fragments
- Modify ansible-role-dotmodules directly (user's own repo at /Users/mcravey/Projects/ansible-role-dotmodules)
- Remove merge_files.yml, merged_file.j2, and conflict_resolution.yml from the role
- Commit and push changes to the role repo
- Update dotfiles requirements.yml to pin the new version (if the role uses versioning)
- Phase 7 handles both repos in the same execution
- No Ansible automation for merged directory cleanup (single-user repo)
- Delete ~/.dotmodules/merged/ as a one-off task on this machine (it's already empty)
- Verify no broken symlinks in ~/.zsh/, ~/.config/fish/, ~/.config/mise/ after changes
- Remove the mergeable_files key and its list from all 6 module config.yml files (editor, zsh, shell, fish, node, dev-tools)
- Verify no stale symlinks remain for old merge targets (aliases.sh, environment.sh, config.fish, config.toml)
- Old pre-conf.d source files are already deleted from earlier phases, so no file cleanup needed in modules/

### Claude's Discretion
- Ordering of tasks within the plan (what to do first: role cleanup, config.yml cleanup, or docs)
- Whether requirements.yml needs a version pin or just a fresh ansible-galaxy install
- Exact prefix range assignments to document (tens-based grouping, etc.)
- How to structure the end-to-end example in CODING_STANDARDS.md

### Deferred Ideas (OUT OF SCOPE)
None

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| MIGR-01 | All mergeable_files declarations removed from every module's config.yml | 6 modules confirmed with mergeable_files: editor, zsh, shell, fish, node, dev-tools. Exact YAML blocks documented below. |
| CLNP-01 | Merge logic (merge_files.yml, merged_file.j2, conflict_resolution.yml) removed from ansible-role-dotmodules | All 3 files confirmed present in role tasks/templates. main.yml references documented for removal. |
| CLNP-02 | Stale symlinks and files in ~/.dotmodules/merged/ cleaned up during deployment | Merged directory is NOT empty: contains 5 stale files. Manual rm -rf is appropriate. |
| CLNP-03 | Ordering convention documented with numeric prefix ranges and module assignment guide | All existing fragments catalogued with actual prefix numbers for documentation. |

</phase_requirements>

## Current State Analysis

### Module config.yml Files with mergeable_files

All 6 modules confirmed to have `mergeable_files` declarations:

| Module | mergeable_files entries |
|--------|----------------------|
| zsh | `.zshrc`, `.zsh/aliases.sh`, `.zsh/environment.sh` |
| editor | `.config/fish/config.fish`, `.zsh/aliases.sh`, `.zsh/environment.sh` |
| shell | `.zsh/environment.sh`, `.config/fish/config.fish` |
| fish | `.config/fish/config.fish` |
| dev-tools | `.zshrc`, `.config/fish/config.fish`, `.config/mise/config.toml` |
| node | `.config/mise/config.toml` |

**Action:** Remove the `mergeable_files:` key and all its list entries from each file. Keep all other keys (homebrew_packages, stow_dirs, register_shell, comments).

### Role Files to Remove

Located at `/Users/mcravey/Projects/ansible-role-dotmodules`:

| File | Type | Purpose (now obsolete) |
|------|------|----------------------|
| `tasks/merge_files.yml` | Task file | Collected and merged files from modules |
| `tasks/conflict_resolution.yml` | Task file | Detected merge vs stow conflicts |
| `templates/merged_file.j2` | Template | Jinja2 template for merged output |

**main.yml edits required** (lines 97-105):
- Remove the "Resolve file strategy conflicts" include_tasks block (lines 98-100)
- Remove the "Process mergeable files" include_tasks block (lines 103-105)

The role does NOT use version tags, so requirements.yml does not need a version pin. A fresh `ansible-galaxy install -r requirements.yml --force` will pull the updated role after pushing.

### Stale Merged Files on Disk

`~/.dotmodules/merged/` contains 5 stale files:
- `.zshrc`
- `.zsh/aliases.sh`
- `.zsh/environment.sh`
- `.config/fish/config.fish`
- `.config/mise/config.toml`

CONTEXT.md said "it's already empty" but it is NOT. These files exist but are no longer symlinked from the home directory (verified: `~/.zshrc` points to the zsh module's file, `~/.config/fish/config.fish` points to the fish module's file, and `~/.zsh/aliases.sh` / `~/.zsh/environment.sh` no longer exist as symlinks).

**Action:** `rm -rf ~/.dotmodules/merged/` is safe. No symlinks point into this directory.

### Current Broken Symlink Status

No broken symlinks found in `~/.zsh/`, `~/.config/fish/`, or `~/.config/mise/`. The migration to conf.d is clean.

## Architecture Patterns

### Established conf.d Convention (from Phases 4-6)

**Zsh fragments** (`~/.zsh/conf.d/`):
```
NN-module-description.sh
```
- Prefix: 2-digit numeric (00-99)
- Extension: `.sh`
- Header line 1: `# shellcheck shell=zsh`
- Header line 2: `# {module} module - {brief description}`

**Fish fragments** (`~/.config/fish/conf.d/`):
```
NN-module-description.fish
```
- Prefix: 2-digit numeric (00-99)
- Extension: `.fish`
- Header: `# {module} module - {brief description}`
- No shellcheck directive needed (fish is natively supported)
- Auto-sourced by fish's built-in conf.d mechanism

**Mise fragments** (`~/.config/mise/conf.d/`):
```
module-name.toml
```
- No numeric prefix (mise doesn't have ordering concerns)
- Extension: `.toml`
- Header: `# {module} module - {brief description}` + `# Managed by dotfiles {module} module`
- Each fragment is standalone TOML with own `[tools]` or `[settings]` headers

### Current Fragment Inventory

| Prefix | Module | Zsh File | Fish File | Mise File |
|--------|--------|----------|-----------|-----------|
| 10 | zsh | `10-zsh-core.sh` | - | - |
| 10 | fish | - | `10-fish-core.fish` | - |
| 50 | editor | `50-editor-env-aliases.sh` | `50-editor-abbrs.fish` | - |
| 50 | shell | `50-shell-eza-colors.sh` | `50-shell-eza-colors.fish` | - |
| 80 | dev-tools | `80-dev-tools-mise.sh` | `80-dev-tools-mise.fish` | `dev-tools.toml` |
| - | node | - | - | `node.toml` |

### Recommended Prefix Range Convention to Document

| Range | Purpose | Current Modules |
|-------|---------|----------------|
| 00-19 | Core shell config (shell-specific foundations) | zsh (10), fish (10) |
| 20-49 | Reserved for future core modules | (unused) |
| 50-69 | Module features (utilities, editor, aliases) | editor (50), shell (50) |
| 70-79 | Reserved for future feature modules | (unused) |
| 80-99 | Late-loading (runtime managers, tools needing PATH) | dev-tools (80) |

**Key insight:** Lower numbers load first. Runtime managers like mise go high (80+) because they may depend on PATH being set. Core shell config goes low (10) because other fragments may depend on environment variables or shell options set there.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Stale merged file detection | Ansible tasks to find/remove old merged files | Manual `rm -rf ~/.dotmodules/merged/` | Single-user, single-machine repo. Automation is overkill. |
| Role version pinning | Custom version tracking | `ansible-galaxy install --force` | Role has no tags/releases. Force reinstall pulls latest from main. |

## Common Pitfalls

### Pitfall 1: Forgetting to update main.yml
**What goes wrong:** Deleting merge_files.yml and conflict_resolution.yml without removing their `include_tasks` references in main.yml causes Ansible failures.
**How to avoid:** Remove the include_tasks blocks from main.yml BEFORE or AT THE SAME TIME as deleting the task files.

### Pitfall 2: Stale role cache
**What goes wrong:** After pushing role changes, running the dotfiles playbook still uses the old cached role.
**How to avoid:** Run `ansible-galaxy install -r requirements.yml --force` after pushing role changes to pull the updated version.

### Pitfall 3: Merged directory symlinks still active
**What goes wrong:** Deleting `~/.dotmodules/merged/` while symlinks still point to files in it creates broken symlinks in the home directory.
**Current status:** Verified safe. No symlinks point into `~/.dotmodules/merged/`. But verify again at execution time as a precaution.

### Pitfall 4: README examples showing obsolete config
**What goes wrong:** Leaving `mergeable_files` in README examples confuses future users.
**How to avoid:** Search the entire README for "mergeable", "merge", "conflict", "Configuration Aggregation" and update/remove all occurrences.

## Code Examples

### config.yml after cleanup (example: shell module)
```yaml
---
# Shell utilities module
# Provides shell-agnostic utilities used by both fish and zsh
# These are shared packages that work with any shell

homebrew_packages:
  - eza # Modern ls replacement (used by zsh aliases, useful for fish)
  - ripgrep # Fast grep alternative
  - stow # Symlink manager (used by deployment system)
  - tldr # Simplified man pages
  - trash # Safe rm replacement
  - wget # File downloader


stow_dirs:
  - shell
```

### main.yml after cleanup (relevant section)
```yaml
# Run Stow once for all modules
- name: Deploy all dotfiles using stow
  ansible.builtin.include_tasks: stow_module.yml
  loop: "{{ stow_dirs }}"
  loop_control:
    loop_var: module_name
  when: stow_dirs | length > 0
```
The two `include_tasks` blocks for `conflict_resolution.yml` and `merge_files.yml` (and their comments) should be removed entirely.

### Broken symlink verification command
```bash
find ~/.zsh/ ~/.config/fish/ ~/.config/mise/ -maxdepth 2 -type l ! -exec test -e {} \; -print
```
Should return no output if clean.

## Documentation Structure

### README.md Changes Needed

1. **Configuration section (lines 99-124):** Remove `mergeable_files` from the config.yml example and the bullet point describing it
2. **How It Works section (lines 273-278):** Remove "Configuration Aggregation" step and "Conflict Resolution" from Benefits
3. **Add a New Module sections (lines 198-203, 258-264):** Add step for creating conf.d fragments
4. **Module Structure (lines 44-54):** Add conf.d directory to the structure diagram

### CODING_STANDARDS.md Changes Needed

Add a new major section covering:
1. **conf.d Convention Overview** - what it is, why it exists
2. **Prefix Range Table** - the ranges documented above
3. **Fragment Naming Pattern** - per-shell differences
4. **Fragment Header Format** - with examples for each shell type
5. **End-to-End Example** - adding a hypothetical new module with conf.d fragments

## Open Questions

1. **requirements.yml after role push**
   - What we know: Role has no version tags, requirements.yml has no version pin
   - Recommendation: No change to requirements.yml needed. Just run `ansible-galaxy install --force` after pushing. The planner should include this as a verification step.

2. **Role repo commit and push**
   - What we know: User explicitly wants changes committed and pushed to the role repo
   - What's unclear: Whether to push from the feature branch or main
   - Recommendation: Commit directly to main in the role repo (it's a personal utility role, not a shared library). But this is the user's call at execution time.

## Sources

### Primary (HIGH confidence)
- Direct filesystem inspection of all 6 module config.yml files
- Direct inspection of ansible-role-dotmodules tasks/ and templates/
- Direct verification of ~/.dotmodules/merged/ contents
- Direct verification of symlink targets in home directory
- Existing conf.d fragments from Phases 4, 5, 6

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new libraries, just removing existing code
- Architecture: HIGH - conf.d patterns already established in Phases 4-6
- Pitfalls: HIGH - straightforward file removal with clear verification steps
- Documentation: HIGH - all fragment conventions observable from existing files

**Research date:** 2026-03-11
**Valid until:** No expiration (cleanup of internal infrastructure, no external dependencies)
