# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.1 — Runtime Includes

**Shipped:** 2026-03-11
**Phases:** 4 | **Plans:** 8 | **Commits:** 42

### What Was Built
- Runtime conf.d sourcing for zsh, fish, and mise (replacing Ansible-time merge)
- Module-owned numbered fragments with attribution headers
- Merge infrastructure removal from ansible-role-dotmodules
- conf.d ordering convention documented in CODING_STANDARDS.md

### What Worked
- Phased migration (one shell at a time) kept each phase small and verifiable
- Fish native conf.d mechanism required zero custom sourcing logic
- Mise conf.d fragments eliminated the awkward shared `[tools]` header problem
- Tens-based prefix grouping (10/50/80) was intuitive and scaled well across shells
- Phase 6 (mise) was the fastest, 4 minutes total, pattern was well-established by then

### What Was Inefficient
- Phase 4 deployment (04-02) took 112 minutes due to debugging p10k instant prompt conflict with DOTFILES_DEBUG
- SHRC-04 (debug mode) was planned, implemented, then had to be deferred, wasted effort
- Phases 04 and 05 skipped VERIFICATION.md, creating audit gaps that required explanation later

### Patterns Established
- conf.d fragment convention: `NN-module-description.ext` with attribution headers
- Prefix ranges: 10-19 core, 50-69 features, 80-99 late-loading integrations
- Each module owns its own fragments, no shared merge targets
- Fish functions get attribution header comments

### Key Lessons
1. Test early for conflicts with existing tooling (p10k) before committing to a feature (DOTFILES_DEBUG)
2. Write VERIFICATION.md as part of execution, not as an afterthought; missing verification creates audit noise
3. Once a pattern is established (phase 4), subsequent phases (5, 6) execute dramatically faster

### Cost Observations
- Timeline: 2 days for 4 phases
- Phase execution accelerated as pattern solidified (112min -> 17min -> 4min -> 5min)
- Notable: research and planning dominated calendar time; actual code changes were fast

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Commits | Phases | Key Change |
|-----------|---------|--------|------------|
| v1.0 | ~20 | 3 | Initial GSD workflow adoption |
| v1.1 | 42 | 4 | Established repeatable migration pattern across shells |

### Top Lessons (Verified Across Milestones)

1. Small, focused phases with clear success criteria execute cleanly
2. Pattern reuse across phases compounds efficiency gains
