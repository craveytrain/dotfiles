# Feature Specification: Homebrew Shell Registration

**Feature Branch**: `001-register-homebrew-shells`  
**Created**: 2025-12-18  
**Status**: Draft  
**Input**: User description: "Automate registration of Homebrew shells in /etc/shells with idempotent Ansible tasks"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automated Shell Registration During Initial Setup (Priority: P1)

A developer runs the Ansible playbook for the first time on a fresh macOS system. The playbook installs Homebrew shells (zsh, fish) and automatically registers them in `/etc/shells`, making them available as login shells without manual intervention.

**Why this priority**: This is the core value proposition - eliminating manual steps during initial system setup. Without this, users must manually edit system files, which is error-prone and requires elevated privileges.

**Independent Test**: Can be fully tested by running the playbook on a clean system and verifying `/etc/shells` contains Homebrew shell paths. Delivers immediate value by enabling shell switching without manual configuration.

**Acceptance Scenarios**:

1. **Given** a fresh macOS system with no Homebrew shells installed, **When** the user runs the Ansible playbook with zsh module enabled, **Then** `/opt/homebrew/bin/zsh` is added to `/etc/shells`
2. **Given** a fresh macOS system with no Homebrew shells installed, **When** the user runs the playbook with fish module enabled, **Then** `/opt/homebrew/bin/fish` is added to `/etc/shells`
3. **Given** both zsh and fish modules are enabled, **When** the playbook runs, **Then** both shell paths are registered in `/etc/shells`

---

### User Story 2 - Idempotent Re-runs Without Duplication (Priority: P1)

A developer makes changes to their dotfiles configuration and re-runs the Ansible playbook multiple times. The shell registration tasks detect that shells are already registered and do not create duplicate entries in `/etc/shells`.

**Why this priority**: Idempotency is a core principle (Constitution §2). Without this, repeated playbook runs would corrupt the system file with duplicates, violating user trust and system integrity.

**Independent Test**: Can be tested by running the playbook multiple times consecutively and verifying `/etc/shells` contains exactly one entry per shell. Delivers value by ensuring safe, repeatable deployments.

**Acceptance Scenarios**:

1. **Given** `/etc/shells` already contains `/opt/homebrew/bin/zsh`, **When** the playbook runs again, **Then** no duplicate entry is added
2. **Given** the playbook has been run successfully once, **When** run 10 times consecutively, **Then** `/etc/shells` remains unchanged after the first run
3. **Given** shells are already registered, **When** the playbook runs, **Then** Ansible reports "ok" status (no changes) rather than "changed"

---

### User Story 3 - Selective Module Registration (Priority: P2)

A developer enables only the fish module in their playbook configuration. When the playbook runs, only fish is registered in `/etc/shells`, and zsh registration is skipped.

**Why this priority**: Modularity is a core principle (Constitution §1). Users should be able to selectively enable modules without affecting unrelated configuration.

**Independent Test**: Can be tested by configuring the playbook with only fish enabled and verifying that zsh is not registered. Delivers value by respecting user module choices.

**Acceptance Scenarios**:

1. **Given** only fish module is in the install list, **When** the playbook runs, **Then** only `/opt/homebrew/bin/fish` is added to `/etc/shells`
2. **Given** zsh module is disabled (commented out), **When** the playbook runs, **Then** `/opt/homebrew/bin/zsh` is NOT added to `/etc/shells`
3. **Given** no shell modules are enabled, **When** the playbook runs, **Then** shell registration tasks are skipped entirely

---

### User Story 4 - Existing Entry Preservation (Priority: P2)

A developer has manually added `/opt/homebrew/bin/fish` to `/etc/shells` before running the playbook. When the playbook runs, it detects the existing entry and does not modify it or create duplicates.

**Why this priority**: Respects existing user configuration and prevents conflicts. Common scenario for users transitioning from manual to automated setup.

**Independent Test**: Can be tested by manually adding shell paths to `/etc/shells`, then running the playbook and verifying no changes occur. Delivers value by protecting existing configuration.

**Acceptance Scenarios**:

1. **Given** user has manually added `/opt/homebrew/bin/fish` to `/etc/shells`, **When** the playbook runs, **Then** the existing entry is preserved without modification
2. **Given** `/etc/shells` already contains both shell paths, **When** the playbook runs, **Then** Ansible reports no changes needed

---

### Edge Cases

- What happens when `/etc/shells` does not exist? (System creates it with appropriate permissions)
- What happens when user lacks sudo privileges? (Task fails with clear error message requesting elevated permissions)
- What happens when Homebrew is installed in a non-standard location? (Shell paths may be incorrect - assumes standard `/opt/homebrew` location)
- What happens when a shell module is removed from the install list after previously being installed? (Shell remains in `/etc/shells` - no automatic removal)
- What happens when `/etc/shells` is read-only or protected? (Task fails with permission error)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST add `/opt/homebrew/bin/zsh` to `/etc/shells` when zsh module is enabled in playbook configuration
- **FR-002**: System MUST add `/opt/homebrew/bin/fish` to `/etc/shells` when fish module is enabled in playbook configuration
- **FR-003**: System MUST check if shell path already exists in `/etc/shells` before attempting to add it
- **FR-004**: System MUST NOT create duplicate entries in `/etc/shells` when run multiple times
- **FR-005**: System MUST require elevated privileges (sudo) to modify `/etc/shells`
- **FR-006**: System MUST only register shells for modules that are enabled in the `dotmodules.install` list
- **FR-007**: System MUST preserve existing `/etc/shells` content when adding new entries
- **FR-008**: System MUST report idempotent status (no changes) when shells are already registered
- **FR-009**: System MUST add shell paths as complete lines in `/etc/shells` (one path per line)
- **FR-010**: System MUST handle both zsh and fish registration independently based on module configuration

### Key Entities

- **/etc/shells**: System file containing list of valid login shells (one absolute path per line)
- **Shell Module**: Configuration unit (zsh or fish) defined in `dotmodules.install` list
- **Homebrew Shell Path**: Absolute path to shell binary installed via Homebrew (e.g., `/opt/homebrew/bin/zsh`)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can run the playbook multiple times without creating duplicate `/etc/shells` entries (100% idempotent)
- **SC-002**: Shell registration completes successfully on first playbook run for enabled modules (100% success rate)
- **SC-003**: Running playbook 10 consecutive times produces identical `/etc/shells` content after first run
- **SC-004**: Users can change their default shell to Homebrew versions using `chsh` immediately after playbook completion (0 manual steps required)
- **SC-005**: Playbook accurately reports "changed" status only when adding new shell entries, "ok" status on subsequent runs

## Assumptions *(mandatory)*

- Homebrew is installed in standard location (`/opt/homebrew`) on Apple Silicon or (`/usr/local`) on Intel Macs
- User running playbook has sudo privileges or can authenticate for privilege escalation
- macOS system has `/etc/shells` file or allows its creation
- Shell binaries are installed via Homebrew before registration tasks run (handled by ansible-role-dotmodules)
- Standard Ansible lineinfile module behavior is sufficient for idempotent line management

## Out of Scope

- Automatic removal of shell paths when modules are disabled
- Registration of shells installed via methods other than Homebrew
- Validation that shell binaries actually exist before registration
- Migration of users' active shell to Homebrew versions (requires explicit `chsh` command)
- Support for custom Homebrew installation paths
- Registration of shells beyond zsh and fish
