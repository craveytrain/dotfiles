# Domain Pitfalls: Runtime conf.d Sourcing Migration

**Domain:** Dotfiles conf.d migration (replacing Ansible-merged files with runtime sourcing)
**Researched:** 2026-03-10

---

## Critical Pitfalls

Mistakes that break existing shell functionality or require significant rework.

### Pitfall 1: Duplicate Definitions Across Merged and conf.d Files During Migration

**What goes wrong:** During the transition period, both the old merged file and the new conf.d fragment exist. The same aliases, environment variables, or functions are defined twice. Some definitions are idempotent (re-exporting the same value), but others cause subtle bugs: duplicate PATH entries, duplicate `abbr` registrations in fish that produce warnings, or conflicting function definitions where last-write-wins produces unexpected behavior.

**Why it happens:** The migration can't be atomic across all modules at once. If you move one module's contributions to conf.d but leave others in the merged file, you need the merged file to still exist for the remaining modules. But the conf.d file also gets sourced, doubling up the moved module's contributions.

**Consequences:** Shell startup warnings, unexpected alias behavior, doubled PATH segments, and hard-to-debug "works on one machine but not another" issues if machines are at different migration stages.

**Prevention:**
1. Migrate per-file, not per-module. Move ALL contributions to `.zsh/aliases.sh` at once (from zsh module + editor module), not "move everything from editor module first."
2. Remove the merged file for a given target path only when ALL modules contributing to it have been migrated.
3. Use a checklist tracking which merged file targets still have contributors:
   - `.zshrc`: zsh, dev-tools (2 modules)
   - `.zsh/aliases.sh`: zsh, editor (2 modules)
   - `.zsh/environment.sh`: zsh, shell, editor (3 modules)
   - `.config/fish/config.fish`: fish, dev-tools, shell, editor (4 modules)
   - `.config/mise/config.toml`: dev-tools, node (2 modules)

**Detection:** Run `grep -c 'function_name_or_alias' ~/.zsh/conf.d/*` and check for duplicate definitions. Fish will warn about duplicate abbreviations on startup.

**Phase relevance:** This is the core migration risk. Address in every phase that touches a merged file.

### Pitfall 2: Zsh Sourcing Order Creates Dependency Failures

**What goes wrong:** The current `.zshrc` sources files in a deliberate order: environment.sh first, then aliases.sh, then functions.sh. The conf.d glob (`~/.zsh/conf.d/*.sh`) sources in alphabetical order. If a conf.d file from module B depends on an environment variable set by a conf.d file from module A, the alphabetical prefix must encode that dependency correctly. Get the numbering wrong and aliases that reference `$EDITOR` break because the editor module's environment.sh hasn't been sourced yet.

**Why it happens:** The current merged-file system implicitly handles ordering because the merge concatenates in module order from deploy.yml. A glob-based system doesn't have that implicit ordering, and the dependency isn't obvious from reading any single file.

**Consequences:** Shell startup errors, undefined variable references, commands that silently do the wrong thing (e.g., `$EDITOR` is empty so `alias e` opens nothing).

**Prevention:**
1. Map existing dependencies before creating any conf.d files. The current codebase has:
   - `aliases.sh` depends on `environment.sh` (the `e` alias uses `$EDITOR`/`$VISUAL`)
   - `aliases.sh` depends on eza being in PATH (conditional aliases)
   - `dev-tools .zshrc` depends on mise being installed (eval mise activate)
2. Use a numbering convention that groups by purpose:
   - `00-09`: PATH and core environment (Homebrew, PATH additions)
   - `10-19`: Tool activation (mise activate, etc.)
   - `20-29`: Environment variables (EDITOR, VISUAL, PAGER, etc.)
   - `30-39`: Aliases
   - `40-49`: Functions
   - `50-59`: Module-specific configuration
   - `90-99`: Local overrides
3. Document the numbering convention in a README within the conf.d directory.

**Detection:** New shell session produces errors or warnings. Test with `zsh -i -c exit` and check stderr.

**Phase relevance:** Must be designed upfront before any conf.d files are created. The numbering scheme is a prerequisite for all subsequent migration work.

### Pitfall 3: Fish conf.d Sources BEFORE config.fish

**What goes wrong:** Fish's native `~/.config/fish/conf.d/` directory is sourced BEFORE `~/.config/fish/config.fish`. If you move module contributions into conf.d files but they depend on variables or PATH set in config.fish, they'll fail silently or behave differently.

**Why it happens:** Fish's documented sourcing order is: conf.d files first (alphabetically), then config.fish. This is the opposite of what most people assume. The current system merges everything into config.fish, so ordering is implicit within that single file.

