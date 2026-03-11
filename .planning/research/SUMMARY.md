# Project Research Summary

**Project:** Dotfiles v1.1 Runtime Includes
**Domain:** Dotfiles configuration management (Stow + Ansible migration)
**Researched:** 2026-03-10
**Confidence:** HIGH

## Executive Summary

This project replaces the Ansible-time merged file system with runtime conf.d sourcing across three tools: zsh, fish, and mise. The current system concatenates contributions from multiple modules into single files at deploy time (via Ansible), then symlinks the merged output. This works but creates an edit-deploy-test cycle, fragile TOML concatenation hacks, and hidden composition where module ownership is unclear. The conf.d approach is the standard Unix solution to this problem, used by systemd, nginx, cron, and natively supported by both fish and mise.

The recommended approach is straightforward: add a glob-sourcing loop to `.zshrc`, leverage fish's native conf.d support, and leverage mise's native conf.d support. Each module stows its own numbered fragment file into the appropriate conf.d directory. No new dependencies are needed. All three tools already support this pattern in their installed versions (zsh 5.9, fish 4.2.1, mise 2025.12.12). The migration is mostly mechanical, restructuring files and updating config.yml declarations.

The primary risk is the transition period. During migration, both the old merged files and new conf.d fragments can coexist, causing duplicate definitions and subtle bugs. The mitigation is to migrate per-target-file (move ALL contributors to a merged file at once) rather than per-module. Secondary risks include zsh sourcing order dependencies (solved by numeric prefixes) and fish's conf.d-before-config.fish ordering (solved by keeping PATH/env in config.fish). Stale symlinks from the old merge system need explicit cleanup.

## Key Findings

### Recommended Stack

No new dependencies. The migration uses capabilities already present in installed versions of zsh, fish, and mise. Stow and Ansible continue in their existing roles.

**Core technologies:**
- **Zsh `(N)` glob qualifier**: Sources `~/.zsh/conf.d/*.sh` safely with no errors on empty directories
- **Fish native conf.d**: `~/.config/fish/conf.d/*.fish` auto-sourced alphabetically before config.fish
- **Mise native conf.d**: `~/.config/mise/conf.d/*.toml` loaded alphabetically with proper TOML merge semantics
- **Numeric prefix convention (00-99)**: Deterministic load ordering across all three conf.d directories
- **Mise `trusted_config_paths` setting**: One-time trust for the entire conf.d directory, avoiding per-file trust

### Expected Features

**Must have (table stakes):**
- Glob-based sourcing loop in .zshrc with `(N)` qualifier
- Fish and mise conf.d directory structures with stowed fragment files
- Numeric prefix ordering convention (2-digit, grouped by purpose)
- Module-owned conf.d fragments replacing all mergeable_files declarations
- Removal of merge logic from ansible-role-dotmodules
- Preserved local override mechanism (.zshrc.local, config.local.fish unchanged)
- Idempotent migration path (playbook works during and after migration)

**Should have (differentiators over current system):**
- Debug/trace mode (`DOTFILES_DEBUG=1` in sourcing loop) for migration and future debugging
- Fragment attribution comments (module name + purpose header in each file)

**Defer:**
- Error isolation per fragment (let errors surface loudly)
- Automated migration tooling (manual restructure is fine for 6 modules)
- Fragment dependency resolution (numeric prefixes are sufficient)
- Sub-directory nesting in conf.d (flat is better for this scale)

### Architecture Approach

Each module stows its own conf.d fragment files into shared conf.d directories. The shell (or tool) sources all fragments at runtime via glob patterns. The `.zshrc` and `config.fish` become single-owner files that orchestrate conf.d sourcing rather than being merge targets. Stow's existing `--no-folding` flag ensures conf.d directories are real directories with individual file symlinks, not directory symlinks. The EDITOR/VISUAL duplication between zsh and editor modules gets resolved by assigning clear ownership to the editor module.

