---
phase: 07-cleanup-and-documentation
plan: 01
subsystem: infra
tags: [ansible, stow, cleanup, merge-removal, conf.d]

# Dependency graph
requires:
  - phase: 04-zsh-conf-d-migration
    provides: Zsh conf.d fragments replacing merged files
  - phase: 05-fish-conf-d-migration
    provides: Fish conf.d fragments replacing merged files
  - phase: 06-mise-conf-d-migration
    provides: Mise conf.d fragments replacing merged files
provides:
  - Clean module config.yml files without mergeable_files
  - Cleaned ansible-role-dotmodules without merge infrastructure
  - No stale merged files on disk
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "All module config uses stow_dirs only (no mergeable_files)"

key-files:
  created: []
  modified:
    - modules/editor/config.yml
    - modules/zsh/config.yml
    - modules/shell/config.yml
    - modules/fish/config.yml
    - modules/node/config.yml
    - modules/dev-tools/config.yml

key-decisions:
  - "Cleaned stow_module.yml of dead mergeable_files branching (deviation Rule 2)"
  - "Removed merge-specific test playbooks from role repo"

patterns-established:
  - "Module config.yml only declares homebrew_packages, stow_dirs, register_shell"

requirements-completed: [MIGR-01, CLNP-01, CLNP-02]

# Metrics
duration: 3min
completed: 2026-03-11
---

# Phase 7 Plan 1: Remove Merge Infrastructure Summary

**Removed mergeable_files from 6 module configs, deleted merge/conflict resolution from ansible-role-dotmodules, cleaned stale ~/.dotmodules/merged/ directory**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-11T18:04:56Z
- **Completed:** 2026-03-11T18:07:43Z
- **Tasks:** 2
- **Files modified:** 6 (dotfiles repo) + 7 (role repo)

## Accomplishments
- Removed mergeable_files key from all 6 module config.yml files (editor, zsh, shell, fish, node, dev-tools)
- Deleted merge_files.yml, conflict_resolution.yml, merged_file.j2 from ansible-role-dotmodules
- Simplified stow_module.yml by removing all mergeable_files branching logic
- Removed include_tasks references to merge/conflict resolution from main.yml
- Cleaned ~/.dotmodules/merged/ directory (5 stale files)
- Verified zero broken symlinks in ~/.zsh/, ~/.config/fish/, ~/.config/mise/

## Task Commits

Each task was committed atomically:

1. **Task 1: Remove mergeable_files from all module config.yml files and clean role merge logic** - `42c33ecf` (chore) in dotfiles repo + `3beba0b` in ansible-role-dotmodules
2. **Task 2: Clean stale merged directory and verify no broken symlinks** - No repo commit (filesystem cleanup only)

## Files Created/Modified
- `modules/editor/config.yml` - Removed mergeable_files section
- `modules/zsh/config.yml` - Removed mergeable_files section
- `modules/shell/config.yml` - Removed mergeable_files section
- `modules/fish/config.yml` - Removed mergeable_files section
- `modules/node/config.yml` - Removed mergeable_files section
- `modules/dev-tools/config.yml` - Removed mergeable_files section
- (external) `ansible-role-dotmodules/tasks/main.yml` - Removed include_tasks for merge/conflict
- (external) `ansible-role-dotmodules/tasks/stow_module.yml` - Simplified, removed mergeable_files branching
- (external) `ansible-role-dotmodules/tasks/merge_files.yml` - Deleted
- (external) `ansible-role-dotmodules/tasks/conflict_resolution.yml` - Deleted
- (external) `ansible-role-dotmodules/templates/merged_file.j2` - Deleted
- (external) `ansible-role-dotmodules/tests/test-merge.yml` - Deleted
- (external) `ansible-role-dotmodules/tests/test-merge-and-stow.yml` - Deleted

## Decisions Made
- Cleaned stow_module.yml of dead mergeable_files branching logic (not in plan, but dead code after merge removal)
- Removed merge-specific test playbooks (test-merge.yml, test-merge-and-stow.yml) since they test deleted functionality

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Dead Code Cleanup] Simplified stow_module.yml**
- **Found during:** Task 1
- **Issue:** stow_module.yml had extensive branching for mergeable_files (ignore patterns, filtered stow, dual deploy paths). With mergeable_files removed from all configs, this was dead code.
- **Fix:** Simplified to single code path without mergeable_files conditionals
- **Files modified:** ansible-role-dotmodules/tasks/stow_module.yml
- **Verification:** No mergeable_files references remain in role task files
- **Committed in:** 3beba0b (role repo)

**2. [Rule 2 - Dead Code Cleanup] Removed merge test playbooks**
- **Found during:** Task 1
- **Issue:** test-merge.yml and test-merge-and-stow.yml test deleted merge functionality
- **Fix:** Removed both test files
- **Files modified:** ansible-role-dotmodules/tests/test-merge.yml, ansible-role-dotmodules/tests/test-merge-and-stow.yml
- **Verification:** Files deleted
- **Committed in:** 3beba0b (role repo)

---

**Total deviations:** 2 auto-fixed (2 dead code cleanup)
**Impact on plan:** Both cleanups necessary to avoid confusion from dead code. No scope creep.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Merge infrastructure fully removed, ready for documentation plan (07-02)
- ansible-role-dotmodules pushed to origin with clean merge removal

## Self-Check: PASSED

All 6 modified config.yml files exist. Commit 42c33ecf verified in git log.

---
*Phase: 07-cleanup-and-documentation*
*Completed: 2026-03-11*
