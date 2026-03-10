# Phase 4: Zsh conf.d Migration - Research

**Researched:** 2026-03-10
**Domain:** Zsh shell configuration, GNU Stow symlink management, conf.d pattern
**Confidence:** HIGH

## Summary

Phase 4 replaces the Ansible-merged zsh configuration files (`.zsh/environment.sh`, `.zsh/aliases.sh`, and the direct-sourced `functions.sh`/`utility.zsh`) with a runtime conf.d pattern. Four modules currently contribute zsh configuration: `zsh`, `editor`, `shell`, and `dev-tools`. Each will stow a single numbered fragment file into `~/.zsh/conf.d/`, and `.zshrc` becomes a ~15-line skeleton with a glob loop in the middle.

The existing infrastructure supports this well. The ansible-role-dotmodules already uses `stow --no-folding`, which creates real directories (not directory symlinks) in the target tree. This means multiple modules can stow files into the same `~/.zsh/conf.d/` directory without conflict. The `.zshrc` rewrite is straightforward since the current file already has a clear structure with fixed-order plugin loading at the top and bottom.

**Primary recommendation:** Create conf.d fragment files in each module's `files/.zsh/conf.d/` directory, rewrite `.zshrc` to a skeleton with glob loop, and remove the old merged file sources. The `--no-folding` flag in stow_module.yml already handles the multi-module-into-one-directory case.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- One conf.d file per module (not split by concern like aliases vs env)
- No shebang line; attribution comment header + shellcheck directive at top
- Naming convention: `{NN}-{module}-{brief-description}.sh`
- All content from merged files plus functions.sh and utility.zsh moves to conf.d
- .zshrc becomes skeleton: p10k instant prompt, conf.d glob loop with DOTFILES_DEBUG, .zshrc.local source, compinit, zsh-autosuggestions, powerlevel10k + p10k, zsh-syntax-highlighting
- `.zshrc.local` stays as direct source in .zshrc (not in conf.d), positioned after conf.d loop but before compinit
- `.env` loading stays inside zsh module's conf.d fragment
- `functions.sh` and `utility.zsh` content moves into conf.d for full consistency

### Claude's Discretion
- Numeric prefix assignment scheme (tens-based, grouped ranges, etc.)
- Exact prefix numbers for each module
- DOTFILES_DEBUG implementation (per-file output in loop vs summary after loop)
- How to handle the transition from merged files to conf.d files during migration

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SHRC-01 | Zsh sources all files in `~/.zsh/conf.d/*.sh` via glob loop with `(N)` qualifier | Glob loop pattern documented below; `(N)` nullglob prevents error on empty dir |
| SHRC-03 | All conf.d directories use numeric prefix ordering convention (00-99, 2-digit) | Prefix scheme recommendation in Architecture Patterns section |
| SHRC-04 | Zsh sourcing loop supports debug mode via `DOTFILES_DEBUG=1` environment variable | Debug implementation pattern documented in Code Examples |
| MIGR-02 | Each module stows its own numbered conf.d fragment files (no shared merge targets) | Stow `--no-folding` already in use; fragment file layout documented |
| MIGR-03 | Each conf.d fragment file has attribution comment header identifying owning module | Header format locked in CONTEXT.md decisions |
| MIGR-04 | EDITOR/VISUAL environment variables owned exclusively by editor module (no duplication) | Duplication analysis in Common Pitfalls; current state documented |
</phase_requirements>

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| GNU Stow | 2.4.1 | Symlink farm manager | Already in use; `--no-folding` enables multi-module conf.d |
| Zsh | Homebrew-managed | Shell | Target shell for conf.d migration |
| ansible-role-dotmodules | HEAD | Deployment automation | Already handles stow invocation with `--no-folding` |

### Supporting
| Tool | Purpose | When to Use |
|------|---------|-------------|
| shellcheck | Static analysis of fragments | Validate fragment files with `# shellcheck shell=zsh` directive |

### Alternatives Considered
None. This phase operates within the existing toolchain.

## Architecture Patterns

### Current State (to be replaced)
```
modules/zsh/files/.zsh/
  environment.sh  (84 lines - merged from zsh+editor+shell modules)
  aliases.sh      (43 lines - merged from zsh+editor modules)
  functions.sh    (63 lines - sourced directly)
  utility.zsh     (39 lines - sourced directly)

modules/editor/files/.zsh/
  environment.sh  (11 lines - merged into zsh environment.sh)
  aliases.sh      (1 line - merged into zsh aliases.sh)

modules/shell/files/.zsh/
  environment.sh  (4 lines - merged into zsh environment.sh)

modules/dev-tools/files/.zshrc  (2 lines - merged into .zshrc)
```