**Major components:**
1. **zsh module** -- Owns .zshrc (sole owner), adds conf.d glob loop, contributes environment and alias fragments
2. **fish module** -- Owns config.fish (sole owner), other modules contribute to native conf.d
3. **dev-tools module** -- Owns mise config.toml (sole owner), contributes mise activation fragments to zsh/fish conf.d
4. **shell module** -- Contributes EZA_COLORS fragments to zsh and fish conf.d
5. **editor module** -- Contributes EDITOR/VISUAL and alias fragments to zsh and fish conf.d
6. **node module** -- Contributes tool versions to mise conf.d (with proper TOML headers)
7. **ansible-role-dotmodules** -- merge_files.yml removed after all modules migrate

### Critical Pitfalls

1. **Duplicate definitions during transition** -- Migrate per-target-file, not per-module. Move ALL contributors to a merged file at once. Remove the merged file only when all its contributors have migrated.
2. **Zsh sourcing order dependencies** -- Map all variable dependencies before creating conf.d files. Environment (00-19) before aliases (50-69) before tool activation (70-89). Use wide numeric gaps.
3. **Fish conf.d sources BEFORE config.fish** -- Keep PATH setup and core environment in config.fish. Only move independent, cross-module fragments to conf.d.
4. **TOML headers required in mise conf.d** -- Each conf.d file must be a valid standalone TOML document. The node module's current "omit [tools] header" hack must be reversed.
5. **Stale symlinks from old merge structure** -- Unstow/clean old merged structure before deploying new conf.d structure. Check for broken symlinks in `~/.dotmodules/merged/`.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Zsh conf.d Migration

**Rationale:** Zsh is the primary shell with the most merge participants (5 modules, 3 merged files). Establishing the pattern here informs all subsequent phases. It also delivers the highest value: the edit-deploy-test cycle affects zsh users most.

**Delivers:** Runtime conf.d sourcing for zsh, eliminating the Ansible merge step for .zshrc, aliases.sh, and environment.sh. EDITOR/VISUAL ownership resolved. Debug mode in sourcing loop.

**Addresses:** Glob-based sourcing loop, numeric prefix convention, module-owned fragments, debug mode, fragment attribution, EDITOR/VISUAL deduplication.

**Avoids:** Pitfall 1 (duplicates) by migrating all contributors to each merged file at once. Pitfall 2 (ordering) by designing the numbering scheme upfront. Pitfall 5 (stale symlinks) by cleaning merged output before deploying. Pitfall 6 (.zshrc is special) by keeping it as an authored file. Pitfall 10 (empty globs) by using `(N)` qualifier. Pitfall 13 (duplicate EDITOR) by assigning ownership.

### Phase 2: Fish conf.d Migration

**Rationale:** Fish has native conf.d support, making this the simplest shell migration. The naming pattern from Phase 1 carries over directly.

**Delivers:** Fish module contributions moved to native conf.d. config.fish becomes single-owner. Shell, editor, and dev-tools modules contribute via conf.d fragments.

**Addresses:** Fish conf.d directory structure, module-owned fish fragments, fragment attribution.

**Avoids:** Pitfall 3 (conf.d before config.fish) by keeping PATH/env in config.fish. Pitfall 7 (Fisher collisions) by using numeric-prefixed naming that won't collide with plugin files.

### Phase 3: Mise conf.d Migration

**Rationale:** Fewest participants (2 modules). Lowest risk. Fixes the fragile TOML concatenation hack where node module had to omit `[tools]` header.

**Delivers:** Node module gets proper standalone TOML file with its own section headers. dev-tools module's config.toml becomes single-owner. Mise trusted_config_paths configured.

**Addresses:** Mise conf.d structure, standalone TOML documents, trust configuration.

**Avoids:** Pitfall 4 (TOML headers) by ensuring each file is valid standalone TOML.

### Phase 4: Cleanup and Documentation

**Rationale:** Can only happen after all modules have migrated. Removing merge logic while any module still uses it would break deployments.

**Delivers:** Removed merge_files.yml and merged_file.j2 from ansible-role-dotmodules. Cleaned up ~/.dotmodules/merged/ directory. Documented numeric prefix convention. Verified no modules still declare mergeable_files.

