---
phase: quick-1
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - modules/zsh/files/.zsh/functions.sh
autonomous: true
requirements:
  - QUICK-1
must_haves:
  truths:
    - "Running `llama-serve` starts qwen3-8b on port 8080 (default)"
    - "Running `llama-serve qwen3-8b` also starts qwen3-8b on port 8080"
    - "Running `llama-serve unknown-model` prints an error and lists available models"
  artifacts:
    - path: "modules/zsh/files/.zsh/functions.sh"
      provides: "llama-serve function"
      contains: "llama-serve"
  key_links:
    - from: "llama-serve function"
      to: "llama-server binary"
      via: "case statement mapping model name to file path and flags"
      pattern: "llama-server -m.*--port 8080"
---

<objective>
Add a `llama-serve` shell function to the zsh functions file that starts a local LLM server using llama-server.

Purpose: Provide a convenient shorthand for starting local LLM inference with named model aliases instead of remembering full file paths and flags.
Output: Updated modules/zsh/files/.zsh/functions.sh with the llama-serve function appended.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@modules/zsh/files/.zsh/functions.sh
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add llama-serve function to functions.sh</name>
  <files>modules/zsh/files/.zsh/functions.sh</files>
  <action>
Append the following function to the end of modules/zsh/files/.zsh/functions.sh:

```sh
## Start a local LLM server via llama-server
## Usage: llama-serve [model-name]
## Defaults to qwen3-8b if no model name is provided
llama-serve () {
  local model="${1:-qwen3-8b}"
  local file flags

  case "$model" in
    qwen3-8b)
      file="$HOME/models/Qwen_Qwen3-8B-Q4_K_M.gguf"
      flags="--port 8080 -ngl 99 --reasoning-budget 0 --reasoning-format none -c 8192"
      ;;
    *)
      echo "Unknown model: $model"
      echo "Available models:"
      echo "  qwen3-8b"
      return 1
      ;;
  esac

  llama-server -m "$file" $flags
}
```

The case statement is the extension point for future models. When adding a new model, add a new `name)` block before the `*)` wildcard with its `file` and `flags` values. The error message lists all valid model names from the case arms (manually kept in sync).
  </action>
  <verify>grep -n "llama-serve" /Users/mcravey/dotfiles/modules/zsh/files/.zsh/functions.sh</verify>
  <done>The function exists in functions.sh, contains a case statement with qwen3-8b, defaults to qwen3-8b when no argument is passed, and prints an error with the available model list for unknown model names.</done>
</task>

</tasks>

<verification>
Source the file and run basic smoke tests:

```sh
source modules/zsh/files/.zsh/functions.sh

# Verify unknown model prints error and lists models
llama-serve bad-model-name
# Expected: prints "Unknown model: bad-model-name", lists "qwen3-8b", exits non-zero

# Verify default resolves to qwen3-8b (dry-run via type inspection)
type llama-serve
```

No actual server start needed for verification - the case statement logic is the only testable part without the binary present.
</verification>

<success_criteria>
- `llama-serve` function is present in modules/zsh/files/.zsh/functions.sh
- Calling with no args defaults to qwen3-8b model and its full flags
- Calling with `qwen3-8b` explicitly also works
- Calling with an unknown model name prints a human-readable error listing available models and returns exit code 1
- The file remains valid POSIX sh (shebang is `#!/usr/bin/env sh`)
</success_criteria>

<output>
After completion, create `.planning/quick/1-add-llama-serve-shell-function-for-runni/quick-1-01-SUMMARY.md`
</output>