### Target State (conf.d pattern)
```
modules/zsh/files/
  .zshrc                               # Skeleton (owned solely by zsh module)
  .zsh/conf.d/10-zsh-core.sh           # All zsh module content combined

modules/editor/files/
  .zsh/conf.d/50-editor-env-aliases.sh  # EDITOR/VISUAL + e alias

modules/shell/files/
  .zsh/conf.d/50-shell-eza-colors.sh    # EZA_COLORS export

modules/dev-tools/files/
  .zsh/conf.d/80-dev-tools-mise.sh      # mise activate
```

### Recommended Prefix Scheme

Tens-based grouping with room to insert:

| Range | Purpose | Assigned |
|-------|---------|----------|
| 00-09 | Reserved (future core/bootstrap) | -- |
| 10-19 | Core shell (zsh module) | 10-zsh-core.sh |
| 20-39 | Unassigned (future modules) | -- |
| 40-59 | Application config (editor, shell) | 50-editor-env-aliases.sh, 50-shell-eza-colors.sh |
| 60-79 | Unassigned | -- |
| 80-89 | Dev tooling (dev-tools) | 80-dev-tools-mise.sh |
| 90-99 | Reserved (future late-loading) | -- |

Rationale: The zsh module's core content (environment vars, platform detection, CDPATH, aliases, functions, utility config) should load first since other modules may depend on it (e.g., editor's `e` alias uses `$VISUAL`). Dev-tools loads late because `mise activate` benefits from having the environment fully set up. Application modules in the middle have no ordering dependency on each other, so they share prefix 50.

### .zshrc Skeleton Pattern

The rewritten `.zshrc` keeps fixed-order plugin loading and inserts the conf.d loop:

