# Feature Specification: Ghostty Terminal Module

**Feature Branch**: `001-ghostty-module`
**Created**: 2026-01-23
**Status**: Draft
**Input**: User description: "I've added config files for Ghostty. I'd like to make that part of this repo so that it can be part of the dot files repo so that it can transfer between computers. Should that be its own package or how should we make that happen?"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Deploy Ghostty Configuration to New Machine (Priority: P1)

As a user setting up a new machine, I want my Ghostty terminal configuration automatically deployed so that my terminal looks and behaves consistently across all my computers.

**Why this priority**: This is the core value proposition - portable terminal configuration that follows the user across machines.

**Independent Test**: Can be fully tested by running the dotfiles Ansible playbook on a clean machine and verifying Ghostty configuration appears at `~/.config/ghostty/config` with expected settings.

**Acceptance Scenarios**:

1. **Given** a new machine without Ghostty configuration, **When** the user runs the dotfiles Ansible playbook, **Then** Ghostty configuration files are symlinked to the correct location (`~/.config/ghostty/`)
2. **Given** the dotfiles have been deployed, **When** the user opens Ghostty, **Then** Ghostty uses the configured settings (theme, fonts, keybindings)
3. **Given** the Ghostty module is included in the playbook, **When** Ansible runs, **Then** the module integrates with existing ansible-role-dotmodules patterns

---

### User Story 2 - Update Ghostty Configuration (Priority: P2)

As a user who wants to customize my terminal, I want to edit Ghostty settings in one place and have changes sync to all machines so that I maintain consistency without manual copying.

**Why this priority**: Ongoing maintenance and customization is important but secondary to initial deployment.

**Independent Test**: Can be tested by modifying the Ghostty config in the repo, running the playbook, and verifying changes appear in the deployed config.

**Acceptance Scenarios**:

1. **Given** a deployed Ghostty configuration, **When** the user edits `modules/ghostty/files/.config/ghostty/config`, **Then** the change is immediately reflected via symlink (no re-run needed)
2. **Given** changes to Ghostty module, **When** the user commits and pushes, **Then** other machines can pull and have updated configuration

---

### Edge Cases

- What happens when Ghostty is not installed on the target machine? The module should deploy configuration regardless; Ghostty will use it when installed.
- What happens if `~/.config/ghostty/` already exists with user files? GNU Stow will detect conflicts and report them (consistent with existing behavior).
- What happens on non-macOS systems? Ghostty config location is the same (`~/.config/ghostty/`), so the module works cross-platform.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST create a new Ansible module at `modules/ghostty/` following existing module conventions
- **FR-002**: System MUST include a `config.yml` with appropriate configuration for the ansible-role-dotmodules pattern
- **FR-003**: System MUST store Ghostty configuration files in `modules/ghostty/files/.config/ghostty/` directory structure
- **FR-004**: System MUST use GNU Stow for symlinking Ghostty config to user's home directory
- **FR-005**: System MUST preserve existing Ghostty configuration content when migrating to the module
- **FR-006**: Module MUST integrate with the existing Ansible playbook structure

### Key Entities

- **Ghostty Module**: A new directory at `modules/ghostty/` containing configuration and files following the established module pattern
- **Ghostty Config File**: The terminal configuration file deployed to `~/.config/ghostty/config`
- **Module Config**: YAML file (`config.yml`) defining stow directories and any Homebrew dependencies

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: User can run the Ansible playbook and have Ghostty configuration deployed to `~/.config/ghostty/`
- **SC-002**: Ghostty configuration transfers successfully between machines via git clone + playbook run
- **SC-003**: Module follows 100% of existing module conventions (config.yml structure, files directory layout, stow_dirs pattern)
- **SC-004**: No manual steps required beyond running the standard dotfiles deployment process

## Assumptions

- Ghostty configuration lives at `~/.config/ghostty/config` (standard XDG location)
- User has existing Ghostty config at `~/.config/ghostty/config` to migrate into the module
- The ansible-role-dotmodules role handles stow deployment automatically when `stow_dirs` is specified
- No Homebrew package is needed for Ghostty (it's installed separately via .dmg or other means)

## Scope

### In Scope

- Creating the Ghostty module directory structure
- Migrating existing Ghostty configuration into the module
- Configuring stow deployment for the module
- Integration with existing Ansible playbook

### Out of Scope

- Ghostty installation automation (users install Ghostty separately)
- Ghostty themes or plugins beyond current configuration
- Integration with shell modules for Ghostty-specific shell configuration
