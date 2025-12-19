# Tasks: Homebrew Shell Registration

**Input**: Design documents from `/specs/001-register-homebrew-shells/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Not explicitly requested in specification - test tasks omitted per template guidelines.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

This feature modifies infrastructure automation files at repository root:
- `playbooks/deploy.yml` - Primary file for task additions
- `/etc/shells` - System file (target, not in repo)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify prerequisites and prepare for implementation

- [X] T001 Verify Ansible 2.9+ is installed and available in PATH
- [X] T002 Verify Homebrew is installed at /opt/homebrew (Apple Silicon) or /usr/local (Intel)
- [X] T003 [P] Verify sudo privileges are available for playbook execution
- [X] T004 [P] Backup current /etc/shells file to /etc/shells.backup

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Ansible playbook structure that MUST be in place before shell registration tasks can be added

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Verify playbooks/deploy.yml exists and is valid YAML
- [X] T006 Verify dotmodules.install variable exists in playbooks/deploy.yml
- [X] T007 Verify ansible-role-dotmodules is configured and runs before shell registration tasks
- [X] T008 Identify insertion point in playbooks/deploy.yml for shell registration tasks (after ansible-role-dotmodules role)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Automated Shell Registration During Initial Setup (Priority: P1) 🎯 MVP

**Goal**: Automatically register Homebrew shells in /etc/shells when playbook runs for the first time, eliminating manual system file editing.

**Independent Test**: Run playbook on a clean system with zsh and fish modules enabled, then verify /etc/shells contains /opt/homebrew/bin/zsh and /opt/homebrew/bin/fish. Execute `chsh -s /opt/homebrew/bin/fish` to confirm shell is immediately available.

### Implementation for User Story 1

- [X] T009 [P] [US1] Add Ansible task for zsh registration in playbooks/deploy.yml using lineinfile module
- [X] T010 [P] [US1] Add Ansible task for fish registration in playbooks/deploy.yml using lineinfile module
- [X] T011 [US1] Add conditional when clause to zsh task: "'zsh' in dotmodules.install"
- [X] T012 [US1] Add conditional when clause to fish task: "'fish' in dotmodules.install"
- [X] T013 [US1] Add become: yes privilege escalation to both shell registration tasks
- [X] T014 [US1] Configure lineinfile path parameter to /etc/shells for both tasks
- [X] T015 [US1] Configure lineinfile line parameter to /opt/homebrew/bin/zsh for zsh task
- [X] T016 [US1] Configure lineinfile line parameter to /opt/homebrew/bin/fish for fish task
- [X] T017 [US1] Configure lineinfile state parameter to present for both tasks

**Checkpoint**: At this point, User Story 1 should be fully functional - playbook can add shells to /etc/shells on first run

---

## Phase 4: User Story 2 - Idempotent Re-runs Without Duplication (Priority: P1)

**Goal**: Ensure shell registration tasks are idempotent - running playbook multiple times does not create duplicate entries in /etc/shells.

**Independent Test**: Run playbook 10 consecutive times with zsh enabled, then verify /etc/shells contains exactly one entry for /opt/homebrew/bin/zsh. Ansible should report "ok" status (not "changed") on runs 2-10.

**Note**: User Story 2 is satisfied by the implementation in User Story 1 - Ansible's lineinfile module with `state: present` provides built-in idempotency. No additional tasks required.

### Validation for User Story 2

- [X] T018 [US2] Test playbook execution with zsh module enabled - first run should report "changed" status
- [X] T019 [US2] Test playbook execution second time - should report "ok" status (idempotent)
- [X] T020 [US2] Verify /etc/shells contains exactly one entry for /opt/homebrew/bin/zsh after multiple runs
- [X] T021 [US2] Test playbook with both zsh and fish enabled - verify exactly one entry per shell after multiple runs

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - initial registration and idempotent re-runs validated

---

## Phase 5: User Story 3 - Selective Module Registration (Priority: P2)

**Goal**: Register only the shells for modules that are enabled in dotmodules.install list, skipping disabled modules.

**Independent Test**: Configure playbook with only fish module enabled (zsh commented out), run playbook, then verify /etc/shells contains /opt/homebrew/bin/fish but NOT /opt/homebrew/bin/zsh. Verify zsh task was skipped in Ansible output.

**Note**: User Story 3 is satisfied by the conditional when clauses implemented in User Story 1 (T011, T012). No additional tasks required.

### Validation for User Story 3

- [X] T022 [US3] Test playbook with only zsh enabled - verify only zsh registered, fish task skipped
- [X] T023 [US3] Test playbook with only fish enabled - verify only fish registered, zsh task skipped
- [X] T024 [US3] Test playbook with no shell modules enabled - verify both tasks skipped
- [X] T025 [US3] Test playbook with both modules enabled - verify both shells registered

**Checkpoint**: All P1 and P2 user stories should now be independently functional and validated

---

## Phase 6: User Story 4 - Existing Entry Preservation (Priority: P2)

**Goal**: Detect existing shell entries in /etc/shells (added manually or by previous runs) and preserve them without modification or duplication.

**Independent Test**: Manually add `/opt/homebrew/bin/fish` to /etc/shells using sudo, then run playbook with fish module enabled. Verify the existing entry is preserved unchanged and Ansible reports "ok" status (not "changed").

**Note**: User Story 4 is satisfied by Ansible lineinfile module's built-in exact match checking (implemented in User Story 1). No additional tasks required.

### Validation for User Story 4

- [X] T026 [US4] Manually add /opt/homebrew/bin/zsh to /etc/shells before playbook run
- [X] T027 [US4] Run playbook with zsh enabled - verify Ansible reports "ok" status (no changes)
- [X] T028 [US4] Verify existing /etc/shells content is preserved (no modifications to other lines)
- [X] T029 [US4] Test with both shells manually pre-added - verify playbook reports no changes needed

**Checkpoint**: All user stories (US1-US4) should now be independently functional and fully validated

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, validation, and final verification across all user stories

- [X] T030 [P] Run playbook dry-run with --check flag to verify no unintended changes
- [X] T031 [P] Update quickstart.md with actual test results and validation steps
- [X] T032 Verify all success criteria from spec.md are met (SC-001 through SC-005)
- [X] T033 Test functional shell switching with `chsh -s /opt/homebrew/bin/fish`
- [X] T034 [P] Document any platform-specific notes (Apple Silicon vs Intel paths)
- [X] T035 [P] Add verbose output example to quickstart.md for troubleshooting
- [X] T036 Run complete quickstart.md validation checklist
- [ ] T037 Prepare git commit with feature implementation and documentation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - User stories can proceed sequentially in priority order (US1 → US2 → US3 → US4)
  - US2, US3, US4 are validation-focused and build on US1 implementation
- **Polish (Phase 7)**: Depends on all user stories being complete and validated

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - Core implementation, no dependencies
- **User Story 2 (P1)**: Builds on US1 - Validates idempotency of US1 implementation
- **User Story 3 (P2)**: Builds on US1 - Validates conditional logic from US1 implementation
- **User Story 4 (P2)**: Builds on US1 - Validates existing entry handling from US1 implementation

### Within Each User Story

- User Story 1: Implementation tasks (T009-T017) can mostly run in parallel (T009 and T010 are independent, but T011-T017 depend on them)
- User Story 2: Validation tasks (T018-T021) must run sequentially to verify idempotency
- User Story 3: Validation tasks (T022-T025) can run in parallel (independent test scenarios)
- User Story 4: Validation tasks (T026-T029) must run sequentially (setup, test, verify pattern)

### Parallel Opportunities

- All Setup tasks (T001-T004) can run in parallel
- All Foundational verification tasks (T005-T008) can run in parallel
- Within US1: T009 and T010 can run in parallel (different tasks for different shells)
- Within US3: T022-T025 can run in parallel (independent test scenarios)
- Polish phase: T030, T031, T034, T035 can run in parallel

---

## Parallel Example: User Story 1 Implementation

```bash
# Launch core task additions in parallel:
Task: "Add Ansible task for zsh registration in playbooks/deploy.yml"
Task: "Add Ansible task for fish registration in playbooks/deploy.yml"