```zsh
# p10k instant prompt (MUST be near top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source conf.d fragments (numeric order)
for conf in "$HOME/.zsh/conf.d/"*.sh(N); do
  [[ ${DOTFILES_DEBUG:-0} == 1 ]] && echo "sourcing: $conf"
  source "$conf"
done

# Local overrides (machine-specific, not a module)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Completion
autoload -Uz compinit && compinit

# Fish-like features (after compinit)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Prompt
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Syntax highlighting (MUST be last)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

### Anti-Patterns to Avoid
- **Splitting a module across multiple conf.d files:** One file per module is the locked decision. The aliases/environment split was an artifact.
- **Putting .zshrc.local in conf.d:** It's a machine-specific escape hatch, not a module contribution. Stays as direct source.
- **Sourcing conf.d files with `source` individually:** Use the glob loop, not individual source lines.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Multi-module same-directory stowing | Custom symlink scripts | GNU Stow with `--no-folding` | Already working in ansible-role-dotmodules; handles conflicts, unstow, restow |
| Ordering guarantee | Custom dependency resolution | 2-digit numeric prefixes + `(N)` glob | Zsh glob expansion is lexicographic; numeric prefixes give deterministic order |
| Null glob safety | Error handling around empty dirs | Zsh `(N)` qualifier | Built-in zsh feature; returns empty list instead of literal glob pattern |

## Common Pitfalls

### Pitfall 1: EDITOR/VISUAL Duplication
**What goes wrong:** Both `modules/zsh/files/.zsh/environment.sh` (lines 36-45) and `modules/editor/files/.zsh/environment.sh` (lines 1-11) currently define EDITOR and VISUAL. After migration, if the zsh module's conf.d fragment still contains these exports, they'll be set twice.
**Why it happens:** The merge system combined them into one file, masking the duplication. With conf.d, both fragments run independently.
**How to avoid:** Remove EDITOR/VISUAL exports from the zsh module's conf.d fragment. MIGR-04 requires the editor module to exclusively own these variables.
**Warning signs:** `grep -r "export EDITOR\|export VISUAL" ~/.zsh/conf.d/` returns more than one file.

### Pitfall 2: editor `e` Alias Duplication
**What goes wrong:** Both `modules/zsh/files/.zsh/aliases.sh` (line 19) and `modules/editor/files/.zsh/aliases.sh` (line 1) define the `e` alias identically. With conf.d, it would be defined twice.
**How to avoid:** Remove the `e` alias from the zsh module's conf.d fragment. It belongs with the editor module since it depends on EDITOR/VISUAL.

### Pitfall 3: Stow Conflict on .zshrc
**What goes wrong:** Currently both `modules/zsh/files/.zshrc` and `modules/dev-tools/files/.zshrc` exist as mergeable files targeting the same `.zshrc`. After migration, `.zshrc` is solely owned by the zsh module (dev-tools content moves to conf.d). But if `dev-tools` still has a `.zshrc` file, stow will conflict.
**How to avoid:** Delete `modules/dev-tools/files/.zshrc` and remove `.zshrc` from dev-tools `mergeable_files`. The `eval "$(mise activate zsh)"` line moves to `modules/dev-tools/files/.zsh/conf.d/80-dev-tools-mise.sh`.

### Pitfall 4: Old Merged File Symlinks Left Behind
**What goes wrong:** After migration, `~/.zsh/environment.sh` and `~/.zsh/aliases.sh` still exist as symlinks pointing to `~/.dotmodules/merged/`. If .zshrc no longer sources them, they're harmless but confusing.
**How to avoid:** The new .zshrc skeleton does not source these files, so they won't cause errors. Full cleanup of merged directory happens in Phase 7. However, the old `functions.sh` and `utility.zsh` symlinks (non-merged, direct stow) need consideration. After migration, the zsh module no longer has those files in `files/.zsh/` (their content is in the conf.d fragment), so stow should be re-run to clean up stale symlinks.

### Pitfall 5: Missing conf.d Directory on Fresh Install
**What goes wrong:** On a brand-new machine, if no module has been stowed yet, `~/.zsh/conf.d/` does not exist. The glob `"$HOME/.zsh/conf.d/"*.sh(N)` with `(N)` returns empty (no error), so it's safe. But if the directory doesn't exist at all, there's no visible error, just no config loaded.
**How to avoid:** The `(N)` qualifier handles this correctly in zsh. No files matched means no sourcing, no error. This is expected on a fresh machine before first deploy.

### Pitfall 6: Fragment Uses Zsh-Specific Syntax but Has .sh Extension
**What goes wrong:** Some content (utility.zsh) uses zsh-specific features like `setopt`, `zle`, `bindkey`. Having a `.sh` extension is misleading.
**How to avoid:** The `.sh` extension is needed for the glob pattern `*.sh(N)` to match. The `# shellcheck shell=zsh` directive in the header handles the linting side. The `.sh` extension is a convention for "shell fragment to be sourced," not a claim of POSIX compatibility. This is fine and common in dotfile repos.

## Code Examples

### Conf.d Glob Loop with Debug Support
```zsh
# Recommended implementation (per-file output, inline with sourcing)
for conf in "$HOME/.zsh/conf.d/"*.sh(N); do
  [[ ${DOTFILES_DEBUG:-0} == 1 ]] && echo "sourcing: $conf"
  source "$conf"
done
```

The `(N)` is a zsh glob qualifier meaning "null glob" -- if no files match, the pattern expands to nothing (empty list) instead of causing an error or being treated as a literal string. This is equivalent to bash's `shopt -s nullglob` but scoped to a single expansion.

### Fragment File Template
```sh
# shellcheck shell=zsh
# {module} module - {brief description of what this fragment provides}

# ... module configuration content ...
```

### Example: editor Module Fragment (50-editor-env-aliases.sh)
```sh
# shellcheck shell=zsh
# editor module - EDITOR/VISUAL exports and editor aliases

# use vim if possible, otherwise vi
if hash vim 2>/dev/null; then
  export EDITOR=vim
else
  export EDITOR=vi
fi

# use Nova, if possible
if hash nova 2>/dev/null; then
  export VISUAL=nova
fi

alias e='${(z)VISUAL:-${(z)EDITOR}}'
```

### Example: dev-tools Module Fragment (80-dev-tools-mise.sh)
```sh
# shellcheck shell=zsh
# dev-tools module - mise-en-place runtime manager activation

eval "$(mise activate zsh)"
```

