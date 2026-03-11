# Phase 6: Mise conf.d Migration - Research

**Researched:** 2026-03-11
**Domain:** mise-en-place TOML configuration, GNU Stow multi-module deployment
**Confidence:** HIGH

## Summary

Mise natively supports loading TOML fragments from `~/.config/mise/conf.d/*.toml` without any includes directive. Files in this directory are loaded alphabetically and merged using additive-with-override semantics for both `[tools]` and `[settings]` sections. This means no skeleton `config.toml` with an includes directive is needed -- mise discovers the conf.d directory automatically as part of its built-in config hierarchy.

The existing config.toml (a Stow symlink from dev-tools) can remain in place alongside the new conf.d directory. The two modules (dev-tools and node) each create a fragment in `modules/{name}/files/.config/mise/conf.d/{name}.toml`, and Stow symlinks them into `~/.config/mise/conf.d/`. Trust is handled by adding `~/.config/mise/conf.d` to the `trusted_config_paths` setting.

**Primary recommendation:** Create conf.d fragments in each module, set `trusted_config_paths` in the dev-tools fragment, then remove the old `config.toml` files. No includes directive or skeleton config needed.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Use glob pattern (`conf.d/*.toml`) so new modules are auto-discovered without editing the main config
- dev-tools module owns the main config.toml (it already installs mise via Homebrew and provides shell activation)
- Conf.d directory path: `~/.config/mise/conf.d/` per requirement spec, unless mise conventions suggest otherwise
- `[settings]` block (asdf_compat=true) goes in the dev-tools conf.d fragment, not a separate file or main config
- Keep asdf_compat=true -- some projects still use .tool-versions files
- No numeric prefixes -- simple module-name format: `dev-tools.toml`, `node.toml`
- Attribution comment headers (consistent with Phase 4/5 convention)
- Current grouping stays: dev-tools fragment has settings + python, node fragment has node + pnpm
- Each conf.d file is a valid standalone TOML document with its own section headers

### Claude's Discretion
- Whether mise supports glob includes natively or needs explicit file listing (research this)
- Skeleton config.toml content and structure (if needed)
- Whether per-fragment `[settings]` sections are supported or if settings must be centralized
- Trust configuration approach for conf.d directory (TOOL-02 requirement)
- Exact conf.d directory path if mise conventions differ from `~/.config/mise/conf.d/`

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| TOOL-01 | Mise loads tool versions from `~/.config/mise/conf.d/*.toml` with standalone TOML headers | Mise natively loads from conf.d directory; each fragment can have its own `[tools]` section; merge is additive-with-override |
| TOOL-02 | Mise trusted_config_paths configured for conf.d directory (no per-file trust prompts) | `trusted_config_paths` accepts directory paths; all files within trusted directories are auto-trusted; set in `[settings]` section |
</phase_requirements>

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| mise | 2025.12.12+ (installed) | Dev tool version manager | Already installed via dev-tools module Homebrew |
| GNU Stow | (installed) | Symlink farm manager | Existing dotfiles deployment mechanism |
| TOML | 1.0 | Configuration format | Mise's native config format |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| ansible-role-dotmodules | (existing) | Module deployment automation | Stow operations during playbook run |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Native conf.d loading | Explicit `includes` directive in skeleton config | Unnecessary -- mise loads conf.d natively |
| `trusted_config_paths` in settings | `MISE_TRUSTED_CONFIG_PATHS` env var | Settings approach is self-contained; env var would need shell fragment coordination |
| `mise trust` per file | `trusted_config_paths` directory | Per-file trust breaks the "add file, it just works" goal |

## Architecture Patterns

### Recommended Project Structure
```
modules/dev-tools/files/.config/mise/
    conf.d/
        dev-tools.toml       # [settings] + [tools] python
modules/node/files/.config/mise/
    conf.d/
        node.toml            # [tools] node + pnpm
```

After Stow deployment:
```
~/.config/mise/
    config.toml              # existing symlink (removed in this phase)
    conf.d/
        dev-tools.toml -> (stow symlink)
        node.toml -> (stow symlink)
```

### Pattern 1: Native conf.d Loading
**What:** Mise automatically discovers and loads all `*.toml` files in `~/.config/mise/conf.d/` in alphabetical order. No includes directive or skeleton config.toml is needed.
**When to use:** Always -- this is mise's built-in behavior.
**Key detail:** The conf.d files are merged using additive-with-override semantics. Each file is a standalone TOML document.

### Pattern 2: Standalone TOML Fragments
**What:** Each conf.d fragment is a complete, valid TOML document with its own section headers.
**When to use:** All conf.d fragments.
**Example:**
```toml
# dev-tools module - mise settings and Python version
# Managed by dotfiles dev-tools module

[settings]
trusted_config_paths = ["~/.config/mise/conf.d"]
asdf_compat = true

[tools]
python = "3.13.2"
```

```toml
# node module - Node.js and pnpm versions
# Managed by dotfiles node module

[tools]
node = "latest"
pnpm = "latest"
```

