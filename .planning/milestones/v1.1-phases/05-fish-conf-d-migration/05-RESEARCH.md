# Phase 5: Fish conf.d Migration - Research

**Researched:** 2026-03-10
**Domain:** Fish shell configuration, native conf.d mechanism, GNU Stow symlink management
**Confidence:** HIGH

## Summary

Phase 5 migrates four modules' fish configuration from Ansible-merged `config.fish` files to fish's native `~/.config/fish/conf.d/` mechanism. Fish automatically sources all `.fish` files in `conf.d/` before `config.fish`, sorted alphabetically with natural number ordering (case-insensitive). This means no glob loop is needed in `config.fish`, unlike zsh. The `config.fish` file becomes a minimal skeleton containing only the `config.local.fish` source line.

Four modules currently contribute to the merged config.fish: `fish` (env vars, abbrs, mux function, tide prompt config), `editor` (ia/marked abbrs), `shell` (EZA_COLORS env var), and `dev-tools` (mise activate). Each module will get one conf.d fragment file following the `NN-module-desc.fish` naming convention from Phase 4. Fisher/Tide manages its own conf.d files with underscore-prefixed names (`_tide_init.fish`), so there is zero collision risk.

The inline `mux` function moves to its own `functions/mux.fish` file, following fish's native autoload convention where each function lives in its own file under `~/.config/fish/functions/`. All existing function files stay as-is.

**Primary recommendation:** Create conf.d fragment files in each module's `files/.config/fish/conf.d/` directory, move the `mux` function to `functions/mux.fish`, reduce `config.fish` to a config.local.fish source line, and add attribution headers to function files.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- config.fish becomes minimal: only the config.local.fish source line (machine-specific escape hatch)
- All module content moves to conf.d fragments
- config.local.fish stays in config.fish, not in conf.d
- Claude decides what else, if anything, needs to stay in config.fish
- Split by need: env vars get no guard, abbrs/prompt/functions get `if status --is-interactive` guard
- Each fragment is responsible for its own guards where needed (no global guard in config.fish)
- Module fragments use `NN-module-desc.fish` prefix convention; Fisher uses underscored/plugin names (no collision risk)
- Fisher stays completely independent; fish_plugins manifest stays stowed as-is
- Existing function files in functions/ stay as-is
- Inline mux function from config.fish moves to its own functions/mux.fish file
- Any module can contribute function files to ~/.config/fish/functions/
- All function files get attribution comment headers identifying owning module
- One conf.d fragment per module (4 fragments total)
- Fish module fragment: env vars, abbrs, tide prompt config
- Editor module fragment: ia and marked abbrs
- Shell module fragment: EZA_COLORS env var
- Dev-tools module fragment: mise activate for fish
- Tide prompt config moves to the fish conf.d fragment

