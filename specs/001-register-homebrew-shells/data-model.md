# Data Model: Homebrew Shell Registration

**Feature**: 001-register-homebrew-shells  
**Date**: 2025-12-18

## Overview

This feature operates on a simple system file (`/etc/shells`) with minimal data structures. No databases, APIs, or complex entities involved - only file-based configuration managed by Ansible.

## Entities

### 1. /etc/shells (System File)

**Description**: UNIX standard file containing list of valid login shells

**Type**: Plain text file (system-managed)

**Location**: `/etc/shells` (fixed path on all UNIX-like systems)

**Format**:
- One absolute shell path per line
- No comments or metadata
- Empty lines ignored
- Must be world-readable for `chsh` validation

**Ownership & Permissions**:
- Owner: `root:wheel` (macOS standard)
- Permissions: `644` (rw-r--r--)
- Modified only with elevated privileges

**Example Content**:
```
# System default shells (macOS)
/bin/bash
/bin/csh
/bin/dash
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh

# Homebrew shells (added by this feature)
/opt/homebrew/bin/zsh
/opt/homebrew/bin/fish
```

**Lifecycle**:
- Created during OS installation
- Modified by package managers, users, automation tools
- Never deleted (system file)
- Grows only (entries rarely removed)

**Validation Rules**:
- Each line must be absolute path (starts with `/`)
- Path should point to executable file (not enforced by file)
- Duplicates allowed by format but undesirable
- Used by `chsh` to validate shell changes

**State Management**:
- This feature: Append-only (no removal)
- Ansible: Idempotent additions via `lineinfile`
- Manual edits: Preserved, not overwritten

---

### 2. Shell Module (Configuration Entity)

**Description**: Logical unit representing a shell module in dotfiles configuration

**Type**: String literal in Ansible variables

**Source**: `dotmodules.install` list in `playbooks/deploy.yml`

**Attributes**:
- **Name** (string): Module identifier (e.g., `'zsh'`, `'fish'`)
- **Enabled** (boolean): Presence in install list indicates enabled
- **Shell Path** (derived): Module name maps to Homebrew binary path

**Example**:
```yaml
dotmodules:
  install:
    - zsh    # Enables zsh module → triggers /opt/homebrew/bin/zsh registration
    - fish   # Enables fish module → triggers /opt/homebrew/bin/fish registration
```

**Relationships**:
- Module name → Shell binary path (one-to-one mapping)
- Module enabled → Shell registered in `/etc/shells` (conditional)

**Validation Rules**:
- Must be valid module name (matches directory in `modules/`)
- Case-sensitive string matching
- No duplicates in install list (Ansible handles gracefully)

**State Transitions**:
```
Module not in list → Shell not registered
Module added to list → Shell registered (on next playbook run)
Module removed from list → Shell remains registered (no auto-cleanup)
```

---

### 3. Homebrew Shell Path (Derived Value)

**Description**: Absolute path to shell binary installed via Homebrew

**Type**: String constant (derived from module name)

**Format**: `/opt/homebrew/bin/{shell_name}`

**Mapping Table**:
| Module Name | Shell Binary Path |
|-------------|------------------|
| `zsh` | `/opt/homebrew/bin/zsh` |
| `fish` | `/opt/homebrew/bin/fish` |

**Validation**:
- Path must be absolute (starts with `/`)
- Binary should exist (assumed via ansible-role-dotmodules)
- Path must match Homebrew installation location

**Platform Variants** (not currently supported):
- Apple Silicon: `/opt/homebrew/bin/*` (current implementation)
- Intel Mac: `/usr/local/bin/*` (requires manual adjustment)
- Custom Homebrew: User-defined paths (not supported)

---

## Relationships

```
┌─────────────────────┐
│ dotmodules.install  │
│   (YAML list)       │
└──────────┬──────────┘
           │
           │ contains
           ▼
    ┌─────────────┐
    │   'zsh'     │────────┐
    │   'fish'    │        │
    └─────────────┘        │
           │               │
           │ triggers      │ maps to
           ▼               ▼
    ┌─────────────────────────────┐
    │  Ansible lineinfile task    │
    │  - Check if line exists     │
    │  - Add if missing           │
    └──────────┬──────────────────┘
               │
               │ modifies
               ▼
        ┌─────────────┐
        │ /etc/shells │
        │   (file)    │
        └─────────────┘
               │
               │ validates
               ▼
        ┌─────────────┐
        │ chsh command│
        └─────────────┘
```

