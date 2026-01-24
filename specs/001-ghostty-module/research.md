# Research: Ghostty Terminal Module

**Feature**: 001-ghostty-module
**Date**: 2026-01-23

## Research Summary

This feature follows well-established patterns in the existing codebase. Research focused on verifying existing patterns and Ghostty configuration requirements.

## Findings

### 1. Existing Module Pattern Analysis

**Decision**: Follow the git module pattern (simple stow-only module)

**Rationale**:
- The git module (`modules/git/`) is the closest match - it has `stow_dirs` configuration and files in `.config/` subdirectory
- Pattern is proven and well-integrated with ansible-role-dotmodules
- No Homebrew dependencies needed for Ghostty (installed separately)

**Alternatives Considered**:
- Fish module pattern: Includes `homebrew_packages`, `mergeable_files`, `register_shell` - overkill for Ghostty
- Fonts module pattern: Only has `homebrew_casks`, no stow - doesn't apply
- Shell module pattern: Has `mergeable_files` - not needed for single config file

### 2. Ghostty Configuration Location

**Decision**: Use `~/.config/ghostty/config` as target location

**Rationale**:
- This is Ghostty's standard XDG config location
- Verified existing config at `~/.config/ghostty/config` (776 bytes)
- Cross-platform compatible (works on both macOS and Linux)

**Alternatives Considered**:
- `~/Library/Application Support/Ghostty/` - macOS-specific, not standard
- `~/.ghostty/` - Non-standard, not used by Ghostty

### 3. Playbook Integration

**Decision**: Add `ghostty` to the install list in `playbooks/deploy.yml`

**Rationale**:
- Standard approach for all modules
- Order in list doesn't matter (no dependencies on other modules)
- Consistent with existing modules

**Alternatives Considered**:
- Separate playbook for ghostty - unnecessary complexity
- Include via separate variable file - inconsistent with current approach

### 4. Module Directory Structure

**Decision**: Use `modules/ghostty/files/.config/ghostty/config` structure

**Rationale**:
- Matches stow convention: files/ directory mirrors home directory structure
- When stowed, creates `~/.config/ghostty/config` symlink
- Consistent with git module's `.config/gh/` structure

**Alternatives Considered**:
- Flat structure (`files/config`) - would require custom stow target, non-standard

## Technical Notes

### Ghostty Config Format
- Plain text key=value pairs
- No special processing needed
- Comments use `#` prefix

### Stow Behavior
- Creates symlinks from `~/.dotmodules/ghostty/files/` to `~/`
- Handles nested directories automatically
- Conflict detection built-in (warns if target exists and isn't a symlink)

## Outstanding Questions

None - all patterns are well-established in this codebase.

## References

- Existing modules: `modules/git/`, `modules/fish/`, `modules/shell/`
- ansible-role-dotmodules documentation (internal)
- Ghostty documentation: https://ghostty.org/docs/config
