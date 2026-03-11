---
phase: 6
slug: mise-conf-d-migration
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-11
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual verification via mise CLI |
| **Config file** | none — uses mise built-in commands |
| **Quick run command** | `mise config ls && mise ls` |
| **Full suite command** | `mise config ls && mise ls && mise settings ls` |
| **Estimated runtime** | ~3 seconds |

---

## Sampling Rate

- **After every task commit:** Run `mise config ls && mise ls`
- **After every plan wave:** Run `mise config ls && mise ls && mise settings ls`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 3 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 06-01-01 | 01 | 1 | TOOL-01 | smoke | `mise config ls --json \| python3 -c "import sys,json; configs=json.load(sys.stdin); assert any('conf.d' in c['path'] for c in configs)"` | N/A (CLI) | ⬜ pending |
| 06-01-02 | 01 | 1 | TOOL-01 | smoke | `mise ls --json \| python3 -c "import sys,json; tools=json.load(sys.stdin); assert 'python' in tools and 'node' in tools"` | N/A (CLI) | ⬜ pending |
| 06-01-03 | 01 | 1 | TOOL-02 | manual-only | Run `mise ls` in new shell, verify no prompt | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*Existing infrastructure covers all phase requirements.* Verification uses mise's built-in CLI commands, no test infrastructure needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| No trust prompt for conf.d files | TOOL-02 | Trust prompts are interactive and environment-dependent | Run `mise ls` in a new shell session, verify no trust prompt appears |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 3s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