**Flow**:
1. User enables module in `dotmodules.install`
2. Ansible evaluates `when` condition
3. Module name maps to shell binary path
4. `lineinfile` checks if path exists in `/etc/shells`
5. If missing, path appended to file
6. User can run `chsh -s {path}` to switch shells

---

## Data Constraints

### Hard Constraints (Enforcement)
- `/etc/shells` must be writable with sudo
- Shell paths must be absolute (format requirement)
- File must be readable by all users (permission requirement)

### Soft Constraints (Assumptions)
- Homebrew installed in standard location
- Shell binaries exist before registration
- File format preserved (one path per line)
- No concurrent modifications during Ansible run

---

## State Transitions

### /etc/shells File States

```
┌──────────────────┐
│ File missing     │ (rare, fresh install)
│ or empty         │
└────────┬─────────┘
         │ create
         ▼
┌──────────────────┐
│ System defaults  │ (macOS standard shells)
│ only             │
└────────┬─────────┘
         │ add Homebrew zsh
         ▼
┌──────────────────┐
│ System defaults  │
│ + zsh            │
└────────┬─────────┘
         │ add Homebrew fish
         ▼
┌──────────────────┐
│ System defaults  │
│ + zsh + fish     │ ← Final state
└──────────────────┘
         │
         │ re-run playbook
         ▼
┌──────────────────┐
│ No change        │ (idempotent)
│ (already present)│
└──────────────────┘
```

### Module Registration States

```
Module 'zsh':

[Not in install list] ─add to list─> [In install list] ─run playbook─> [Registered in /etc/shells]
                                              │                                │
                                              │                                │
                                    remove from list                      (persists)
                                              │                                │
                                              ▼                                │
                                    [Not in install list] <──────────────────┘
                                    (shell remains registered)
```

**Note**: Removal from install list does NOT remove shell from `/etc/shells` (by design - respects user choice to keep shell available)

---

## Edge Cases & Handling

### Case 1: File Does Not Exist
- **Scenario**: Fresh system, `/etc/shells` missing
- **Handling**: `lineinfile` creates file with correct permissions
- **Result**: File created, shell path added
- **Risk**: Low (macOS always creates this file)

### Case 2: Duplicate Entries
- **Scenario**: Manual edit added same path before Ansible run
- **Handling**: `lineinfile` detects exact match, skips addition
- **Result**: Single entry preserved, idempotent
- **Risk**: None

### Case 3: Concurrent Modifications
- **Scenario**: User or process modifies `/etc/shells` during playbook run
- **Handling**: Ansible atomic file writes prevent corruption
- **Result**: Last write wins, file integrity maintained
- **Risk**: Low (rare scenario)

### Case 4: Permission Denied
- **Scenario**: User lacks sudo privileges
- **Handling**: Task fails with clear error message
- **Result**: Playbook stops, user prompted to authenticate
- **Risk**: Expected failure mode

### Case 5: Read-Only File System
- **Scenario**: macOS recovery mode or system protection active
- **Handling**: `lineinfile` fails with permission error
- **Result**: Playbook fails, clear error message
- **Risk**: Low (normal operation mode allows writes)

---

## Data Validation

### Pre-Conditions (Checked by Ansible)
- [ ] File path exists or can be created
- [ ] Process has write permissions (via `become: yes`)
- [ ] Line content is valid string

### Post-Conditions (Ensured by Implementation)
- [x] File contains exactly one entry per shell path
- [x] File permissions preserved (644)
- [x] Existing content untouched
- [x] Idempotent result (unchanged on re-run)

### Testing Validation
```bash
# Verify file integrity
ls -la /etc/shells                          # Check permissions: -rw-r--r--

# Verify content
cat /etc/shells                             # View all entries

# Count Homebrew entries
grep -c homebrew /etc/shells                # Should be: 2 (if both modules enabled)

# Check for duplicates
sort /etc/shells | uniq -d                  # Should be: empty (no duplicates)

# Verify shell functionality
chsh -s /opt/homebrew/bin/zsh              # Should succeed
echo $SHELL                                 # Should show new shell after re-login
```

---

## Summary

**Data Complexity**: Minimal
- Single file entity (`/etc/shells`)
- Simple text format (one path per line)
- No relational data or complex structures
- State managed entirely by Ansible `lineinfile`

**Key Insight**: Simplicity is a feature - leveraging existing UNIX standards and Ansible built-ins eliminates need for custom data management code.
