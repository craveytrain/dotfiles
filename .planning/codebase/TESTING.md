# Testing Patterns

**Analysis Date:** 2026-01-23

## Test Framework

**Runner:**
- No dedicated test framework detected in codebase
- Shell scripts tested manually and via shellcheck linting
- Linting via `shellcheck` command-line tool

**Assertion Library:**
- Not applicable; no formal test framework in use
- Manual verification of script outputs

**Run Commands:**
```bash
shellcheck script.sh              # Lint shell script
shellcheck -x script.sh           # Follow source includes
```

## Test File Organization

**Location:**
- Not detected - no formal test files exist in repository
- Integration tests appear to be manual via spec-driven development workflow
- Tests could be colocated with features in `specs/` directory alongside `spec.md` and `plan.md`

**Naming:**
- Feature specs: `specs/NNN-feature-name/spec.md`
- Implementation plans: `specs/NNN-feature-name/plan.md`
- Task lists: `specs/NNN-feature-name/tasks.md`
- Research docs: `specs/NNN-feature-name/research.md`
- Data models: `specs/NNN-feature-name/data-model.md`

**Structure:**
```
specs/
├── 001-mise-node-module/
│   ├── spec.md
│   ├── plan.md
│   ├── tasks.md
│   └── contracts/
├── 002-fix-stow-conflicts/
│   ├── spec.md
│   ├── plan.md
│   └── tasks.md
└── 003-local-config-overrides/
    ├── spec.md
    ├── plan.md
    └── tasks.md
```

## Test Structure

**Suite Organization:**
- No formal test suites; testing is spec-driven
- Each feature branch (e.g., `001-mise-node-module`) represents a complete testable unit
- Feature prerequisites checked via `.specify/scripts/bash/check-prerequisites.sh`
- Features validated through plan completion and task fulfillment

**Patterns:**
- Pre-execution validation: `.specify/scripts/bash/check-prerequisites.sh` validates feature branch structure
- Plan template-based validation: Features must have `plan.md` before implementation
- Tasks-based validation: Implementation phase requires `tasks.md`
- Manual verification: Scripts run to completion or exit with clear error messages

**Example Validation Pattern:**
```bash
# From check-prerequisites.sh
if [[ ! -d "$FEATURE_DIR" ]]; then
    echo "ERROR: Feature directory not found: $FEATURE_DIR" >&2
    exit 1
fi

if [[ ! -f "$IMPL_PLAN" ]]; then
    echo "ERROR: plan.md not found in $FEATURE_DIR" >&2
    exit 1
fi

# Check for optional documents
check_file "$RESEARCH" "research.md"
check_file "$DATA_MODEL" "data-model.md"
check_dir "$CONTRACTS_DIR" "contracts/"
```

## Mocking

**Framework:**
- Not detected; shell scripts use actual system calls
- Git commands used directly without mocking
- File system operations performed on real files

**Patterns:**
- Optional command execution with error suppression: `git fetch --all 2>/dev/null || true`
- Conditional logic based on command availability: `if hash vim 2>/dev/null; then ...`
- Temporary files for intermediate processing: `temp_file=$(mktemp); ... mv "$temp_file" "$target"`

**What to Mock:**
- Not applicable; testing is spec-driven, not unit-test driven
- Real file system used for integration
- Git repository state used directly

**What NOT to Mock:**
- All actual operations are real (no mocking pattern established)

## Fixtures and Factories

**Test Data:**
- Feature templates stored in `.specify/templates/`
- Template files: `spec-template.md`, `plan-template.md`, `agent-file-template.md`
- Templates substituted during feature creation with actual values
- No factory functions; direct template copying used

**Location:**
- `.specify/templates/` directory contains template files
- Templates have placeholder patterns like `[PROJECT NAME]`, `[DATE]`, `[EXTRACTED FROM ALL PLAN.MD FILES]`
- Agent context generation substitutes templates:
```bash
sed -i.bak -e "s|\[PROJECT NAME\]|$project_name|" "$temp_file"
sed -i.bak -e "s|\[DATE\]|$current_date|" "$temp_file"
```

## Coverage

**Requirements:**
- Not enforced; no coverage tracking detected
- Spec-driven workflow ensures features are documented
- Manual testing via spec completion

**View Coverage:**
- Not applicable; run scripts manually and verify outputs
- Check prerequisite files exist and are readable
- Verify agent context files updated correctly after features

## Test Types

**Unit Tests:**
- Not used; focus is on integration testing via feature workflow
- Individual script functions tested through shell execution
- Scripts can be sourced for function testing if needed

**Integration Tests:**
- Entire feature workflow tested: spec creation → plan generation → implementation → task completion
- Git branch creation and management tested (`create-new-feature.sh`)
- Agent context file updates tested (`update-agent-context.sh`)
- Prerequisites validation tested (`check-prerequisites.sh`)

**E2E Tests:**
- Not used; workflow is fundamentally end-to-end
- Each feature represents an E2E test case from creation through completion

## Common Patterns

**Async Testing:**
- Not applicable; shell scripts are synchronous
- Long-running operations (e.g., `git fetch --all`) allowed to complete or timeout

**Error Testing:**
- Explicit error paths tested through shell script execution
- Exit codes verified: functions return 0 on success, non-zero on failure
- Error messages written to stderr: `echo "ERROR: message" >&2`
- Pattern example from `update-agent-context.sh`:
```bash
validate_environment() {
    if [[ -z "$CURRENT_BRANCH" ]]; then
        log_error "Unable to determine current feature"
        exit 1
    fi

    if [[ ! -f "$NEW_PLAN" ]]; then
        log_error "No plan.md found at $NEW_PLAN"
        exit 1
    fi
}
```

**JSON Output Validation:**
- Scripts support `--json` output mode for machine parsing
- Validates JSON output by parsing in subsequent scripts
- Example from `check-prerequisites.sh`:
```bash
if $JSON_MODE; then
    printf '{"FEATURE_DIR":"%s","AVAILABLE_DOCS":%s}\n' "$FEATURE_DIR" "$json_docs"
fi
```

## Linting Standards

**shellcheck Usage:**
- Tool: `shellcheck` via Homebrew (configured in `dev-tools` module)
- Common disables documented inline:
  - `# shellcheck disable=SC2139` - Used where alias expansion timing is intentional
  - `# shellcheck source=$HOME/.env` - Source hints for file inclusion
- Scripts follow SC2 rules for portability and correctness

## Manual Testing Checklist

When adding new shell scripts, verify:
1. Script exits with code 0 on success, non-zero on error
2. Error messages clearly describe what failed and how to fix it
3. All output to stderr uses `>&2` redirection
4. Shell options (`set -e`, `set -u`, `set -o pipefail`) appropriate for context
5. All variables quoted to prevent word-splitting
6. Temporary files cleaned up via trap handlers
7. Functions return appropriate exit codes
8. JSON output (if applicable) is valid JSON
9. Scripts are portable (use `/usr/bin/env bash` not `/bin/bash`)

---

*Testing analysis: 2026-01-23*
