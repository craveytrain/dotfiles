# Milestones

## v1.1 Runtime Includes (Shipped: 2026-03-11)

**Phases:** 4-7 (4 phases, 8 plans)
**Commits:** 42 | **Files:** 82 | **Lines:** +5,974 / -3,210
**Timeline:** 2 days (2026-03-10 → 2026-03-11)

**Key accomplishments:**
- Zsh conf.d migration: .zshrc sources ~/.zsh/conf.d/*.sh fragments at runtime instead of Ansible-merged files
- Fish conf.d migration: modules use native ~/.config/fish/conf.d/ mechanism; mux extracted to autoload function
- Mise conf.d migration: standalone TOML fragments with trust bootstrapping replace shared config.toml
- Merge infrastructure removal: mergeable_files purged from all module configs
- Documentation: README and CODING_STANDARDS updated with conf.d convention, prefix ranges, and module example

### Known Gaps

- **SHRC-04** (Deferred): Zsh debug mode (DOTFILES_DEBUG=1) incompatible with p10k instant prompt
- **Verification gaps**: Phases 04 and 05 missing VERIFICATION.md files (6 requirements lack formal 3-source verification, but integration checker confirmed all working)

---

