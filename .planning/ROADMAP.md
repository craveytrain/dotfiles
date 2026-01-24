# Roadmap

**Project:** Dotfiles Configuration Management
**Created:** 2026-01-23
**Strategy:** Continuous improvement, no version numbers

---

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

**Deliverables:**
- Fixed playbooks/deploy.yml (remove duplicate)
- modules/ghostty/ with config.yml, files/, README.md
- Ghostty config in .config/ghostty/config

**Complexity:** Low (config-only module, no dependencies)

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

**Deliverables:**
- modules/claude/ with config.yml, files/, README.md
- Claude config in ~/.claude/ (settings.json, statusline.js)
- Post-deployment authentication instructions

**Complexity:** Low (settings + single hook)

**Research:** Complete (02-RESEARCH.md)

**Status:** COMPLETE

**Note:** Scope reduced from original plan - only syncing settings.json and statusline.js hook. Agents, commands, and GSD framework managed locally per machine.

---

## Phase 3: Ongoing Config Discovery

**Goal:** Continuous discovery and addition of configuration modules as needed.

**Success Criteria:**
- Home directory audit identifies additional config files
- New modules added based on muscle memory consistency needs
- Module quality maintained (constitutional principles followed)

**Deliverables:**
- Additional modules as discovered
- Updated deploy.yml with new modules
- Documentation for each new tool

**Complexity:** Variable (depends on tool complexity)

**Approach:** Continuous, not time-boxed

---

## Dependencies

**Phase 1 → Phase 2:**
- Phase 1 validates module creation pattern before adding complexity

**Phase 2 → Phase 3:**
- Phase 2 completes initial planned work, Phase 3 is ongoing discovery

---

## Out of Scope

- Full machine provisioning (focus: configuration management)
- Mac App Store applications (nerfed versions)
- Universal software installation (selective, case-by-case)
- Windows/Linux support (macOS Apple Silicon only)
- Version numbers or formal releases (continuous improvement)
- Shell integration testing module (defer until needed)
- Clean system validation phase (defer until problems arise)

---

*Roadmap created: 2026-01-23*
*Aligned with PROJECT.md active requirements*
