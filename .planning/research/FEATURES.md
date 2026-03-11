# Feature Landscape: Runtime conf.d Sourcing Migration

**Domain:** Dotfiles conf.d/runtime sourcing to replace Ansible-merged files
**Researched:** 2026-03-10
**Focus:** What features do well-designed conf.d systems have?

## Executive Summary

The conf.d pattern is well-established in Unix system administration (systemd, nginx, Apache, cron) and increasingly in shell configuration (fish's native conf.d, zsh community patterns like zdotdir/mattmc3, thoughtbot's dotfiles). The core idea is simple: instead of merging multiple module contributions into one monolithic file at deploy time, each module stows its own fragment into a conf.d directory, and the shell sources them all at runtime via a glob loop.

This project's migration has three domains with different native support levels:
- **Fish:** Native conf.d support built into the shell. Drop files in `~/.config/fish/conf.d/` and they load automatically. Zero custom code needed.
- **Zsh:** No native conf.d. Requires a glob-sourcing loop in .zshrc. Well-understood community pattern.
- **Mise:** Native conf.d support via `~/.config/mise/conf.d/*.toml`. Files load alphabetically, settings merge with overrides.

The migration is mostly mechanical. The tricky parts are load ordering, handling the existing local override mechanism, and making sure the transition is clean (no orphaned merged files left behind).

---

## Table Stakes

Features the migration must have or the result is broken or worse than the current system.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Glob-based sourcing loop (zsh) | Core mechanism that replaces Ansible merge | Low | `for f in ~/.zsh/conf.d/*.sh; source "$f"` |
| Fish conf.d directory structure | Fish sources `~/.config/fish/conf.d/*.fish` natively | Low | No loop needed, just place files correctly |
| Mise conf.d directory structure | Mise loads `~/.config/mise/conf.d/*.toml` natively | Low | Alphabetical loading, settings merge |
| Numeric prefix ordering convention | Controls load order deterministically | Low | `00-` through `99-` prefix scheme |
| Module-owned conf.d fragments | Each module stows its own fragment file | Low | Replaces mergeable_files contributions |
| Removal of mergeable_files declarations | Clean break from old system | Low | Delete from all config.yml files |
| Removal of merge logic from role | Dead code after migration | Low | But must happen after all modules migrate |
| Preserved local override mechanism | Machine-specific config must still work | Low | Source .local file last (or use 99- prefix) |
| Idempotent migration path | Running playbook during and after migration must not break things | Medium | Transitional state where both old and new coexist |

### Detail: Glob-Based Sourcing Loop (Zsh)

**What:** A for-loop in `.zshrc` that sources all files matching a glob pattern from a conf.d directory.

**Why table stakes:** This is the fundamental mechanism. Without it, module fragments don't load. Every conf.d implementation for zsh uses this pattern.

**Standard pattern:**
```zsh
# Source all conf.d fragments
for conf in "$HOME/.zsh/conf.d/"*.sh(N); do
  source "$conf"
done
```

The `(N)` glob qualifier is zsh-specific and prevents errors when no files match (null glob). This is important because an empty conf.d directory shouldn't produce errors.

**Placement in .zshrc:** After p10k instant prompt, before compinit. Environment variables and PATH additions need to load early. The current .zshrc already sources `environment.sh`, `aliases.sh`, `functions.sh`, and `utility.zsh` individually. The conf.d loop replaces those four source lines.

**Confidence:** HIGH. This is a well-documented, widely-used pattern.

### Detail: Numeric Prefix Ordering Convention

**What:** Files in conf.d use numeric prefixes to control load order. `00-environment.sh` loads before `50-aliases.sh` which loads before `90-local.sh`.

**Why table stakes:** Shell configuration is order-dependent. Environment variables must be set before aliases that reference them. PATH additions must happen before commands that depend on them. Without ordering, the system works by accident rather than design.

**Recommended scheme:**
```
00-09: Early bootstrap (environment, PATH, platform detection)
10-29: Module environment contributions (editor env, shell utils env)
30-49: Reserved / future use
50-69: Aliases, abbreviations, functions
70-89: Tool activation (mise activate, completions)
90-99: Late loading (local overrides, syntax highlighting)
```