### Pattern 3: Trust via Settings
**What:** `trusted_config_paths` in `[settings]` accepts directory paths. All config files within that directory are automatically trusted.
**When to use:** In the dev-tools fragment to cover the entire conf.d directory.
**Key detail:** The setting must be in a config file that is itself already trusted. The main `~/.config/mise/config.toml` is auto-trusted by mise. If config.toml is removed and only conf.d files exist, there may be a bootstrap issue (see Pitfalls).

### Anti-Patterns to Avoid
- **Skeleton config.toml with includes:** Unnecessary complexity. Mise loads conf.d natively.
- **`[tools]` header omission:** The old merge-artifact pattern. Each conf.d fragment MUST have its own `[tools]` header since they are standalone documents.
- **Numeric prefixes for mise conf.d:** Unlike shell conf.d, tool definitions have no ordering dependencies. Simple `{module-name}.toml` naming per user decision.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Config merging | Custom merge logic | Mise native conf.d loading | Mise handles additive merge automatically |
| Trust management | Per-file `mise trust` calls | `trusted_config_paths` setting | Auto-trusts all files in directory |
| File discovery | Includes directive | Mise's built-in conf.d glob | Already part of mise's config hierarchy |

**Key insight:** This phase eliminates the ansible-role-dotmodules merge logic for mise configs by using mise's own native directory-based loading.

## Common Pitfalls

### Pitfall 1: Trust Bootstrap Chicken-and-Egg
**What goes wrong:** If `config.toml` is removed before conf.d files are trusted, the conf.d files containing `trusted_config_paths` setting may themselves trigger trust prompts.
**Why it happens:** `trusted_config_paths` lives inside a conf.d fragment that needs to be trusted first.
**How to avoid:** Either (a) keep a minimal `config.toml` with just `trusted_config_paths` setting, or (b) run `mise trust ~/.config/mise/conf.d/dev-tools.toml` once after first deployment, or (c) set `MISE_TRUSTED_CONFIG_PATHS=~/.config/mise/conf.d` as an environment variable in a shell fragment (already-trusted activation script).
**Recommended approach:** Option (c) is cleanest. Add `export MISE_TRUSTED_CONFIG_PATHS="$HOME/.config/mise/conf.d"` to the existing mise activation shell fragments (80-dev-tools-mise.sh and 80-dev-tools-mise.fish) which are already loaded before mise runs. Then also include `trusted_config_paths` in the dev-tools.toml for completeness/documentation purposes.

### Pitfall 2: Stale config.toml Symlink
**What goes wrong:** After creating conf.d fragments, the old `config.toml` symlink still exists and loads conflicting tool versions.
**Why it happens:** Stow doesn't automatically remove old symlinks when you add new files.
**How to avoid:** Remove old `config.toml` files from both `modules/dev-tools/files/.config/mise/config.toml` and `modules/node/files/.config/mise/config.toml`, then restow. The old symlink at `~/.config/mise/config.toml` will be removed by restow.
**Warning signs:** `mise config ls` shows both config.toml and conf.d files; duplicate tool definitions.

### Pitfall 3: Legacy .tool-versions File
**What goes wrong:** `modules/dev-tools/files/.tool-versions` declares `nodejs 22.9.0`, which conflicts with the node module's `node = "latest"` configuration.
**Why it happens:** This is a stale artifact from before the node module existed. It's currently active (`mise config ls` shows it).
**How to avoid:** Remove the `.tool-versions` file from dev-tools module as part of this phase or note it for Phase 7. It pins Node.js to 22.9.0 when the intent is "latest".
**Warning signs:** `mise ls` shows Node.js pinned to old version despite conf.d saying "latest".

### Pitfall 4: Stow Directory Folding
**What goes wrong:** When only one module has a `conf.d/` directory, Stow creates a symlink to the entire directory rather than individual file symlinks. Adding a second module's conf.d file later causes a conflict.
**Why it happens:** Stow's tree folding optimization.
**How to avoid:** Both modules should have their conf.d fragments created and stowed in the same playbook run. If they are stowed sequentially, Stow will automatically unfold the directory symlink into individual file symlinks when the second module is stowed. This is standard Stow behavior and works correctly -- just be aware of it during testing.

### Pitfall 5: TOML Comment Syntax
**What goes wrong:** Using `//` or `/* */` comments in TOML files.
**Why it happens:** Habit from other formats.
**How to avoid:** TOML only supports `#` for comments. The attribution headers must use `#`.

## Code Examples

### dev-tools conf.d Fragment
```toml
# dev-tools module - mise settings and Python version
# Managed by dotfiles dev-tools module

[settings]
trusted_config_paths = ["~/.config/mise/conf.d"]
asdf_compat = true

[tools]
python = "3.13.2"
```

### node conf.d Fragment
```toml
# node module - Node.js and pnpm versions
# Managed by dotfiles node module

[tools]
node = "latest"
pnpm = "latest"
```

### Trust Bootstrap in Shell Activation (zsh)
```bash
# shellcheck shell=zsh
# dev-tools module - mise-en-place runtime manager activation

export MISE_TRUSTED_CONFIG_PATHS="$HOME/.config/mise/conf.d"
eval "$(mise activate zsh)"
```