**Addresses:** Merge logic removal, stale file cleanup, convention documentation.

**Avoids:** Pitfall 11 (stale mergeable_files) with final grep verification.

### Phase Ordering Rationale

- **Zsh first** because it has the most complex merge situation (5 modules, 3 files) and the highest daily-use impact. If the pattern works for zsh, it works everywhere.
- **Fish second** because native conf.d support means zero custom sourcing code, but the fish-specific ordering quirk (conf.d before config.fish) needs attention.
- **Mise third** because it only involves 2 modules and the fix is simple (add TOML headers, move to conf.d directory).
- **Cleanup last** because merge logic must remain functional during incremental migration. Removing it early would break any module not yet migrated.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 1 (Zsh):** The numbering scheme design and .zshrc restructuring need careful planning. The EDITOR/VISUAL deduplication and p10k/compinit/plugin ordering constraints make this the most nuanced phase.
- **Phase 2 (Fish):** Verify Fisher plugin conf.d state on deployed machines. The conf.d-before-config.fish ordering needs validation with actual fish module content.

Phases with standard patterns (skip research-phase):
- **Phase 3 (Mise):** Two files, well-documented native support, verified on installed version. Straightforward.
- **Phase 4 (Cleanup):** Mechanical removal of dead code and files. No research needed.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All three tools tested/verified on installed versions. Zsh glob qualifiers stable since zsh 4.x. Fish and mise conf.d are native features. |
| Features | HIGH | Feature set is well-scoped. Clear separation of table stakes vs differentiators. Anti-features are well-reasoned. |
| Architecture | HIGH | Component boundaries are clean. Stow --no-folding already in use. Migration path is incremental and reversible per phase. |
| Pitfalls | HIGH | 13 pitfalls identified with concrete prevention strategies. Phase-specific warnings mapped. Most pitfalls are well-understood Unix/Stow patterns. |

**Overall confidence:** HIGH

### Gaps to Address

- **Fisher conf.d state:** Need to check what Fisher currently places in `~/.config/fish/conf.d/` on deployed machines before creating stow-managed files there. Run `ls ~/.config/fish/conf.d/` during Phase 2 planning.
- **Mise conf.d merge semantics:** Verified that mise recognizes conf.d files, but the exact merge behavior (which setting wins when main config.toml and conf.d disagree) should be validated during Phase 3 implementation.
- **Stow unstow cleanup:** The exact steps to cleanly remove the merged stow module need validation. Whether `stow -D merged` handles it or manual cleanup is required.

## Sources

### Primary (HIGH confidence)
- Zsh glob qualifiers: `man zshexpn` (installed locally, zsh 5.9)
- Fish shell conf.d: [fishshell.com/docs/current](https://fishshell.com/docs/current/)
- Mise configuration: [mise.jdx.dev/configuration](https://mise.jdx.dev/configuration.html)
- GNU Stow manual: [gnu.org/software/stow/manual](https://www.gnu.org/software/stow/manual/stow.html)
- ansible-role-dotmodules source: `~/.ansible/roles/ansible-role-dotmodules/` (read directly)

### Secondary (MEDIUM confidence)
- Mise conf.d behavior: [deepwiki.com/jdx/mise](https://deepwiki.com/jdx/mise/3.2-configuration-system)
- Fish conf.d ordering: [fish-shell/fish-shell#8553](https://github.com/fish-shell/fish-shell/issues/8553)
- Community dotfiles patterns: [z0rc/dotfiles](https://github.com/z0rc/dotfiles), [mattmc3/zdotdir](https://github.com/mattmc3/zdotdir), [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles)

### Tertiary (LOW confidence)
- Zsh startup optimization benchmarks: [coderlegion.com](https://coderlegion.com/11431/from-1-4s-to-53ms-optimizing-zsh-startup-on-macos) (useful for context, not directly applicable)

---
*Research completed: 2026-03-10*
*Ready for roadmap: yes*
