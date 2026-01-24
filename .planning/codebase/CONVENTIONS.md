# Coding Conventions

**Analysis Date:** 2026-01-23

## Naming Patterns

**Files:**
- Bash scripts: `.sh` extension (e.g., `common.sh`, `check-prerequisites.sh`)
- Shell sourced files: `.sh` extension (e.g., `.zsh/aliases.sh`, `.zsh/functions.sh`)
- Zsh-specific configs: `.zsh` extension (e.g., `.zshrc`, `utility.zsh`, `.p10k.zsh`)
- Configuration files: `.yml` or `.yaml` for Ansible configs, `.zshrc`, `.zshenv`, `.zlogin`, `.zprofile` for shell config
- Feature branches: `NNN-descriptive-name` format where NNN is zero-padded 3-digit number (e.g., `001-mise-node-module`, `003-local-config-overrides`)

**Functions:**
- Bash functions use `snake_case` (e.g., `get_repo_root()`, `check_feature_branch()`, `find_feature_dir_by_prefix()`)
- Zsh functions use `snake_case` (e.g., `rationalise-dot()` in utility.zsh)
- Functions with underscores preferred for multi-word names
- Descriptive names that indicate purpose (e.g., `log_error()`, `validate_environment()`, `parse_plan_data()`)

**Variables:**
- Global shell variables: `UPPER_CASE` (e.g., `REPO_ROOT`, `FEATURE_DIR`, `HAS_GIT`, `CURRENT_BRANCH`)
- Local shell variables: `lower_case` with underscores (e.g., `script_dir`, `repo_root`, `branch_name`)
- Environment variables for feature tracking: `SPECIFY_FEATURE`
- Temporary/internal variables prefixed with underscore in some contexts (e.g., `_AGENT_TYPE`)

**Types:**
- Bash/shell scripts: No type system; comments indicate expected types where needed
- Config values stored as strings in shell variables
- Arrays use `array_name=()` syntax and accessed with `${array_name[@]}`

## Code Style

**Formatting:**
- Shebang: `#!/usr/bin/env bash` (portable across systems)
- Shell shebang for POSIX: `#!/usr/bin/env sh` for compatibility files
- Zsh shebang: `#!/usr/bin/env zsh` for zsh-specific files
- Indentation: 4 spaces for Bash/shell scripts (see `check-prerequisites.sh`, `create-new-feature.sh`)
- Indentation: Tabs in some files (mixed convention, see `.prettierrc` uses tabs for JavaScript)
- Line length: Generally kept reasonable (80-char printWidth in formatting config)
- Line endings: Unix-style (LF)
- Shell scripts: Use `set -e` (exit on error) at top; advanced scripts use `set -u` and `set -o pipefail`

**Linting:**
- Bash scripts checked with `shellcheck` (see references in `.zsh/aliases.sh` with `# shellcheck disable=` comments)
- shellcheck installed via `dev-tools` module config
- Common shellcheck disables: `SC2139` (used in alias definitions where expansion at assignment time is intentional)
- JavaScript linted with ESLint (eslintrc.js exists in dev-tools)
- JavaScript formatted with Prettier (prettierrc config exists)

## Import Organization

**Order:**
1. Shebang line (`#!/usr/bin/env bash`)
2. Comments/header documentation
3. Set options (`set -e`, `set -u`, `set -o pipefail`)
4. Function definitions (utility functions first, then business logic)
5. Main execution code at end
6. `main` function typically called with `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`

**Path Aliases:**
- Not applicable for shell scripts; file paths always absolute or relative from well-known points
- Git repository root found via `git rev-parse --show-toplevel` or filesystem search
- Environment paths set in shell config files (e.g., `CDPATH` defined in `environment.sh`)

**Source Inclusion:**
- Use absolute paths for sourcing: `source "$SCRIPT_DIR/common.sh"`
- Use `eval $(get_feature_paths)` pattern to load multiple variables from function output
- Local overrides sourced at end: `[ -f ~/.zshrc.local ] && source ~/.zshrc.local`

## Error Handling