### Trust Bootstrap in Shell Activation (fish)
```fish
# dev-tools module - mise-en-place runtime manager activation

set -gx MISE_TRUSTED_CONFIG_PATHS "$HOME/.config/mise/conf.d"
mise activate fish | source
```

### Verification Commands
```bash
# Verify conf.d files are loaded
mise config ls
# Expected: shows conf.d/dev-tools.toml and conf.d/node.toml

# Verify tools are loaded from conf.d
mise ls
# Expected: python, node, pnpm all present

# Verify no trust prompt
mise ls  # should not prompt

# Verify settings
mise settings ls
# Expected: asdf_compat = true, trusted_config_paths includes conf.d
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single merged config.toml via Ansible | Native conf.d directory loading | Always supported by mise | No Ansible redeploy needed for config changes |
| Omitting `[tools]` header (merge artifact) | Full standalone TOML per fragment | This phase | Each file is self-documenting |
| Per-file `mise trust` | `trusted_config_paths` directory setting | Mise 2024+ | Auto-trust all files in directory |

**Deprecated/outdated:**
- Merge artifact pattern (bare tool definitions without `[tools]` header): Fixed by this migration

## Discretion Recommendations

Based on research findings, here are recommendations for the Claude's Discretion items:

1. **Glob includes vs native:** Mise loads conf.d natively. No includes directive needed. No skeleton config.toml needed.

2. **Per-fragment [settings]:** Supported. Settings merge additively across files. Place `[settings]` in dev-tools.toml only (per user decision). Other modules don't need settings sections unless they have module-specific settings.

3. **Trust configuration:** Use dual approach: `MISE_TRUSTED_CONFIG_PATHS` env var in shell activation fragments (solves bootstrap) + `trusted_config_paths` in dev-tools.toml `[settings]` (documentation/belt-and-suspenders).

4. **Conf.d directory path:** `~/.config/mise/conf.d/` is exactly correct. This matches mise's built-in config hierarchy.

5. **Skeleton config.toml:** Not needed. Remove the old config.toml files entirely. Mise loads conf.d without a parent config.toml.

## Open Questions

1. **Legacy .tool-versions cleanup**
   - What we know: `modules/dev-tools/files/.tool-versions` contains `nodejs 22.9.0` and is actively loaded
   - What's unclear: Whether this should be cleaned up in Phase 6 or deferred to Phase 7
   - Recommendation: Remove it in this phase since it directly conflicts with the node module's tool definition and would cause confusing `mise ls` output after migration

2. **Old config.toml removal timing**
   - What we know: Removing config.toml and adding conf.d fragments should happen in the same restow operation
   - What's unclear: Whether mergeable_files config.yml entries should also be removed now or in Phase 7
   - Recommendation: Remove the config.toml files from modules but leave mergeable_files declarations in config.yml for Phase 7 (MIGR-01 is explicitly Phase 7 scope). The mergeable_files entry becomes a no-op once the source file doesn't exist.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual verification via mise CLI |
| Config file | none -- uses mise built-in commands |
| Quick run command | `mise config ls && mise ls` |
| Full suite command | `mise config ls && mise ls && mise settings ls` |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| TOOL-01 | Mise loads tools from conf.d fragments | smoke | `mise config ls --json \| python3 -c "import sys,json; configs=json.load(sys.stdin); assert any('conf.d' in c['path'] for c in configs)"` | N/A (CLI) |
| TOOL-01 | Tools show correct versions | smoke | `mise ls --json \| python3 -c "import sys,json; tools=json.load(sys.stdin); assert 'python' in tools and 'node' in tools"` | N/A (CLI) |
| TOOL-02 | No trust prompt for conf.d files | manual-only | Run `mise ls` in new shell, verify no prompt | N/A |

### Sampling Rate
- **Per task commit:** `mise config ls && mise ls`
- **Per wave merge:** Full suite including settings verification
- **Phase gate:** All verification commands pass in fresh shell

### Wave 0 Gaps
None -- verification uses mise's built-in CLI commands, no test infrastructure needed.

## Sources

### Primary (HIGH confidence)
- [mise configuration docs](https://mise.jdx.dev/configuration.html) - conf.d native loading, config hierarchy, merge semantics
- [mise settings docs](https://mise.jdx.dev/configuration/settings.html) - trusted_config_paths syntax and behavior
- Local mise installation (v2025.12.12) - verified current config state, commands

### Secondary (MEDIUM confidence)
- [GitHub Discussion #7886](https://github.com/jdx/mise/discussions/7886) - trusted_config_paths env var behavior confirmed
- [GitHub Discussion #3544](https://github.com/jdx/mise/discussions/3544) - trust mechanism directory-based tracking confirmed

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - mise is already installed, conf.d is documented native behavior
- Architecture: HIGH - verified conf.d loading against official docs and local mise installation
- Pitfalls: HIGH - trust bootstrap issue verified through documentation analysis; Stow behavior confirmed by existing fish conf.d pattern

**Research date:** 2026-03-11
**Valid until:** 2026-04-11 (stable -- mise conf.d is a mature feature)