**Consequences:** Environment variables not set, PATH not configured, abbreviations that reference undefined variables, mise not activated when conf.d files expect it.

**Prevention:**
1. Understand the current config.fish structure. Right now, the fish module's config.fish sets PATH (`brew shellenv`, `fish_add_path`), environment variables, abbreviations, functions, and prompt config all in one file. The shell module and dev-tools module contribute additional lines.
2. Keep PATH setup and core environment in config.fish (it runs after conf.d). Move only independent fragments to conf.d.
3. Alternatively, make ALL conf.d files self-contained: each file should not depend on config.fish having run first. This means each conf.d file that needs Homebrew PATH should include its own `eval (/opt/homebrew/bin/brew shellenv)` guard or similar.
4. Test ordering explicitly: `fish -c 'echo $PATH'` after migration to verify.

**Detection:** Fish abbreviations that reference undefined variables, commands not found because PATH isn't set yet in conf.d files.

**Phase relevance:** Fish migration phase. Must be researched and designed before moving any fish contributions to conf.d.

### Pitfall 4: TOML Section Headers Break Mise conf.d

**What goes wrong:** The current mise merge hack puts `[tools]` header only in the dev-tools module and omits it from the node module because concatenation would produce duplicate headers. When migrating to mise's native `~/.config/mise/conf.d/`, each file is parsed independently as valid TOML, so every file MUST have its own section headers. If you copy the node module's current content (`node = "latest"` without `[tools]`) into a conf.d file, mise will fail to parse it or put the values under the wrong section.

**Why it happens:** The current system was designed around string concatenation. TOML conf.d expects each file to be a standalone valid TOML document.

**Consequences:** Mise silently ignores tool versions, or reports TOML parse errors. Tools stop being managed, and you don't notice until `node --version` returns the system version instead of the managed one.

**Prevention:**
1. Every mise conf.d file must be a valid standalone TOML document with proper section headers.
2. The node module's conf.d file should be:
   ```toml
   [tools]
   node = "latest"
   pnpm = "latest"
   ```
3. The dev-tools module's conf.d file should be:
   ```toml
   [settings]
   asdf_compat = true

   [tools]
   python = "3.13.2"
   ```
4. Test with `mise doctor` and `mise ls` after migration to verify all tools are still recognized.

**Detection:** `mise ls` shows fewer tools than expected. `mise doctor` reports config issues.

**Phase relevance:** Mise migration phase. Simple to prevent if you know about it, catastrophic if you don't.

### Pitfall 5: Stow Conflicts When Changing File Structure

**What goes wrong:** The migration changes where files live. Currently, module X has `files/.zsh/aliases.sh` which gets merged. After migration, module X has `files/.zsh/conf.d/30-editor-aliases.sh`. But the old symlink for `.zsh/aliases.sh` still exists from the merged system. Stow doesn't clean up old symlinks when the source file structure changes. You end up with stale symlinks pointing to removed files, and the merged file continues to be sourced alongside the conf.d directory.

**Why it happens:** Stow tracks what it has stowed, but when you restructure a module's files directory, you need to unstow the old structure before stowing the new one. If you just run the playbook, the old symlinks from the merged module remain.

**Consequences:** Broken symlinks in the home directory, sourcing errors when zsh tries to load a file that no longer exists, or double-sourcing if the old merged file and new conf.d both exist.

**Prevention:**
1. Add a migration step that unstows the old module structure before stowing the new one.
2. Alternatively, manually clean up `~/.dotmodules/merged/` and its symlinks before the first post-migration deploy.
3. Create a migration script or documented checklist that removes:
   - The `modules/merged/` directory contents
   - Any symlinks in `~/` that point to `~/.dotmodules/merged/`
4. Test by checking for broken symlinks: `find ~ -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null`

**Detection:** `ls -la ~/.zsh/` shows broken symlinks (red in most terminals). Shell startup errors about missing files.

**Phase relevance:** Must be addressed in the first migration phase. The cleanup step is a prerequisite for the entire migration.

---

## Moderate Pitfalls

### Pitfall 6: The .zshrc Itself Has Module Contributions

**What goes wrong:** Both the zsh module and dev-tools module contribute to `.zshrc` via mergeable_files. The zsh module owns the main `.zshrc` file (with p10k, compinit, plugin loading). The dev-tools module adds `eval "$(mise activate zsh)"`. After migration, where does the mise activation go? It can't go in a conf.d file because it needs to run at a specific point in the .zshrc lifecycle (after PATH is set, before completions that depend on mise-managed tools).

