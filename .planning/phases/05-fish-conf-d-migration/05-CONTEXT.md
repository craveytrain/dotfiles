# Phase 5: Fish conf.d Migration - Context

**Gathered:** 2026-03-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Migrate fish module contributions from Ansible-merged `config.fish` to fish's native `~/.config/fish/conf.d/` mechanism. Each module stows its own numbered conf.d fragment. Edits go live on `git pull` without Ansible redeploy. Four modules currently contribute to the merged config.fish: fish, editor, shell, dev-tools.

</domain>

<decisions>
## Implementation Decisions

### config.fish skeleton
- config.fish becomes minimal — only the `config.local.fish` source line (machine-specific escape hatch, not a module contribution)
- All module content moves to conf.d fragments
- config.local.fish stays in config.fish, not in conf.d (same reasoning as .zshrc.local in Phase 4)
- Claude decides what else, if anything, needs to stay in config.fish to keep things working

### Interactive guards
- Split by need: env vars get no guard (available in all fish sessions), abbrs/prompt/functions get `if status --is-interactive` guard
- Each fragment is responsible for its own guards where needed (no global guard in config.fish)

### Fisher coexistence
- Naming separation is sufficient — module fragments use `NN-module-desc.fish` prefix convention, Fisher uses underscored/plugin names (e.g., `_tide_init.fish`). No collision risk.
- Fisher stays completely independent — it manages its own conf.d files, we don't touch them
- `fish_plugins` manifest file stays stowed as-is by the fish module (Fisher concern, not conf.d concern)

### Functions directory
- Existing function files in `functions/` stay as-is — they follow fish's native autoload convention (lazy-loaded on first call)
- Inline `mux` function from config.fish moves to its own `functions/mux.fish` file for consistency
- Any module can contribute function files to `~/.config/fish/functions/` (not restricted to fish module)
- All function files get attribution comment headers identifying owning module (consistency with conf.d convention)

### Fragment content mapping
- One conf.d fragment per module, same as Phase 4 zsh convention (4 fragments total)
- Fish module fragment: env vars, abbrs, tide prompt config (all content from current monolith except mux function and local override)
- Editor module fragment: `ia` and `marked` abbrs
- Shell module fragment: EZA_COLORS env var
- Dev-tools module fragment: mise activate for fish
- Tide prompt config (`tide_left_prompt_items`, `tide_right_prompt_items`) moves to the fish conf.d fragment — no technical reason to keep in config.fish, and it gets the git-pull-goes-live benefit

### Claude's Discretion
- Exact numeric prefix assignments for each module's fragment
- What minimal content (if any) stays in config.fish beyond config.local.fish source
- Mise activate guard: research what mise recommends for fish (login vs interactive vs no guard)
- Fragment file naming details (brief description suffix)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `modules/fish/files/.config/fish/config.fish` (58 lines): Monolith with env, abbrs, mux function, tide prompt config — all moves to conf.d
- `modules/fish/files/.config/fish/functions/` (10 files): Autoloaded fish functions — stay as-is
- `modules/fish/files/.config/fish/fish_plugins`: Fisher plugin manifest (fisher, tide) — stays as-is
- `modules/editor/files/.config/fish/config.fish` (2 lines): `ia` and `marked` abbrs
- `modules/shell/files/.config/fish/config.fish` (5 lines): EZA_COLORS env var
- `modules/dev-tools/files/.config/fish/config.fish` (3 lines): mise activate with login guard

### Established Patterns
- Phase 4 zsh conf.d: `NN-module-description.sh` naming, shellcheck directive + attribution header, one file per module
- Fish native conf.d: auto-sources all `.fish` files in `~/.config/fish/conf.d/` — no glob loop needed
- Fish functions: one function per file in `functions/`, autoloaded on first call
- Module structure: `modules/{name}/files/` contains stowable files, `config.yml` declares metadata
- GNU Stow symlinks from multiple modules into the same target directory

### Integration Points
- Each module's `config.yml` has `mergeable_files` entries for `config.fish` — removal is Phase 7, not this phase
- New conf.d fragments go in `modules/{name}/files/.config/fish/conf.d/{NN}-{name}-{desc}.fish`
- Stow symlinks conf.d contents from multiple modules into `~/.config/fish/conf.d/`
- Fisher-managed conf.d files coexist in the same directory (no conflicts due to naming convention)
- 4 modules contribute: fish, editor, shell, dev-tools

</code_context>

<specifics>
## Specific Ideas

- Tide prompt config has no ordering constraints (unlike p10k which has hard requirements for instant prompt at top and config source at bottom) — this is why it can safely move to conf.d
- The interactive guard split mirrors how fish itself works: env vars are universal, interactive features are session-specific
- Attribution headers on function files is a new convention not established in Phase 4 (zsh didn't have autoloaded function files)

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-fish-conf-d-migration*
*Context gathered: 2026-03-10*
