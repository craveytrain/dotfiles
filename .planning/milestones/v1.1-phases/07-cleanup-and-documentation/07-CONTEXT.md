# Phase 7: Cleanup and Documentation - Context

**Gathered:** 2026-03-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Remove all merge infrastructure (mergeable_files declarations, role merge logic files) and document the conf.d convention for future module authors. This is the final phase of the v1.1 Runtime Includes milestone. No new features, just cleanup and documentation.

</domain>

<decisions>
## Implementation Decisions

### Convention documentation
- Both README.md and CODING_STANDARDS.md get updated
- README.md: update Module Structure section to show conf.d, update "Add a New Module" instructions, remove mergeable_files from config.yml example, update "How It Works" to remove merge/conflict references
- CODING_STANDARDS.md: full conf.d walkthrough including prefix range table, fragment header format, naming pattern, per-shell differences (zsh needs shellcheck directive, fish uses native conf.d, mise has no numeric prefixes), and an end-to-end example of adding a new module with conf.d fragments

### Role cleanup
- Modify ansible-role-dotmodules directly (user's own repo at /Users/mcravey/Projects/ansible-role-dotmodules)
- Remove merge_files.yml, merged_file.j2, and conflict_resolution.yml from the role
- Commit and push changes to the role repo
- Update dotfiles requirements.yml to pin the new version (if the role uses versioning)
- Phase 7 handles both repos in the same execution

### Stale file cleanup
- No Ansible automation for merged directory cleanup (single-user repo)
- Delete ~/.dotmodules/merged/ as a one-off task on this machine (it's already empty)
- Verify no broken symlinks in ~/.zsh/, ~/.config/fish/, ~/.config/mise/ after changes

### mergeable_files removal
- Remove the mergeable_files key and its list from all 6 module config.yml files (editor, zsh, shell, fish, node, dev-tools)
- Verify no stale symlinks remain for old merge targets (aliases.sh, environment.sh, config.fish, config.toml)
- Old pre-conf.d source files are already deleted from earlier phases, so no file cleanup needed in modules/

### Claude's Discretion
- Ordering of tasks within the plan (what to do first: role cleanup, config.yml cleanup, or docs)
- Whether requirements.yml needs a version pin or just a fresh ansible-galaxy install
- Exact prefix range assignments to document (tens-based grouping, etc.)
- How to structure the end-to-end example in CODING_STANDARDS.md

</decisions>

<specifics>
## Specific Ideas

- The broken symlink verification should cover old merge targets specifically: ~/.zsh/aliases.sh, ~/.zsh/environment.sh, ~/.config/fish/config.fish (the old merged one, not the skeleton), ~/.config/mise/config.toml (the old merged one)
- The role repo is at /Users/mcravey/Projects/ansible-role-dotmodules — plan tasks can operate on it directly
- README.md currently shows mergeable_files in a config.yml example and mentions "Configuration Aggregation" and "Conflict Resolution" as features — both need updating

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `docs/policy/CODING_STANDARDS.md`: Existing standards doc with Module Structure Standards section — extend with conf.d conventions
- `README.md`: Comprehensive repo documentation with Module Structure, Add a New Module, and How It Works sections — update to reflect conf.d

### Established Patterns
- Phase 4 zsh conf.d: `NN-module-description.sh`, shellcheck directive + attribution header
- Phase 5 fish conf.d: `NN-module-description.fish`, attribution header, native conf.d auto-sourcing
- Phase 6 mise conf.d: `module-name.toml`, no numeric prefixes, standalone TOML with own headers
- All fragments: attribution comment header identifying owning module

### Integration Points
- 6 module config.yml files need mergeable_files removed: editor, zsh, shell, fish, node, dev-tools
- ansible-role-dotmodules (external repo): merge_files.yml, merged_file.j2, conflict_resolution.yml to be removed
- requirements.yml references the role repo

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 07-cleanup-and-documentation*
*Context gathered: 2026-03-11*