**Naming convention:** `{NN}-{module}-{purpose}.sh`
- `00-zsh-environment.sh` (from zsh module)
- `10-editor-environment.sh` (from editor module)
- `10-shell-environment.sh` (from shell module)
- `50-zsh-aliases.sh` (from zsh module)
- `50-editor-aliases.sh` (from editor module)
- `70-dev-tools-mise.sh` (from dev-tools module)
- `99-local.sh` (local overrides, if using conf.d approach)

**Confidence:** HIGH. Numeric ordering is universal in conf.d systems (systemd, init.d, cron.d).

### Detail: Module-Owned conf.d Fragments

**What:** Instead of each module declaring `mergeable_files: ['.zshrc']` and contributing to a merged output, each module stows its own file into the conf.d directory.

**Current state (being replaced):**
```
modules/editor/config.yml:
  mergeable_files:
    - '.zsh/aliases.sh'       # Merged into shared aliases.sh
    - '.zsh/environment.sh'   # Merged into shared environment.sh

modules/editor/files/.zsh/aliases.sh:    # Contains: alias e='...'
modules/editor/files/.zsh/environment.sh: # Contains: export EDITOR=vim
```

**New state:**
```
modules/editor/files/.zsh/conf.d/10-editor-environment.sh  # export EDITOR=vim
modules/editor/files/.zsh/conf.d/50-editor-aliases.sh      # alias e='...'
```

Each module owns its fragment files. Stow symlinks them into `~/.zsh/conf.d/`. No merge step needed.

**Confidence:** HIGH. Direct consequence of the conf.d pattern.

### Detail: Preserved Local Override Mechanism

**What:** Machine-specific configuration (`.zshrc.local`, `config.local.fish`) must continue to work after migration.

**Options:**
1. Keep the current `.zshrc.local` sourcing line in `.zshrc` (simplest, no change needed)
2. Use a `99-local.sh` conf.d fragment that sources the local file
3. Let users drop a `99-local.sh` directly in the conf.d directory (not stow-managed)

**Recommendation:** Option 1. Keep `.zshrc.local` sourcing at the end of `.zshrc`. It's already there, users know about it, and it loads after all conf.d fragments. No reason to change what works.

For fish, the current `config.local.fish` sourcing at the end of `config.fish` stays as-is. Fish's native conf.d loads before `config.fish`, so local overrides in `config.fish` naturally come last.

**Confidence:** HIGH.

---

## Differentiators

Features that improve on the current system. Not required for migration, but worth considering.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Error isolation per fragment | Bad file doesn't break entire shell | Medium | Wrap source in error handling |
| Debug/trace mode | See which fragments load and timing | Low | `DOTFILES_DEBUG=1` env var |
| Fragment attribution comments | Know which module owns each fragment | Low | Header comment in each file |
| Automated migration script | One command to restructure all modules | Medium | Ansible task or shell script |
| conf.d directory documentation | README in conf.d explaining the convention | Low | Helps future self |
| Startup time measurement | Verify conf.d doesn't slow shell startup | Low | `time zsh -i -c exit` before/after |

### Detail: Error Isolation Per Fragment

**What:** Wrap the sourcing loop so a syntax error in one fragment doesn't prevent the rest from loading.

```zsh
for conf in "$HOME/.zsh/conf.d/"*.sh(N); do
  source "$conf" 2>/dev/null || echo "Error sourcing $conf" >&2
done
```

**Value:** In the merged-file world, a syntax error in one module's contribution breaks the entire merged file. With conf.d, you can isolate failures. But this is a double-edged sword: silently swallowing errors makes debugging harder.

**Recommendation:** Don't suppress errors. Let them surface loudly. A broken fragment should be fixed, not ignored. The simple loop without error handling is better. If you want debugging, use the debug mode feature instead.

**Confidence:** MEDIUM. Most well-known conf.d implementations (fish, systemd) don't suppress errors.

### Detail: Debug/Trace Mode

**What:** An environment variable that, when set, prints each fragment as it's sourced and optionally times it.

```zsh
for conf in "$HOME/.zsh/conf.d/"*.sh(N); do
  [[ -n "$DOTFILES_DEBUG" ]] && echo "sourcing: $conf"
  source "$conf"
done
```

**Value:** When something goes wrong, knowing which file caused it is invaluable. Negligible runtime cost when disabled (one string comparison per file).

