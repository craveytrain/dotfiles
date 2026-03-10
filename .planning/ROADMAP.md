# Roadmap

**Project:** Dotfiles Configuration Management
**Created:** 2026-01-23
**Strategy:** Continuous improvement, no version numbers

---

## Milestones

- **v1.0 Foundation** - Phases 1-3 (shipped 2026-01-24)
- **v1.1 Runtime Includes** - Phases 4-7 (in progress)

## Phases

<details>
<summary>v1.0 Foundation (Phases 1-3) - SHIPPED 2026-01-24</summary>

## Phase 1: Foundation & Ghostty Module

**Goal:** Fix existing tech debt and validate module creation pattern with simplest possible implementation.

**Plans:** 4 plans (3 waves)

Plans:
- [x] 01-01-PLAN.md - SpecKit cleanup (Wave 1)
- [x] 01-02-PLAN.md - Remove duplicate 1password entry from deploy.yml (Wave 1)
- [x] 01-03-PLAN.md - Create Ghostty module structure (Wave 2)
- [x] 01-04-PLAN.md - Deploy and verify Ghostty module (Wave 3, checkpoint)

**Success Criteria:**
- Duplicate 1password entry removed from deploy.yml
- Ghostty terminal configuration deployed via ansible-role-dotmodules
- Ghostty config synchronized across machines
- SpecKit artifacts cleaned up

**Status:** COMPLETE

---

## Phase 2: Claude CLI Module

**Goal:** Synchronize Claude Code CLI configuration across machines.

**Plans:** 2 plans (2 waves)

Plans:
- [x] 02-01-PLAN.md - Create Claude module structure and populate files (Wave 1)
- [x] 02-02-PLAN.md - Deploy and verify Claude module (Wave 2, checkpoint)

**Success Criteria:**
- Claude CLI configuration synchronized across machines
- Custom statusline hook available on all machines
- Authentication documented in module README

**Status:** COMPLETE

---

## Phase 3: Ongoing Config Discovery

**Goal:** Continuous discovery and addition of configuration modules as needed.

**Status:** Continuous

</details>

### v1.1 Runtime Includes (In Progress)

**Milestone Goal:** Eliminate Ansible-merged files so config edits are live immediately on git pull without redeploying. Each module stows its own conf.d fragment instead of contributing to a merged output.

- [x] **Phase 4: Zsh conf.d Migration** - Replace Ansible-merged zsh config files with runtime conf.d sourcing (completed 2026-03-10)
- [ ] **Phase 5: Fish conf.d Migration** - Migrate fish module contributions to native conf.d mechanism
- [ ] **Phase 6: Mise conf.d Migration** - Replace merged mise config with native conf.d includes
- [ ] **Phase 7: Cleanup and Documentation** - Remove dead merge logic, clean stale files, document conventions

## Phase Details

### Phase 4: Zsh conf.d Migration
**Goal**: Zsh configuration loads from individual module-owned conf.d fragments at runtime instead of Ansible-merged files
**Depends on**: Phase 3 (v1.0 complete)
**Requirements**: SHRC-01, SHRC-03, SHRC-04, MIGR-02, MIGR-03, MIGR-04
**Success Criteria** (what must be TRUE):
  1. Opening a new zsh session sources all conf.d fragments from `~/.zsh/conf.d/` without errors
  2. Editing a conf.d fragment in the repo and running `git pull` makes the change live in the next shell session (no Ansible redeploy needed)
  3. Setting `DOTFILES_DEBUG=1` before opening a shell prints which conf.d files are being sourced
  4. EDITOR and VISUAL environment variables are set by the editor module only, with no duplicate definitions across modules
  5. All conf.d files use 2-digit numeric prefixes and contain attribution comment headers identifying their owning module
**Plans**: 2 plans (2 waves)

Plans:
- [x] 04-01-PLAN.md - Create conf.d fragments and rewrite .zshrc skeleton (Wave 1)
- [x] 04-02-PLAN.md - Deploy via Ansible and verify live zsh session (Wave 2, checkpoint)

### Phase 5: Fish conf.d Migration
**Goal**: Fish module contributions load via the native conf.d mechanism instead of Ansible-merged config.fish
**Depends on**: Phase 4
**Requirements**: SHRC-02
**Success Criteria** (what must be TRUE):
  1. Opening a new fish session picks up all module contributions from `~/.config/fish/conf.d/` without errors
  2. Fish conf.d fragments use the same numeric prefix convention and attribution headers established in Phase 4
  3. Editing a fish conf.d fragment in the repo and running `git pull` makes the change live in the next fish session
**Plans**: TBD

Plans:
- [ ] 05-01: TBD

### Phase 6: Mise conf.d Migration
**Goal**: Mise loads tool versions and settings from individual conf.d TOML files instead of a single merged config
**Depends on**: Phase 4
**Requirements**: TOOL-01, TOOL-02
**Success Criteria** (what must be TRUE):
  1. Running `mise ls` shows tool versions loaded from conf.d fragment files in `~/.config/mise/conf.d/`
  2. Adding a new tool version file to the conf.d directory does not trigger a trust prompt (trusted_config_paths configured)
  3. Each conf.d TOML file is a valid standalone TOML document with its own section headers
**Plans**: TBD

Plans:
- [ ] 06-01: TBD

### Phase 7: Cleanup and Documentation
**Goal**: All merge infrastructure is removed and the conf.d convention is documented for future module authors
**Depends on**: Phase 4, Phase 5, Phase 6
**Requirements**: MIGR-01, CLNP-01, CLNP-02, CLNP-03
**Success Criteria** (what must be TRUE):
  1. No module config.yml contains a `mergeable_files` declaration (grep returns zero matches)
  2. The merge_files.yml, merged_file.j2, and conflict_resolution.yml files are removed from ansible-role-dotmodules
  3. Running the Ansible playbook cleans up any stale files in `~/.dotmodules/merged/` and leaves no broken symlinks
  4. A documented ordering convention explains numeric prefix ranges and how new modules should contribute conf.d fragments
**Plans**: TBD

Plans:
- [ ] 07-01: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 4 -> 5 -> 6 -> 7
(Phases 5 and 6 have no dependency on each other, only on Phase 4)

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Foundation & Ghostty | v1.0 | 4/4 | Complete | 2026-01-23 |
| 2. Claude CLI Module | v1.0 | 2/2 | Complete | 2026-01-24 |
| 3. Ongoing Discovery | v1.0 | - | Continuous | - |
| 4. Zsh conf.d Migration | v1.1 | 2/2 | Complete | 2026-03-10 |
| 5. Fish conf.d Migration | v1.1 | 0/? | Not started | - |
| 6. Mise conf.d Migration | v1.1 | 0/? | Not started | - |
| 7. Cleanup and Documentation | v1.1 | 0/? | Not started | - |

---

*Roadmap created: 2026-01-23*
*Last updated: 2026-03-10 - Phase 4 complete (2/2 plans, SHRC-04 deferred)*
