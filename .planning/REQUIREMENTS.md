# Requirements: Dotfiles v1.1 Runtime Includes

**Defined:** 2026-03-10
**Core Value:** Muscle memory consistency. Config edits go live on git pull without redeploying.

## v1.1 Requirements

### Shell Sourcing

- [x] **SHRC-01**: Zsh sources all files in `~/.zsh/conf.d/*.sh` via glob loop with `(N)` qualifier
- [ ] **SHRC-02**: Fish sources module contributions via native `~/.config/fish/conf.d/*.fish` mechanism
- [x] **SHRC-03**: All conf.d directories use numeric prefix ordering convention (00-99, 2-digit)
- [ ] **SHRC-04**: ~~Zsh sourcing loop supports debug mode via `DOTFILES_DEBUG=1` environment variable~~ DEFERRED: p10k instant prompt intercepts all console output during shell init

### Module Migration

- [ ] **MIGR-01**: All mergeable_files declarations removed from every module's config.yml
- [x] **MIGR-02**: Each module stows its own numbered conf.d fragment files (no shared merge targets)
- [x] **MIGR-03**: Each conf.d fragment file has attribution comment header identifying owning module
- [x] **MIGR-04**: EDITOR/VISUAL environment variables owned exclusively by editor module (no duplication)

### Tool Configuration

- [ ] **TOOL-01**: Mise loads tool versions from `~/.config/mise/conf.d/*.toml` with standalone TOML headers
- [ ] **TOOL-02**: Mise trusted_config_paths configured for conf.d directory (no per-file trust prompts)

### Cleanup

- [ ] **CLNP-01**: Merge logic (merge_files.yml, merged_file.j2, conflict_resolution.yml) removed from ansible-role-dotmodules
- [ ] **CLNP-02**: Stale symlinks and files in `~/.dotmodules/merged/` cleaned up during deployment
- [ ] **CLNP-03**: Ordering convention documented with numeric prefix ranges and module assignment guide

## Future Requirements

### Ongoing Discovery
- **DISC-01**: Continue home directory audit for additional config files to modularize
- **DISC-02**: Evaluate conf.d pattern for non-shell config files as new modules are added

## Out of Scope

| Feature | Reason |
|---------|--------|
| Error isolation per fragment | Let errors surface loudly; suppressing masks real issues |
| Automated migration tooling | Manual restructure is fine for 6 modules |
| Fragment dependency resolution | Numeric prefixes are sufficient at this scale |
| Sub-directory nesting in conf.d | Flat structure is better for ~5 files per directory |
| Per-command performance optimization | Conf.d cost is shell-startup only (~2ms), not per-command |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SHRC-01 | Phase 4 | Complete |
| SHRC-02 | Phase 5 | Pending |
| SHRC-03 | Phase 4 | Complete |
| SHRC-04 | Phase 4 | Deferred (p10k conflict) |
| MIGR-01 | Phase 7 | Pending |
| MIGR-02 | Phase 4 | Complete |
| MIGR-03 | Phase 4 | Complete |
| MIGR-04 | Phase 4 | Complete |
| TOOL-01 | Phase 6 | Pending |
| TOOL-02 | Phase 6 | Pending |
| CLNP-01 | Phase 7 | Pending |
| CLNP-02 | Phase 7 | Pending |
| CLNP-03 | Phase 7 | Pending |

**Coverage:**
- v1.1 requirements: 13 total
- Mapped to phases: 13
- Unmapped: 0

---
*Requirements defined: 2026-03-10*
*Last updated: 2026-03-10 after roadmap creation*
