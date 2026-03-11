# Phase 4: Zsh conf.d Migration - Context

**Gathered:** 2026-03-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Replace Ansible-merged zsh config files (`.zshrc`, `.zsh/aliases.sh`, `.zsh/environment.sh`) with runtime `conf.d` sourcing. Each module stows its own numbered fragment file into `~/.zsh/conf.d/`. Edits go live on `git pull` without Ansible redeploy.

</domain>

<decisions>
## Implementation Decisions

### Fragment file granularity
- One conf.d file per module (not split by concern like aliases vs env)
- The current split into `aliases.sh` / `environment.sh` was an artifact of the merge system and does not carry forward
- Even the zsh module (the largest contributor) gets a single conf.d file combining its environment, aliases, functions, and utility content

### File format and headers
- No shebang line (files are sourced, not executed)
- Attribution comment header identifying the owning module
- shellcheck directive comment (`# shellcheck shell=zsh`) at the top of each fragment
- Example header:
  ```sh
  # shellcheck shell=zsh
  # editor module - EDITOR/VISUAL exports and aliases
  ```

### Naming convention
- Format: `{NN}-{module}-{brief-description}.sh`
- Module name + brief description of what the fragment contributes
- Examples: `50-editor-env-aliases.sh`, `10-zsh-environment.sh`

### What moves to conf.d
- All content from currently merged files: environment vars, aliases, functions, utility
- `functions.sh` and `utility.zsh` (currently direct source lines in .zshrc) also move into conf.d for full consistency
- Everything goes through the glob loop

### What stays in .zshrc (skeleton)
- p10k instant prompt (must be near top of file)
- The conf.d glob loop with DOTFILES_DEBUG support
- `.zshrc.local` source line (local escape hatch, not a module)
- `compinit` (must be before autosuggestions)
- zsh-autosuggestions (must be after compinit)
- powerlevel10k theme + p10k config
- zsh-syntax-highlighting (must be last)
- .zshrc becomes a ~15-line skeleton with the conf.d loop in the middle

### Local overrides
- `.zshrc.local` stays as a direct source line in .zshrc, not in conf.d
- It's a machine-specific escape hatch, not a module contribution
- Positioned after conf.d loop but before compinit (same as current placement)

### .env loading
- The conditional `.env` source stays inside the zsh module's conf.d fragment (where it currently lives in environment.sh)
- Not moved to .zshrc alongside .zshrc.local

### Claude's Discretion
- Numeric prefix assignment scheme (tens-based, grouped ranges, etc.)
- Exact prefix numbers for each module
- DOTFILES_DEBUG implementation (per-file output in loop vs summary after loop)
- How to handle the transition from merged files to conf.d files during migration

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `modules/zsh/files/.zsh/environment.sh` (84 lines): Platform detection, Nerd Font, PAGER, colors, CDPATH, .env loading
- `modules/zsh/files/.zsh/aliases.sh` (43 lines): ip, catn, pubkey, dot, e, mkdir, eza aliases, grep
- `modules/zsh/files/.zsh/functions.sh`: Zsh functions (to be migrated to conf.d)
- `modules/zsh/files/.zsh/utility.zsh`: Zsh utility config (to be migrated to conf.d)
- `modules/editor/files/.zsh/environment.sh` (11 lines): EDITOR/VISUAL exports
- `modules/editor/files/.zsh/aliases.sh` (1 line): `e` alias
- `modules/shell/files/.zsh/environment.sh` (4 lines): EZA_COLORS
- `modules/dev-tools/files/.zshrc` (2 lines): `eval "$(mise activate zsh)"`

### Established Patterns
- Module structure: `modules/{name}/files/` contains stowable files, `config.yml` declares metadata
- `stow_dirs` in config.yml tells ansible-role-dotmodules which directories to stow
- `mergeable_files` in config.yml lists files that get merged (to be replaced by conf.d)
- GNU Stow creates symlinks from module files to home directory

### Integration Points
- Each module's `config.yml` needs `mergeable_files` entries removed (Phase 7, not this phase)
- New conf.d fragment files go in `modules/{name}/files/.zsh/conf.d/{NN}-{name}-{desc}.sh`
- Stow will symlink `~/.zsh/conf.d/` contents from multiple modules into the same directory
- `.zshrc` in the zsh module needs rewriting to the skeleton pattern
- 4 modules contribute to zsh merged files: zsh, editor, shell, dev-tools

</code_context>

<specifics>
## Specific Ideas

- The current `aliases.sh` / `environment.sh` split was called out as an artifact of the merge system, not a meaningful organizational choice
- User wants full consistency: if it's sourced config, it goes through conf.d. No exceptions for functions.sh or utility.zsh.
- The .zshrc should feel like a "skeleton" or "frame" with the conf.d loop slotted into the middle between fixed-order plugin loading

</specifics>

<deferred>
## Deferred Ideas

None -- discussion stayed within phase scope

</deferred>

---

*Phase: 04-zsh-conf-d-migration*
*Context gathered: 2026-03-10*