**Recommendation:** Worth adding. One extra line in the loop. Useful during migration and for future debugging.

**Confidence:** HIGH.

### Detail: Fragment Attribution Comments

**What:** Each fragment file starts with a comment identifying its source module.

```sh
# Module: editor
# Purpose: Set EDITOR and VISUAL environment variables

if hash vim 2>/dev/null; then
  export EDITOR=vim
...
```

**Value:** The current merged files have Jinja2 headers showing module attribution. Losing that traceability would be a regression. Fragment files should self-document their origin.

**Recommendation:** Do this. Low effort, high clarity. The module name and purpose in a comment header.

**Confidence:** HIGH.

---

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Dynamic fragment discovery/registration | Over-engineering; glob pattern is sufficient | Use the glob loop |
| Fragment dependency resolution | Ordering by numeric prefix is simpler and well-understood | Use numeric prefixes |
| Conditional fragment loading (per-machine) | Adds complexity; use local overrides for machine-specific config | Keep .local file pattern |
| Fragment enable/disable mechanism | Unnecessary with Stow; uninstall module removes its fragments | Remove module via Stow |
| Shared fragment library / inheritance | Modules should be self-contained per constitutional principle | Each module owns its fragments |
| Sub-directory nesting in conf.d | Flat directory with numeric prefixes is clearer | Keep conf.d flat |
| Auto-migration of existing merged files | One-time task, not worth automating for ~6 modules | Manual restructure per module |

### Detail: Fragment Dependency Resolution

**What:** A system where fragments declare dependencies on other fragments, and a resolver determines load order.

**Why avoid:** This is what systemd does, and it's massive overkill for ~10-15 shell config fragments. Numeric prefixes solve the ordering problem completely. The dependency graph is simple and linear (environment before aliases before tool activation). If you can't express your ordering needs with two-digit numbers, you have a design problem, not a tooling problem.

### Detail: Conditional Fragment Loading

**What:** Fragments that check hostname, environment variables, or other conditions before loading. Or a mechanism to skip fragments on certain machines.

**Why avoid:** The local override file (`.zshrc.local`) already handles machine-specific configuration. Putting conditionals in fragments defeats the purpose of simple, static configuration files. The BeyondTrust machine's `--skip-tags register_shell` is an Ansible-time concern, not a runtime concern. At runtime, all deployed fragments should load unconditionally.

### Detail: Sub-Directory Nesting

**What:** Instead of flat `conf.d/`, having `conf.d/environment/`, `conf.d/aliases/`, `conf.d/functions/` subdirectories.

**Why avoid:** Adds navigation complexity. With numeric prefixes, files naturally sort into logical groups visually. `ls conf.d/` shows the full picture at a glance. Thoughtbot's `pre/`/`post/` subdirectory pattern works for their use case (many contributors, team environments) but is unnecessary for a personal dotfiles repo with clear ownership.

---

## Feature Dependencies

```
Glob-based sourcing loop (zsh)
  --> Numeric prefix ordering convention
  --> Module-owned conf.d fragments
        --> Removal of mergeable_files declarations
              --> Removal of merge logic from role

Fish conf.d directory structure
  --> Module-owned conf.d fragments (fish versions)

Mise conf.d directory structure
  --> Module-owned conf.d fragments (mise versions)

Debug/trace mode --> Glob-based sourcing loop
Fragment attribution --> Module-owned conf.d fragments
Preserved local overrides --> (independent, already exists)
```

**Critical path:** The glob loop must exist before any module can move its fragments. Modules can migrate one at a time once the loop is in place. The merge logic removal must happen last, after all modules have migrated.

---

## MVP Recommendation

### Must Do (in this order):

1. **Add conf.d sourcing loop to .zshrc** - Replace the four individual `source` lines with the glob loop. This is the foundation.
2. **Create conf.d directory structure for fish** - Create the `~/.config/fish/conf.d/` path in the fish module's stow tree. Fish handles the rest natively.
3. **Set up mise conf.d directory** - Mise natively supports `~/.config/mise/conf.d/*.toml`.
4. **Migrate module fragments one at a time** - Move each module's mergeable_files contributions to numbered conf.d fragments. Start with the simplest module (shell has one env fragment).
5. **Remove mergeable_files from config.yml** - After each module's fragments are migrated.
6. **Remove merge logic from ansible-role-dotmodules** - After all mergeable_files declarations are gone.
7. **Document the convention** - Write a README or doc explaining the numeric prefix scheme.