**Prevention:**
1. Don't put .zshrc contributions into conf.d. The .zshrc file is special because it has ordering constraints that conf.d can't easily express (p10k instant prompt must be first, syntax highlighting must be last).
2. Instead, inline the dev-tools module's `.zshrc` contribution directly into the zsh module's `.zshrc`. The line `eval "$(mise activate zsh)"` should be placed in `.zshrc` after Homebrew PATH is set.
3. The .zshrc then sources conf.d for aliases, environment, and functions, but its own structure remains a single authored file.

**Detection:** mise commands not found, or compinit doesn't see mise-provided completions.

**Phase relevance:** Zsh migration phase. Design decision that must be made before implementation.

### Pitfall 7: Fish conf.d Files from Stow Collide with Fisher Plugin Files

**What goes wrong:** Fisher (fish plugin manager) installs plugin configuration into `~/.config/fish/conf.d/` and `~/.local/share/fish/vendor_conf.d/`. If your Stow-managed conf.d files use names that collide with Fisher-generated files, or if Fisher and Stow both try to manage the conf.d directory itself, you get conflicts.

**Prevention:**
1. Use a clear naming prefix for Stow-managed files: `dotfiles-*.fish` or a numeric prefix scheme that won't collide with Fisher's naming.
2. Verify that Stow with `--no-folding` creates individual symlinks inside conf.d rather than symlinking the conf.d directory itself. With --no-folding, Stow should create the directory and symlink individual files, which is what you want.
3. Check what Fisher currently puts in conf.d: `ls ~/.config/fish/conf.d/` on a deployed machine.

**Detection:** `stow` errors about existing files in conf.d, or Fisher plugins stop working after deploy.

**Phase relevance:** Fish migration phase.

### Pitfall 8: Local Override Pattern Changes Semantics

**What goes wrong:** Currently, `.zshrc.local` is sourced at a specific point in .zshrc (after all configuration, before plugins). With conf.d, if you move local overrides to `~/.zsh/conf.d/99-local.sh`, the override runs at a different point in the startup sequence. Variables set in .zshrc.local that were meant to override things set earlier in .zshrc may now run too early or in the wrong context.

**Prevention:**
1. Keep the `.zshrc.local` and `config.local.fish` patterns as-is. They work, they're documented, and they solve a different problem than conf.d.
2. conf.d is for module contributions. Local overrides are for machine-specific customization. Don't conflate them.
3. Make .zshrc source conf.d, THEN source .zshrc.local, preserving the override semantics.

**Detection:** Machine-specific overrides stop working after migration.

**Phase relevance:** All migration phases. Document this clearly so future contributors don't move local overrides into conf.d.

### Pitfall 9: Performance Regression from Glob Sourcing

**What goes wrong:** Replacing a single merged file with glob-based sourcing of N individual files adds N-1 additional file opens and shell source operations. For zsh, each `source` call has overhead (file open, parse, execute). With 5-10 conf.d files per category (aliases, environment, functions), that's 15-30 additional source calls per shell startup.

**Prevention:**
1. The project already estimated ~2ms overhead, which is negligible. But verify after implementation.
2. Use `zsh/zprof` to benchmark before and after: add `zmodload zsh/zprof` at top of .zshrc and `zprof` at bottom, compare results.
3. Keep the number of conf.d files reasonable. With 11 modules and only 5 files being merged, you're looking at maybe 10-15 conf.d files total. This is fine.
4. Avoid sourcing conf.d directories that have zero files (use the `(N)` glob qualifier in zsh to suppress errors on empty globs).

**Detection:** Noticeable delay when opening new terminal. Profile with `time zsh -i -c exit`.

**Phase relevance:** Validate during the first migration phase (zsh). If performance is acceptable for zsh, fish and mise will be fine.

### Pitfall 10: Empty Glob Errors in Zsh