**Patterns:**
- Exit on error: Scripts use `set -e` to fail immediately on command failure
- Error output redirected to stderr: `echo "ERROR: message" >&2`
- Explicit error checking after conditional commands: `git fetch --all 2>/dev/null || true` for commands that may safely fail
- Trap EXIT/INT/TERM for cleanup:
  ```bash
  cleanup() {
    local exit_code=$?
    # cleanup code
    exit $exit_code
  }
  trap cleanup EXIT INT TERM
  ```
- Return codes checked explicitly: `if ! command; then handle_error; fi`
- Functions return 0 on success, non-zero on failure

**Error Reporting:**
- Structured error functions: `log_error()`, `log_warning()`, `log_info()`, `log_success()`
- Error messages include context: "ERROR: description" + "Explanation of how to fix"
- Validation functions return clear error messages before exiting

## Logging

**Framework:** No external logging framework; uses `echo` with stdio/stderr redirection

**Patterns:**
- INFO messages: `echo "INFO: $1"` to stdout
- ERROR messages: `echo "ERROR: $1" >&2` to stderr
- SUCCESS messages: `echo "✓ $1"` to stdout
- WARNING messages: `echo "WARNING: $1" >&2` to stderr
- JSON output mode for programmatic parsing: Returns JSON on `--json` flag
- Structured logging with prefixes like `[specify]` when appropriate

**Logging locations:**
- See `update-agent-context.sh` for comprehensive logging example
- Logging functions defined early in scripts
- Called throughout execution for debugging

## Comments

**When to Comment:**
- Complex regex patterns documented with intent
- Non-obvious branching logic explained
- Variable definitions with context: `# Global variables for parsed plan data`
- Section headers for major code blocks: `#==============================================================================`
- Logic that works around shell limitations documented
- Comments use `#` followed by space

**JSDoc/TSDoc:**
- Not used in shell scripts
- Function descriptions in header comments where needed
- Inline comments for complex sed/awk patterns

## Function Design

**Size:**
- Most functions 10-50 lines
- Longer functions (100+ lines) broken up or well-commented (see `update_existing_agent_file()` with section markers)
- Complex logic extracted to separate functions

**Parameters:**
- Positional parameters: `$1`, `$2` for explicit parameters
- Optional parameters handled via flags: `--json`, `--help`, `--require-tasks`
- Parameter validation at function start
- Named parameters simulated via flags: `--short-name <value>`, `--number <value>`

**Return Values:**
- Exit code 0 for success, non-zero for failure
- Functions that need output use `echo` to stdout
- Multiple values returned via array or space-separated: `eval $(function_that_echoes_vars)`
- Document what's returned in function header comments

## Module Design

**Exports:**
- Shell scripts don't export functions unless sourced
- `source "$SCRIPT_DIR/common.sh"` makes all functions available
- `eval $(get_feature_paths)` pattern exports variables to calling script
- JSON mode supports structured data export via printf

**Barrel Files:**
- Not applicable to shell scripts
- Config consolidation in module `config.yml` files
- Merged configs in `.dotmodules/merged/` directory pattern

## Shell-Specific Conventions

**Variable Scoping:**
- Global variables declared at top in UPPER_CASE
- Local variables in functions declared with `local` keyword: `local script_dir="..."`
- Temporary files created with `mktemp` and cleaned up

**Array Handling:**
- Declare with `array=()` syntax
- Access with `"${array[@]}"` to expand all elements
- Check length with `${#array[@]}`
- Append with `array+=("item")`

**String Handling:**
- Always quote variables: `"$variable"` to prevent word-splitting
- Use `[[ ]]` for test conditions (more robust than `[ ]`)
- Pattern matching: `[[ "$string" =~ pattern ]]`
- String replacement: `${variable//old/new}` for all occurrences

**Conditionals:**
- Use `[[ ]]` for bash conditionals (POSIX compatibility with `[ ]` where needed)
- Early exit pattern: `if ! condition; then error; exit 1; fi`
- Flag-based options parsed with `case` statement

**Pipes and Redirection:**
- Complex piping documented: `git branch -a 2>/dev/null || echo ""`
- Error suppression with `2>/dev/null` when command optionally fails
- Append with `>>` vs overwrite with `>`
- Process substitution with `<()` for commands needing file arguments

---

*Convention analysis: 2026-01-23*