### Worth Adding:

- Debug mode (`DOTFILES_DEBUG=1`) in the sourcing loop
- Attribution comments in all fragment files

### Defer:

- Error isolation (let errors surface naturally)
- Automated migration tooling (manual restructure is fine for ~6 modules)
- Any form of fragment dependency resolution

---

## Module Migration Map

Current mergeable_files usage mapped to conf.d fragments:

### Zsh conf.d (~/.zsh/conf.d/)

| Module | Current Contribution | New Fragment | Prefix |
|--------|---------------------|-------------|--------|
| zsh | `.zsh/environment.sh` (platform, NERD_FONT, cdpath, colors) | `00-zsh-environment.sh` | 00 |
| zsh | `.zsh/aliases.sh` (ls, grep, mkdir, dot, ip, pubkey) | `50-zsh-aliases.sh` | 50 |
| shell | `.zsh/environment.sh` (EZA_COLORS) | `10-shell-environment.sh` | 10 |
| editor | `.zsh/environment.sh` (EDITOR, VISUAL) | `10-editor-environment.sh` | 10 |
| editor | `.zsh/aliases.sh` (alias e) | `50-editor-aliases.sh` | 50 |
| dev-tools | `.zshrc` (mise activate zsh) | `70-dev-tools-mise.sh` | 70 |
| zsh | `.zshrc` (functions, utility, compinit, plugins, prompt) | Stays in `.zshrc` | N/A |

**Note:** The .zshrc itself doesn't go into conf.d. It's the orchestrator that sources conf.d. Items like p10k, compinit, autosuggestions, and syntax-highlighting stay in .zshrc because they have specific ordering requirements relative to each other.

### Fish conf.d (~/.config/fish/conf.d/)

| Module | Current Contribution | New Fragment | Prefix |
|--------|---------------------|-------------|--------|
| fish | `config.fish` (env, abbrs, functions, prompt) | Stays in `config.fish` or splits | N/A |
| shell | `config.fish` (EZA_COLORS) | `10-shell-environment.fish` | 10 |
| editor | `config.fish` (abbr ia, marked) | `50-editor-abbrs.fish` | 50 |
| dev-tools | `config.fish` (mise activate) | `70-dev-tools-mise.fish` | 70 |

**Note:** Fish conf.d files load before `config.fish`. So the fish module's own config.fish stays as-is. Other modules' contributions move to conf.d fragments that load before it.

### Mise conf.d (~/.config/mise/conf.d/)

| Module | Current Contribution | New Fragment | Prefix |
|--------|---------------------|-------------|--------|
| dev-tools | `config.toml` (settings, python) | `00-dev-tools.toml` | 00 |
| node | `config.toml` (node, pnpm) | `10-node.toml` | 10 |

**Note:** The `[tools]` header duplication issue goes away with conf.d. Each TOML file is independent and mise merges them.

---

## Sources

- [Fish shell conf.d documentation](https://fishshell.com/docs/current/) - Native conf.d mechanism
- [Fish conf.d sourcing order issue #8553](https://github.com/fish-shell/fish-shell/issues/8553) - Ordering details
- [Mise configuration docs](https://mise.jdx.dev/configuration.html) - conf.d directory support
- [Thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles) - zsh/configs pre/post pattern
- [mattmc3/zdotdir](https://github.com/mattmc3/zdotdir) - Zsh conf.d patterns
- [Carmelyne: Modularizing Your .zshrc](https://carmelyne.com/modularizing-your-zshrc/) - Zsh modularization

---

## Quality Gate Checklist

- [x] Categories are clear (table stakes vs differentiators vs anti-features)
- [x] Complexity noted for each feature
- [x] Dependencies between features identified
- [x] Migration map ties features to concrete module changes
- [x] Fish native conf.d behavior documented
- [x] Mise native conf.d behavior documented
- [x] Numeric ordering convention defined with ranges
- [x] Local override preservation addressed

---

*Research completed: 2026-03-10*
*Based on analysis of: existing module mergeable_files, fish native conf.d, mise conf.d, zsh community patterns, thoughtbot dotfiles*