### Claude's Discretion
- Exact numeric prefix assignments for each module's fragment
- What minimal content (if any) stays in config.fish beyond config.local.fish source
- Mise activate guard: research what mise recommends for fish (login vs interactive vs no guard)
- Fragment file naming details (brief description suffix)

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SHRC-02 | Fish sources module contributions via native `~/.config/fish/conf.d/*.fish` mechanism | Fish auto-sources conf.d/*.fish before config.fish; no loop needed. Stow --no-folding allows multi-module contributions to same directory. |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| fish | 4.x (4.5.0 current) | Shell | Already installed via fish module homebrew_packages |
| GNU Stow | installed | Symlink manager | Already used by all modules; --no-folding ensures directory creation |
| Fisher | installed | Fish plugin manager | Already manages tide; owns _-prefixed conf.d files |
| Tide v6 | installed | Prompt framework | Already configured via fish_plugins manifest |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| mise | installed | Runtime version manager | Dev-tools module activates it in fish |

### Alternatives Considered
None. All tooling is already established by the project.

## Architecture Patterns

### Recommended Project Structure

```
modules/fish/files/.config/fish/
  config.fish              # Minimal skeleton (config.local.fish source only)
  conf.d/
    10-fish-core.fish      # Env vars, abbrs, tide prompt config
  functions/
    mux.fish               # Extracted from config.fish (NEW)
    digg.fish              # Existing (stays)
    headers.fish           # Existing (stays)
    ... (10 existing + 1 new)

modules/editor/files/.config/fish/conf.d/
    50-editor-abbrs.fish   # ia and marked abbrs

modules/shell/files/.config/fish/conf.d/
    50-shell-eza-colors.fish  # EZA_COLORS env var

modules/dev-tools/files/.config/fish/conf.d/
    80-dev-tools-mise.fish    # mise activate fish
```

### Pattern 1: Fish conf.d Fragment Structure

**What:** Each module's fragment is a self-contained `.fish` file with attribution header and appropriate interactive guards.

**When to use:** Every conf.d fragment in this phase.

**Example:**
```fish
# fish module - core environment, abbreviations, and prompt configuration

# --- Environment (no guard needed - available in all sessions) ---
set -gx DOTFILES "$HOME/dotfiles"
set -gx XDG_CONFIG_HOME "$HOME/.config"

if status --is-interactive
    # --- Abbreviations ---
    abbr dot "cd $DOTFILES"
    # ...

    # --- Prompt ---
    set -g tide_left_prompt_items pwd git cmd_duration newline status character
    set -g tide_right_prompt_items node python rustc java php ruby go terraform
end
```

### Pattern 2: Fish Function File with Attribution Header

**What:** Each function file gets a comment header identifying the owning module.

**When to use:** The new `mux.fish` file and optionally existing function files.

**Example:**
```fish
# fish module - create or attach to a named tmux session
function mux
    set -l session (test (count $argv) -gt 0; and echo $argv[1]; or echo "main")
    tmux new-session -A -s $session
end
```

### Pattern 3: Numeric Prefix Convention

**What:** Consistent with Phase 4 zsh scheme. Fragments numbered by tier.

**Recommendation:**
| Prefix | Module | Rationale |
|--------|--------|-----------|
| 10 | fish | Core module, loads first (env vars, PATH, abbrs, prompt) |
| 50 | editor | Application module, middle tier |
| 50 | shell | Utility module, middle tier |
| 80 | dev-tools | Late loader (mise needs PATH established first) |

This matches the zsh Phase 4 scheme exactly: `10-zsh-core`, `50-editor-*`, `50-shell-*`, `80-dev-tools-*`.

### Pattern 4: Minimal config.fish Skeleton

**What:** config.fish reduced to only what cannot live in conf.d.

**Recommendation:** Only the config.local.fish source line needs to stay. Since conf.d loads before config.fish, putting config.local.fish sourcing in config.fish means local overrides run last, which is correct behavior (overrides take effect after all module fragments).

```fish
# Local configuration (machine-specific overrides)
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
```

Nothing else needs to stay in config.fish. The brew shellenv, fish_add_path, env vars, abbrs, and tide config all work correctly from conf.d.

### Anti-Patterns to Avoid
- **Wrapping entire fragments in `if status --is-interactive`:** Split env vars (no guard) from interactive features (guarded). Env vars should be available in non-interactive fish scripts too.
- **Using `set -U` (universal variables):** Fish 4.x deprecated universal variables. Use `set -gx` for exports, `set -g` for globals. Tide prompt config uses `set -g` correctly.
- **Creating conf.d subdirectories:** Fish only sources files directly in `conf.d/`, not in subdirectories.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| conf.d sourcing loop | Custom sourcing in config.fish | Fish native auto-sourcing | Fish handles conf.d natively, unlike zsh which needs a glob loop |
| Function autoloading | Source functions from conf.d | `functions/` directory | Fish autoloads one-function-per-file from functions/ on first call |
| Plugin management | Manual plugin sourcing in conf.d | Fisher + fish_plugins manifest | Fisher already manages tide and owns its own conf.d files |

**Key insight:** Fish's native conf.d is simpler than zsh's. There is no loop to write, no `(N)` qualifier to remember. Just put `.fish` files in the directory.

## Common Pitfalls

### Pitfall 1: Brew shellenv in conf.d Ordering
**What goes wrong:** If `eval "$(/opt/homebrew/bin/brew shellenv)"` runs in a fragment that loads after another fragment needs brew-installed tools.
**Why it happens:** conf.d loads alphabetically, so `50-shell-*` would load before a hypothetical `60-fish-brew.fish`.
**How to avoid:** Keep brew shellenv in the `10-fish-core.fish` fragment (lowest prefix), ensuring PATH is set before any other fragment runs.
**Warning signs:** Commands like `mise`, `eza` not found in fish shell.

### Pitfall 2: fish_add_path Idempotency
**What goes wrong:** Worrying about duplicate PATH entries on shell restart.
**Why it happens:** Unfamiliarity with fish's `fish_add_path` behavior.
**How to avoid:** `fish_add_path` is already idempotent. It checks before adding and does not create duplicates. Safe to call in conf.d on every shell startup.
**Warning signs:** None, this is a non-issue in fish.

### Pitfall 3: Abbr Definitions in Non-Interactive Shells
**What goes wrong:** `abbr` commands emit warnings or errors in non-interactive sessions.
**Why it happens:** Abbreviations are an interactive-only feature in fish.
**How to avoid:** Wrap `abbr` calls in `if status --is-interactive` blocks. This is already decided in CONTEXT.md.
**Warning signs:** Error messages when running fish scripts or non-interactive commands.

### Pitfall 4: Stale Merged config.fish Symlink
**What goes wrong:** After creating conf.d fragments, the old merged `~/.dotmodules/merged/.config/fish/config.fish` symlink still exists and the old monolith content still loads.
**Why it happens:** Ansible merge logic still active until Phase 7 cleanup.
**How to avoid:** The new config.fish (minimal skeleton) replaces the old monolith. Since stow deploys it and the merge target is the same file, the new content overwrites the old. The mergeable_files entries in config.yml stay until Phase 7 but the fish module's config.fish now has minimal content.
**Warning signs:** Duplicate env vars, duplicate abbrs in fish session.

### Pitfall 5: Mise Activate Guard
**What goes wrong:** Using `--shims` flag when `mise activate` is preferred for interactive shells.
**Why it happens:** Current dev-tools config.fish uses `status --is-login` with `--shims`, which is the non-interactive approach.
**How to avoid:** Use `mise activate fish | source` for interactive sessions (supports hooks, watch_files, full feature set). The `--shims` approach loses features like env var loading on cd.
**Recommendation:** Use `if status --is-interactive` guard with `mise activate fish | source` (no `--shims` flag). This matches mise's official recommendation and provides the full feature set.

## Code Examples

### Fish conf.d Fragment: fish module (10-fish-core.fish)
```fish
# fish module - core environment, abbreviations, and prompt configuration

# --- Environment ---
set -gx DOTFILES "$HOME/dotfiles"
set -gx XDG_CONFIG_HOME "$HOME/.config"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
fish_add_path ~/.local/bin
fish_add_path ~/.bin

set -gx CDPATH . ~ (test -e ~/Work; and echo ~/Work)
set -gx LS_COLORS 'rs=0:di=00;38;5;39:ex=00;32:ln=00;38;5;5:'

if status --is-interactive
    # --- Abbreviations ---
    abbr dot "cd $DOTFILES"
    abbr dotdot --regex '^\.\.+$' --function multicd
    abbr ip "dig +short myip.opendns.com @resolver1.opendns.com"
    abbr pubkey "cat ~/.ssh/*.pub | pbcopy; echo '=> Public key copied to clipboard.'"
    abbr mkdir "mkdir -p"
    abbr df "df -kh"
    abbr du "du -kh"

    # --- Prompt (Tide) ---
    set -g tide_left_prompt_items pwd git cmd_duration newline status character
    set -g tide_right_prompt_items node python rustc java php ruby go terraform
end
```

### Fish conf.d Fragment: editor module (50-editor-abbrs.fish)
```fish
# editor module - program launcher abbreviations

if status --is-interactive
    abbr -a ia 'open -a "iA Writer"'
    abbr -a marked 'open -a "Marked 2"'
end
```

### Fish conf.d Fragment: shell module (50-shell-eza-colors.fish)
```fish
# shell module - eza color configuration

# eza colors - remove bold from various elements
set -gx EZA_COLORS 'uu=33:un=33'
```

### Fish conf.d Fragment: dev-tools module (80-dev-tools-mise.fish)
```fish
# dev-tools module - mise runtime manager activation

if status --is-interactive
    mise activate fish | source
end
```

### Fish function file: mux.fish (extracted from config.fish)
```fish
# fish module - create or attach to a named tmux session
# Usage: mux [session-name]
# Defaults to "main" if no session name is provided
function mux
    set -l session (test (count $argv) -gt 0; and echo $argv[1]; or echo "main")
    tmux new-session -A -s $session
end
```

### Minimal config.fish
```fish
# Local configuration (machine-specific overrides)
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `set -U` universal variables | `set -gx`/`set -g` in config files | Fish 4.0 (Feb 2025) | Universal variables deprecated; config belongs in files |
| `abbr --universal` | `abbr` in config.fish or conf.d | Fish 4.0 (Feb 2025) | `--universal` flag warns; abbrs go in config files |
| `mise activate fish --shims` | `mise activate fish \| source` | mise docs current | Full activate preferred for interactive; shims for non-interactive/IDE |
| Monolith config.fish | conf.d fragments | Project Phase 5 | Edits go live on git pull |

## Open Questions

1. **Existing function file attribution headers**
   - What we know: CONTEXT.md says all function files get attribution headers
   - What's unclear: Whether to add headers to all 10+ existing function files in this phase or just the new mux.fish
   - Recommendation: Add headers to all function files for consistency, but this is a simple batch operation (not a separate plan)

2. **brew shellenv in non-interactive context**
   - What we know: The current config.fish wraps everything in `if status --is-interactive`, including brew shellenv
   - What's unclear: Whether brew shellenv should be outside the interactive guard (available to non-interactive fish scripts)
   - Recommendation: Move brew shellenv outside the interactive guard. Non-interactive fish scripts may need access to brew-installed tools via PATH. `fish_add_path` calls should also be unguarded.

## Sources

### Primary (HIGH confidence)
- [Fish 4.5.0 documentation](https://fishshell.com/docs/current/) - conf.d sourcing order, glob sorting, status --is-interactive
- [Fish release notes](https://fishshell.com/docs/current/relnotes.html) - Universal variable deprecation in 4.0+
- [mise activate docs](https://mise.jdx.dev/cli/activate.html) - Fish activation recommendations
- [mise shims docs](https://mise.jdx.dev/dev-tools/shims.html) - Shims vs activate tradeoffs

### Secondary (MEDIUM confidence)
- [Fish conf.d sourcing order issue #8553](https://github.com/fish-shell/fish-shell/issues/8553) - Sourcing order details (user conf.d before system)
- [Fish conf.d discussion #11083](https://github.com/fish-shell/fish-shell/discussions/11083) - conf.d vs config.fish relationship

### Tertiary (LOW confidence)
None. All findings verified with official documentation.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all tools already in use, versions verified
- Architecture: HIGH - follows established Phase 4 patterns, fish conf.d is well-documented native feature
- Pitfalls: HIGH - verified against official docs and current fish version behavior

**Research date:** 2026-03-10
**Valid until:** 2026-04-10 (stable domain, fish 4.x is mature)
