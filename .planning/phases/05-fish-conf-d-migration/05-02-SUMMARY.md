---
phase: 05-fish-conf-d-migration
plan: 02
subsystem: shell-config
tags: [fish, conf.d, stow, deployment, verification]

# Dependency graph
requires:
  - phase: 05-fish-conf-d-migration
    plan: 01
    provides: 4 conf.d fragment files, mux.fish function, minimal config.fish skeleton
provides:
  - deployed fish conf.d migration with stow symlinks from 4 modules into ~/.config/fish/conf.d/
  - verified live fish session with conf.d sourcing pattern
affects: [06-mise-conf-d-migration, 07-cleanup]

# Tech tracking
tech-stack:
  added: []
  patterns: [manual stow deployment with --no-folding and mergeable file exclusion]

key-files:
  created: []
  modified: []

key-decisions:
  - "Manual stow deployment used instead of full ansible-playbook: same pattern as Phase 4 Plan 02"
  - "Old non-stow-managed symlinks (14 files) removed before stow could claim targets"
  - "Mergeable files (config.fish) excluded from stow via --ignore flag for editor, shell, dev-tools modules"

patterns-established:
  - "stow --no-folding --ignore='config\\.fish' for modules with mergeable files"
  - "Old symlinks must be removed before stow can claim targets"

requirements-completed: [SHRC-02]

# Metrics
duration: ~15min
completed: 2026-03-11
---

# Phase 5 Plan 02: Fish conf.d Deployment and Verification Summary

**Deployed 4-module fish conf.d migration via stow, verified live fish session sources all fragments with correct env vars, abbreviations, and mise activation**

## Performance

- **Duration:** ~15 min (includes checkpoint pause for human verification)
- **Started:** 2026-03-11T01:14:41Z
- **Completed:** 2026-03-11T01:30:00Z
- **Tasks:** 2
- **Files modified:** 0 (deployment-only, home directory symlinks)

## Accomplishments
- Deployed conf.d fragment files from 4 modules (fish, editor, shell, dev-tools) into ~/.config/fish/conf.d/ via stow
- Replaced 14 old non-stow-managed symlinks with stow-managed equivalents
- Verified fish opens without errors and all env vars, abbreviations, and tools work correctly
- Confirmed 4 conf.d symlinks present with correct numeric prefixes (10, 50, 50, 80)
- User confirmed live fish shell behavior matches pre-migration expectations

## Task Commits

Each task was committed atomically:

1. **Task 1: Deploy conf.d fragments via stow and run automated smoke tests** - no commit (deployment-only task, no repo changes)
2. **Task 2: Human verification of live fish session** - no commit (checkpoint verification, no repo changes)

## Files Created/Modified

No repository files were created or modified. This plan only affected home directory symlinks:
- `~/.config/fish/conf.d/10-fish-core.fish` - Symlink to fish module fragment
- `~/.config/fish/conf.d/50-editor-abbrs.fish` - Symlink to editor module fragment
- `~/.config/fish/conf.d/50-shell-eza-colors.fish` - Symlink to shell module fragment
- `~/.config/fish/conf.d/80-dev-tools-mise.fish` - Symlink to dev-tools module fragment
- `~/.config/fish/config.fish` - Symlink to fish module minimal skeleton (replaced old merged symlink)
- `~/.config/fish/functions/mux.fish` - Symlink to fish module extracted function
- `~/.config/fish/functions/*.fish` (12 files) - Stow-managed symlinks replacing old direct symlinks
- `~/.config/fish/fish_plugins` - Stow-managed symlink replacing old direct symlink

## Decisions Made
- **Manual stow over ansible-playbook:** Same approach as Phase 4 Plan 02. Direct stow deployment of the 4 conf.d-relevant modules avoids git module's pre-existing stow conflicts.
- **Old symlink removal:** 14 symlinks pointing to `~/dotfiles/modules/...` paths (old dotfiles repo location) were removed before stow could create its own symlinks. These included fish_plugins, 12 function files, and the merged config.fish.
- **Mergeable file exclusion:** config.fish exists in editor, shell, and dev-tools modules as a mergeable file. Using `--ignore='config\.fish'` during stow prevents cross-module conflicts.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Old non-stow-managed symlinks blocking stow deployment**
- **Found during:** Task 1 (stow deployment)
- **Issue:** 14 existing symlinks (fish_plugins, 12 function files, merged config.fish) pointed to `~/dotfiles/modules/...` paths and were not owned by stow
- **Fix:** Removed all conflicting symlinks before running stow
- **Files modified:** Home directory symlinks only (no repo changes)
- **Verification:** All 4 modules stowed successfully, all 7 automated smoke tests passed

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Expected issue (documented in Phase 4 lessons learned). Old symlinks needed removal before stow could claim targets.

## Issues Encountered
None beyond the expected old symlink conflicts.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Fish conf.d migration complete and verified in live shell
- Phase 5 fully complete (both plans done)
- config.yml mergeable_files still reference old files (Phase 7 cleanup)
- Phase 6 (Mise conf.d migration) can proceed independently
- Fisher/Tide conf.d files coexist without conflicts (underscore-prefixed naming)

## Self-Check: PASSED

All key artifacts verified: SUMMARY.md exists, 4 conf.d symlinks deployed, mux.fish symlink deployed.

---
*Phase: 05-fish-conf-d-migration*
*Completed: 2026-03-11*