### Stow Directory Layout for conf.d
```
# Each module creates this structure in its files/ directory:
modules/editor/files/.zsh/conf.d/50-editor-env-aliases.sh

# After stow --no-folding, this becomes:
~/.zsh/conf.d/50-editor-env-aliases.sh -> ../../dotfiles/modules/editor/files/.zsh/conf.d/50-editor-env-aliases.sh
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Ansible merge + Jinja2 template | Runtime conf.d sourcing | This phase | Config edits live on git pull |
| Split aliases.sh/environment.sh per module | Single fragment per module | This phase | Simpler, one file to find per module |
| Direct source lines for functions.sh/utility.zsh | Everything through conf.d glob | This phase | Consistent loading mechanism |

## Open Questions

1. **Old file cleanup during this phase vs Phase 7**
   - What we know: Phase 7 handles `mergeable_files` removal from config.yml and merge logic cleanup. This phase creates the new conf.d files and rewrites .zshrc.
   - What's unclear: Should the old `aliases.sh`, `environment.sh`, `functions.sh`, `utility.zsh` files in `modules/zsh/files/.zsh/` be removed in this phase or Phase 7?
   - Recommendation: Remove them in this phase. They are replaced by the single `10-zsh-core.sh` conf.d fragment. Leaving them creates confusion. The `mergeable_files` config.yml entries can remain until Phase 7 since the merge system is harmless when the source files no longer exist. However, `functions.sh` and `utility.zsh` are NOT mergeable files (they're directly stowed), so they should definitely be removed in this phase to avoid stale symlinks.

2. **dev-tools .zshrc file removal timing**
   - What we know: `modules/dev-tools/files/.zshrc` has 2 lines (`eval "$(mise activate zsh)"`). This moves to conf.d.
   - What's unclear: Can we delete it in this phase without breaking the merge system for `.zshrc`?
   - Recommendation: Yes, delete it. The `.zshrc` merge currently combines zsh module's .zshrc + dev-tools .zshrc. After this phase, .zshrc is solely owned by zsh module (no merge needed). Even if the merge system runs, it will just produce the zsh module's .zshrc unchanged.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual shell testing (no automated test framework in project) |
| Config file | none |
| Quick run command | `zsh -l -c 'echo ok'` (login shell smoke test) |
| Full suite command | `DOTFILES_DEBUG=1 zsh -l -c 'echo ok'` (verify all fragments load) |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SHRC-01 | Zsh sources conf.d/*.sh via glob loop | smoke | `zsh -l -c 'echo ok'` | N/A (shell behavior) |
| SHRC-03 | Numeric prefix ordering convention | manual | `ls ~/.zsh/conf.d/` (visual check) | N/A |
| SHRC-04 | DOTFILES_DEBUG=1 prints sourced files | smoke | `DOTFILES_DEBUG=1 zsh -l -c '' 2>&1 \| grep sourcing` | N/A |
| MIGR-02 | Each module stows own conf.d fragment | manual | `ls -la ~/.zsh/conf.d/` (verify symlinks point to different modules) | N/A |
| MIGR-03 | Attribution comment headers present | manual | `head -2 ~/.zsh/conf.d/*.sh` | N/A |
| MIGR-04 | EDITOR/VISUAL only in editor module | manual | `grep -l 'export EDITOR\|export VISUAL' ~/.zsh/conf.d/` (should return only editor fragment) | N/A |

### Sampling Rate
- **Per task commit:** `zsh -l -c 'echo ok'` (verify shell still opens)
- **Per wave merge:** `DOTFILES_DEBUG=1 zsh -l -c '' 2>&1` + manual verification of all criteria
- **Phase gate:** Full manual verification of all 5 success criteria before `/gsd:verify-work`

### Wave 0 Gaps
None. This phase uses manual shell testing against a live zsh session. No test framework to install.

## Sources

### Primary (HIGH confidence)
- Direct codebase inspection of all 4 contributing modules (zsh, editor, shell, dev-tools)
- `ansible-role-dotmodules/tasks/stow_module.yml` -- confirmed `--no-folding` flag usage
- GNU Stow 2.4.1 man page -- confirmed `--no-folding` creates real directories for multi-package stowing
- Current `.zshrc` (35 lines) -- mapped exact plugin loading order

### Secondary (MEDIUM confidence)
- Zsh `(N)` glob qualifier behavior (well-documented zsh feature, verified against existing project use of zsh)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - entire stack is already in use in the project
- Architecture: HIGH - direct inspection of all source files and stow behavior
- Pitfalls: HIGH - identified by comparing current merged state with target conf.d state
- Prefix scheme: MEDIUM - Claude's discretion area, recommendation based on dependency analysis

**Research date:** 2026-03-10
**Valid until:** 2026-04-10 (stable domain, no external dependency changes expected)
