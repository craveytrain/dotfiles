---
phase: 4
slug: zsh-conf-d-migration
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-10
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual shell testing (no automated test framework in project) |
| **Config file** | none |
| **Quick run command** | `zsh -l -c 'echo ok'` |
| **Full suite command** | `DOTFILES_DEBUG=1 zsh -l -c 'echo ok'` |
| **Estimated runtime** | ~2 seconds |

---

## Sampling Rate

- **After every task commit:** Run `zsh -l -c 'echo ok'`
- **After every plan wave:** Run `DOTFILES_DEBUG=1 zsh -l -c 'echo ok'`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 2 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-xx | 01 | 1 | SHRC-01 | smoke | `zsh -l -c 'echo ok'` | N/A | ⬜ pending |
| 04-01-xx | 01 | 1 | SHRC-04 | smoke | `DOTFILES_DEBUG=1 zsh -l -c '' 2>&1 \| grep sourcing` | N/A | ⬜ pending |
| 04-01-xx | 01 | 1 | SHRC-03 | manual | `ls ~/.zsh/conf.d/` | N/A | ⬜ pending |
| 04-02-xx | 02 | 1 | MIGR-02 | manual | `ls -la ~/.zsh/conf.d/` | N/A | ⬜ pending |
| 04-02-xx | 02 | 1 | MIGR-03 | manual | `head -2 ~/.zsh/conf.d/*.sh` | N/A | ⬜ pending |
| 04-02-xx | 02 | 1 | MIGR-04 | manual | `grep -l 'export EDITOR\|export VISUAL' ~/.zsh/conf.d/` | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*Existing infrastructure covers all phase requirements.*

No test framework to install. This phase uses manual shell testing against a live zsh session.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Numeric prefix ordering | SHRC-03 | Convention check, not runtime behavior | `ls ~/.zsh/conf.d/` — verify 2-digit prefixes |
| Symlinks from multiple modules | MIGR-02 | Filesystem structure check | `ls -la ~/.zsh/conf.d/` — verify symlinks point to different module dirs |
| Attribution headers present | MIGR-03 | File content convention | `head -2 ~/.zsh/conf.d/*.sh` — verify module attribution comments |
| EDITOR/VISUAL only in editor | MIGR-04 | Cross-module uniqueness check | `grep -l 'export EDITOR\|export VISUAL' ~/.zsh/conf.d/` — should return only editor fragment |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