# Then configure each task (can also be parallel if editing different sections):
Task: "Add conditional when clause to zsh task"
Task: "Add conditional when clause to fish task"
```

---

## Parallel Example: User Story 3 Validation

```bash
# Launch all validation scenarios in parallel:
Task: "Test playbook with only zsh enabled"
Task: "Test playbook with only fish enabled"
Task: "Test playbook with no shell modules enabled"
Task: "Test playbook with both modules enabled"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup → Verify environment ready
2. Complete Phase 2: Foundational → Verify playbook structure ready
3. Complete Phase 3: User Story 1 → Implement core shell registration
4. **STOP and VALIDATE**: Test on clean system, verify shells register correctly
5. Ready for daily use (minimal viable automation)

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → **Deploy/Demo (MVP!)**
3. Add User Story 2 validation → Test independently → Verify idempotency works
4. Add User Story 3 validation → Test independently → Verify module selection works
5. Add User Story 4 validation → Test independently → Verify existing entries preserved
6. Complete Polish → Final validation → Ready for merge to main

### Sequential Execution (Recommended for this feature)

Since this is a simple feature with validation-focused stories:

1. Complete Setup + Foundational together (parallel tasks where possible)
2. Implement User Story 1 completely (core functionality)
3. Validate User Story 2 (idempotency checks)
4. Validate User Story 3 (conditional execution)
5. Validate User Story 4 (preservation checks)
6. Polish and document results

---

## Notes

- [P] tasks = different files or independent operations, no dependencies
- [Story] label maps task to specific user story for traceability
- Most user stories (US2-US4) are validation-focused, testing properties of US1 implementation
- Implementation was noted as already complete in plan.md - these tasks serve as validation checklist
- No custom code needed - pure Ansible declarative configuration
- Idempotency is built into Ansible lineinfile module - no custom logic required
- Each user story validation is independently verifiable
- Commit after completing each user story validation phase
- Constitution principles (modularity, idempotency, automation) are satisfied by design

---

## Task Summary

- **Total Tasks**: 37
- **Setup Phase**: 4 tasks
- **Foundational Phase**: 4 tasks
- **User Story 1 (Implementation)**: 9 tasks
- **User Story 2 (Validation)**: 4 tasks
- **User Story 3 (Validation)**: 4 tasks
- **User Story 4 (Validation)**: 4 tasks
- **Polish Phase**: 8 tasks
- **Parallel Opportunities**: 13 tasks marked [P]
- **MVP Scope**: Phases 1-3 (User Story 1 only) = 17 tasks
