# Implementation Plan: Ghostty Terminal Module

**Branch**: `001-ghostty-module` | **Date**: 2026-01-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-ghostty-module/spec.md`

## Summary

Create a new Ansible module for Ghostty terminal configuration that integrates with the existing ansible-role-dotmodules pattern. The module will use GNU Stow to symlink configuration files from `modules/ghostty/files/.config/ghostty/` to `~/.config/ghostty/`.

## Technical Context

**Language/Version**: YAML (Ansible 2.9+), Ghostty config format (plain text key=value)
**Primary Dependencies**: ansible-role-dotmodules, GNU Stow (already installed via shell module)
**Storage**: File-based configuration (`~/.config/ghostty/config`)
**Testing**: Manual verification via Ansible playbook run
**Target Platform**: macOS (primary), Linux (compatible)
**Project Type**: Configuration module (dotfiles pattern)
**Performance Goals**: N/A (configuration deployment)
**Constraints**: Must follow existing module conventions exactly
**Scale/Scope**: Single module with one configuration file

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| 1. Modularity | ✅ PASS | Ghostty module is self-contained, no dependencies on other modules |
| 2. Idempotency | ✅ PASS | Stow operations are idempotent by design |
| 3. Automation-First | ✅ PASS | No manual steps required beyond playbook run |
| 4. Cross-Platform Awareness | ✅ PASS | `~/.config/ghostty/` is standard XDG location on both macOS and Linux |
| 5. Configuration Merging | ✅ PASS | Single config file, no merging needed |
| 6. Documentation-First | ✅ PASS | Spec created before implementation |
| 7. Version Control | ✅ PASS | All config will be committed to repo |
| 8. Declarative Over Imperative | ✅ PASS | Using YAML config.yml, no shell scripts |

**Gate Status**: PASSED - All principles satisfied

## Project Structure

### Documentation (this feature)

```text
specs/001-ghostty-module/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output
├── checklists/
│   └── requirements.md  # Quality checklist
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
modules/ghostty/
├── config.yml                    # Module configuration (stow_dirs)
├── README.md                     # Module documentation
└── files/
    └── .config/
        └── ghostty/
            └── config            # Ghostty configuration (migrated from ~/.config/ghostty/)

playbooks/
└── deploy.yml                    # Updated to include ghostty module
```

**Structure Decision**: Single module following existing dotfiles module pattern. No contracts/ or data-model.md needed as this is a simple file deployment feature.

## Complexity Tracking

> No violations - all constitution principles satisfied with the simplest possible approach.

## Implementation Approach

### Files to Create

1. **`modules/ghostty/config.yml`** - Module configuration
   ```yaml
   ---
   # Ghostty terminal configuration module
   # Provides Ghostty configuration for consistent terminal appearance

   stow_dirs:
     - ghostty
   ```

2. **`modules/ghostty/files/.config/ghostty/config`** - Copy of existing config from `~/.config/ghostty/config`

3. **`modules/ghostty/README.md`** - Module documentation

### Files to Modify

1. **`playbooks/deploy.yml`** - Add `ghostty` to the install list

### Migration Steps

1. Create module directory structure
2. Copy existing Ghostty config from `~/.config/ghostty/config` to module
3. Remove original config file (will be replaced by symlink)
4. Run playbook to deploy via stow
5. Verify symlink points to module files

## Dependencies

- **Existing**: stow (installed via shell module), ansible-role-dotmodules
- **New**: None required

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Stow conflict with existing config | Medium | Low | Backup and remove original before stow |
| Ghostty not installed on target | Low | None | Config deploys regardless; Ghostty uses it when installed |

## Success Verification

1. `~/.config/ghostty/config` exists and is a symlink to `modules/ghostty/files/.config/ghostty/config`
2. Ghostty (if installed) loads configuration without errors
3. Module appears in playbook output during deployment
