# Phase 6: Mise conf.d Migration - Context

**Gathered:** 2026-03-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Replace Ansible-merged mise config.toml with individual module-owned TOML files loaded via mise's native includes mechanism. Each module stows its own conf.d fragment. Edits go live on `git pull` without Ansible redeploy. Two modules currently contribute to the merged config.toml: dev-tools (settings + python) and node (node + pnpm).

</domain>

<decisions>
## Implementation Decisions

### Includes mechanism
- Use glob pattern (`conf.d/*.toml`) so new modules are auto-discovered without editing the main config
- dev-tools module owns the main config.toml (it already installs mise via Homebrew and provides shell activation)
- Conf.d directory path: `~/.config/mise/conf.d/` per requirement spec, unless mise conventions suggest otherwise

### Main config.toml role
- Claude decides whether a skeleton config.toml is needed (with includes directive) or if mise can load from a directory natively
- If a skeleton is needed, it lives in the dev-tools module alongside the existing mise activation conf.d fragments

### Settings placement
- `[settings]` block (asdf_compat=true) goes in the dev-tools conf.d fragment, not a separate file or main config
- Keep asdf_compat=true — some projects still use .tool-versions files
- Just asdf_compat for now; more settings can be added later

### Fragment naming
- No numeric prefixes — ordering doesn't matter for mise tool definitions (unlike zsh/fish where load order matters)
- Simple module-name format: `dev-tools.toml`, `node.toml`
- Attribution comment headers (consistent with Phase 4/5 convention)

### Fragment ownership
- Current grouping stays: dev-tools fragment has settings + python, node fragment has node + pnpm
- Future language-specific tools get their own module's conf.d fragment (e.g., a ruby module would add `ruby.toml`)
- General-purpose tools stay in dev-tools fragment

### Fragment format
- Each conf.d file is a valid standalone TOML document with its own section headers (`[tools]`, `[settings]`)
- No more merge-artifact restrictions (node module can now have its own `[tools]` header)

### Claude's Discretion
- Whether mise supports glob includes natively or needs explicit file listing (research this)
- Skeleton config.toml content and structure (if needed)
- Whether per-fragment `[settings]` sections are supported or if settings must be centralized
- Trust configuration approach for conf.d directory (TOOL-02 requirement)
- Exact conf.d directory path if mise conventions differ from `~/.config/mise/conf.d/`

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `modules/dev-tools/files/.config/mise/config.toml` (17 lines): `[settings]` (asdf_compat) + `[tools]` (python 3.13.2) — to be split into conf.d fragment
- `modules/node/files/.config/mise/config.toml` (17 lines): bare `node = "latest"` + `pnpm = "latest"` (no `[tools]` header — merge artifact) — to become standalone TOML
- `modules/dev-tools/files/.zsh/conf.d/80-dev-tools-mise.sh`: mise zsh activation (already migrated in Phase 4)
- `modules/dev-tools/files/.config/fish/conf.d/80-dev-tools-mise.fish`: mise fish activation (already migrated in Phase 5)

### Established Patterns
- Module structure: `modules/{name}/files/` contains stowable files, `config.yml` declares metadata
- `mergeable_files` in config.yml lists files that get merged (both dev-tools and node declare `.config/mise/config.toml`)
- GNU Stow symlinks from multiple modules into the same target directory
- Phase 4/5 convention: attribution comment headers, one fragment per module

### Integration Points
- `modules/dev-tools/config.yml` has `mergeable_files: '.config/mise/config.toml'` — removal is Phase 7
- `modules/node/config.yml` has `mergeable_files: '.config/mise/config.toml'` — removal is Phase 7
- New conf.d fragments go in `modules/{name}/files/.config/mise/conf.d/{name}.toml`
- Stow symlinks conf.d contents from multiple modules into `~/.config/mise/conf.d/`
- trusted_config_paths must cover conf.d directory to satisfy TOOL-02

</code_context>

<specifics>
## Specific Ideas

- Numeric prefixes deliberately dropped for mise conf.d — reflects that tool definitions have no ordering dependencies (unlike shell config where env vars must load before aliases)
- The node module's current lack of `[tools]` header is explicitly called out as a merge artifact that should be fixed in the standalone version
- Pattern for future modules: language-specific tools in their own module, general tools centralized in dev-tools

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 06-mise-conf-d-migration*
*Context gathered: 2026-03-11*
