---
phase: quick-1
plan: 01
subsystem: shell
tags: [zsh, llama, llm, shell-function]

requires: []
provides:
  - llama-serve zsh function for starting local LLM inference via llama-server
affects: [zsh]

tech-stack:
  added: []
  patterns:
    - "Named model alias pattern: case statement maps short name to file path + flags"

key-files:
  created: []
  modified:
    - modules/zsh/files/.zsh/functions.sh

key-decisions:
  - "Case statement used as extension point - add new model block before wildcard arm"
  - "Flags passed unquoted to allow word splitting (intentional for multi-flag strings)"

patterns-established:
  - "Model alias pattern: local model/file/flags vars with case statement dispatch"

requirements-completed: [QUICK-1]

duration: 5min
completed: 2026-02-19
---

# Quick Task 1: Add llama-serve Shell Function Summary

**llama-serve zsh function with named model aliases dispatching to llama-server with qwen3-8b as default**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-02-19T19:00:19Z
- **Completed:** 2026-02-19T19:05:00Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Added `llama-serve` function to `modules/zsh/files/.zsh/functions.sh`
- Default model is `qwen3-8b` when called with no arguments
- Case statement maps `qwen3-8b` to full model file path and server flags
- Unknown model names print a human-readable error listing available models and return exit 1
- Case statement serves as the documented extension point for future models

## Task Commits

Each task was committed atomically:

1. **Task 1: Add llama-serve function to functions.sh** - `10a1a44f` (feat)

## Files Created/Modified
- `modules/zsh/files/.zsh/functions.sh` - Appended llama-serve function with case-based model dispatch

## Decisions Made
- Flags string passed unquoted (`$flags` not `"$flags"`) to allow shell word splitting across multiple flag tokens - this is intentional behavior for multi-token flag strings
- Case statement placed at end of file to keep existing functions intact and make the new addition easy to spot

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required. The function references `~/models/Qwen_Qwen3-8B-Q4_K_M.gguf` which must exist for the server to actually start, but that is a runtime requirement not a configuration step.

## Next Phase Readiness

- Function is deployed once `stow` runs the zsh module (standard dotfiles workflow)
- To add new models: add a new `name)` arm to the case statement before `*)` with `file` and `flags` values, then update the `echo "  name"` line in the `*)` arm

---
*Phase: quick-1*
*Completed: 2026-02-19*