**What goes wrong:** If `~/.zsh/conf.d/` exists but contains no `*.sh` files (or the directory doesn't exist yet), a bare glob `source ~/.zsh/conf.d/*.sh` in zsh will produce a "no matches found" error and potentially abort .zshrc execution.

**Prevention:**
1. Use the null glob qualifier: `for f in ~/.zsh/conf.d/*.sh(N); do source "$f"; done`
2. The `(N)` qualifier makes zsh return an empty list instead of erroring when no files match.
3. Alternatively, check directory existence first: `[[ -d ~/.zsh/conf.d ]] && for f in ...`

**Detection:** New shell session shows "no matches found: /Users/.../.zsh/conf.d/*.sh" error.

**Phase relevance:** Zsh migration phase. Must be in the sourcing loop implementation from day one.

---

## Minor Pitfalls

### Pitfall 11: Forgetting to Remove mergeable_files from config.yml

**What goes wrong:** After migrating a file to conf.d, the `mergeable_files` declaration remains in the module's config.yml. Next time ansible-role-dotmodules runs, it still tries to merge the old file, potentially recreating the merged output alongside the new conf.d structure.

**Prevention:** Include config.yml cleanup in each migration step's checklist. Verify with `grep -r mergeable_files modules/*/config.yml` after migration.

**Detection:** Unexpected files appearing in `~/.dotmodules/merged/` after deployment.

**Phase relevance:** Every migration phase.

### Pitfall 12: Conf.d Files Need Consistent Shebang/Guard Patterns

**What goes wrong:** Some current files start with `#!/usr/bin/env sh`, some with `#!/usr/bin/env zsh`, some with no shebang. Conf.d files sourced by zsh don't need shebangs (they're sourced, not executed), but inconsistency makes it unclear whether a file is meant to be sourced or executed.

**Prevention:**
1. Drop shebangs from conf.d files entirely. They're sourced, not executed.
2. Add a comment header indicating the sourcing context: `# Sourced by ~/.zshrc via conf.d`
3. Keep `.sh` extension for zsh conf.d files (existing convention), `.fish` for fish conf.d files.

**Detection:** ShellCheck warnings about unused shebangs.

**Phase relevance:** All migration phases. Establish convention before first file is created.

### Pitfall 13: Editor Module's environment.sh Duplicates zsh Module's environment.sh

**What goes wrong:** Both the zsh module and editor module currently have `files/.zsh/environment.sh`. The zsh module's version sets EDITOR, VISUAL, PAGER, PLATFORM, and more. The editor module's version also sets EDITOR and VISUAL. In the merged system, these are concatenated. In conf.d, you'd have two files both setting `$EDITOR`, with last-write-wins behavior determined by alphabetical ordering.

**Prevention:**
1. During migration, deduplicate. The EDITOR/VISUAL settings belong in the editor module's conf.d file, not the zsh module's.
2. Split the current zsh environment.sh into logical conf.d files: platform detection, editor settings, PATH/CDPATH, colors, etc.
3. Assign each concern to the module that owns it: editor module owns EDITOR/VISUAL, zsh module owns PLATFORM/CDPATH/PAGER, shell module owns EZA_COLORS.

**Detection:** Review conf.d files for duplicate variable assignments before committing.

**Phase relevance:** Zsh migration phase. The deduplication is the real work of the migration.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Numbering convention design | Pitfall 2: wrong ordering breaks dependencies | Map all current dependencies first, design convention around them |
| Zsh conf.d implementation | Pitfall 10: empty glob errors | Use `(N)` glob qualifier from the start |
| Zsh conf.d implementation | Pitfall 6: .zshrc is special | Keep .zshrc as authored file, don't conf.d-ify it |
| Zsh conf.d implementation | Pitfall 13: duplicate EDITOR definitions | Deduplicate during migration, assign ownership |
| Fish conf.d implementation | Pitfall 3: conf.d runs before config.fish | Keep PATH/env setup in config.fish, only move independent fragments |
| Fish conf.d implementation | Pitfall 7: Fisher file collisions | Use dotfiles- prefix for Stow-managed conf.d files |
| Mise conf.d implementation | Pitfall 4: TOML headers required | Each file must be valid standalone TOML |
| Stow restructuring | Pitfall 5: stale symlinks from old structure | Unstow/clean old structure before deploying new |
| All phases | Pitfall 1: duplicates during transition | Migrate per-target-file, not per-module |
| All phases | Pitfall 11: stale mergeable_files declarations | Grep config.yml files after each phase |
| Cleanup phase | Pitfall 8: local override semantics change | Keep .local pattern separate from conf.d |

---

## Sources

- [Fish conf.d sourcing order issue #8553](https://github.com/fish-shell/fish-shell/issues/8553)
- [Fish conf.d sourcing order documentation issue #3099](https://github.com/fish-shell/fish-shell/issues/3099)
- [Fish conf.d load order changed in 3.1.0 #6593](https://github.com/fish-shell/fish-shell/issues/6593)
- [Mise configuration documentation](https://mise.jdx.dev/configuration.html)
- [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Optimizing zsh startup times](https://coderlegion.com/11431/from-1-4s-to-53ms-optimizing-zsh-startup-on-macos)
- [Zsh zprof optimization](https://www.mikekasberg.com/blog/2025/05/29/optimizing-zsh-init-with-zprof.html)

---

*Pitfall research: 2026-03-10*
