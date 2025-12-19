# Research: Homebrew Shell Registration

**Feature**: 001-register-homebrew-shells  
**Date**: 2025-12-18  
**Status**: Complete

## Overview

This document captures research findings and technical decisions for automating Homebrew shell registration in `/etc/shells`. Research focused on Ansible patterns, idempotency strategies, and macOS system file handling.

## Research Questions & Findings

### 1. How to ensure idempotent file modifications in Ansible?

**Decision**: Use Ansible `lineinfile` module with `state: present`

**Rationale**:
- Built-in idempotency: Module checks if line exists before modifying file
- Atomic operations: File writes are atomic, preventing corruption
- Ansible-native: No custom shell scripts required
- Proven pattern: Standard approach in Ansible community

**Alternatives Considered**:

| Approach | Pros | Cons | Verdict |
|----------|------|------|---------|
| `lineinfile` module | Built-in idempotency, simple syntax | Limited to single-line operations | ✅ **Selected** |
| `blockinfile` module | Can manage multi-line blocks | Overkill for single lines, adds markers | ❌ Rejected |
| Shell script with `grep` | Maximum flexibility | Requires custom idempotency logic | ❌ Rejected |
| `template` module | Full file control | Would overwrite existing system entries | ❌ Rejected |

**References**:
- [Ansible lineinfile documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html)
- [Ansible Best Practices: Idempotency](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#idempotency)

**Implementation**:
```yaml
lineinfile:
  path: /etc/shells
  line: /opt/homebrew/bin/zsh
  state: present
```

---

### 2. How to conditionally execute tasks based on module selection?

**Decision**: Use `when` clause with Jinja2 list membership test

**Rationale**:
- Standard Ansible pattern for conditional execution
- Directly references existing `dotmodules.install` variable
- Readable and maintainable
- No additional variables or complexity

**Alternatives Considered**:

| Approach | Pros | Cons | Verdict |
|----------|------|------|---------|
| `when` with `in` operator | Simple, standard pattern | None significant | ✅ **Selected** |
| Ansible tags | Allows selective execution | Requires user to pass tags | ❌ Rejected |
| Separate playbooks | Complete isolation | Violates modularity principle | ❌ Rejected |
| Variable-driven loops | More flexible | Overkill for 2 shells | ❌ Rejected |

**Implementation**:
```yaml
when: "'zsh' in dotmodules.install"
```

**Testing**:
- Verified module name matching (exact string comparison)
- Tested with module enabled, disabled, and missing from list
- Confirmed tasks skip appropriately when conditions not met

---

### 3. How to handle privilege escalation for system file modification?

**Decision**: Use `become: yes` at task level

**Rationale**:
- Minimal privilege scope: Only shell registration tasks elevated
- Standard Ansible pattern for sudo/privilege escalation
- Single password prompt for entire playbook run
- More secure than elevating entire playbook

**Alternatives Considered**:

| Approach | Pros | Cons | Verdict |
|----------|------|------|---------|
| Task-level `become` | Minimal privilege scope | Slightly more verbose | ✅ **Selected** |
| Play-level `become` | Single declaration | Elevates all tasks unnecessarily | ❌ Rejected |
| Manual `sudo` wrapper | No Ansible dependency | Not automated, breaks idempotency | ❌ Rejected |
| Passwordless sudo | No prompts | Security risk, requires system config | ❌ Rejected |

**Security Considerations**:
- Only `/etc/shells` modification requires elevation
- Ansible role execution runs as regular user
- Password cached for duration of playbook run
- Standard macOS security practices maintained

**Implementation**:
```yaml
- name: Ensure Homebrew zsh is in /etc/shells
  become: yes
  lineinfile: [...]
```

---

### 4. How to handle different Homebrew installation paths?

**Decision**: Hardcode Apple Silicon path (`/opt/homebrew`), document Intel limitation

**Rationale**:
- 95%+ of new Macs use Apple Silicon
- Homebrew standardized on `/opt/homebrew` for ARM architecture
- Intel Macs use `/usr/local` (legacy, declining usage)
- Architecture detection adds complexity for minimal benefit
- Documented in spec assumptions

**Current Implementation**: Apple Silicon only (`/opt/homebrew/bin/*`)

**Future Enhancement Path**:
```yaml
# Potential multi-architecture support (not implemented)
vars:
  homebrew_prefix: "{{ '/opt/homebrew' if ansible_architecture == 'arm64' else '/usr/local' }}"
  
lineinfile:
  line: "{{ homebrew_prefix }}/bin/zsh"
```

**Trade-offs**:
- ✅ Simple implementation for majority use case
- ✅ Clear documentation of limitation
- ❌ Intel Mac users need manual adjustment
- ❌ No runtime detection

**References**:
- [Homebrew Installation Paths](https://docs.brew.sh/Installation)
- Homebrew changed default to `/opt/homebrew` in 2020 for Apple Silicon

---

## Best Practices Applied

### Ansible Idempotency Patterns

**Pattern**: Check-then-act (declarative state)
- Use modules that check current state before modification
- Prefer `state: present` over imperative commands
- Let Ansible report "ok" vs "changed" status

**Applied**:
```yaml
lineinfile:
  path: /etc/shells
  line: /opt/homebrew/bin/zsh
  state: present  # ← Declarative: "ensure this line exists"
```

**Not used** (imperative anti-pattern):
```yaml
shell: echo "/opt/homebrew/bin/zsh" >> /etc/shells  # ← Would create duplicates
```

---

### macOS System File Handling

**Best Practice**: Preserve existing content, append only
- `/etc/shells` managed by OS, contains system defaults
- User may have manual customizations
- Multiple tools may modify file (brew, ansible, manual edits)

**Applied**:
- `lineinfile` appends if missing, leaves existing lines untouched
- No use of `state: absent` (no automatic cleanup)
- File permissions preserved by Ansible

---

### Constitution Alignment

Every research decision validated against constitution principles:

| Principle | Research Alignment |
|-----------|-------------------|
| Modularity | Conditional tasks respect module selection |
| Idempotency | `lineinfile` inherently idempotent |
| Automation-First | No manual `/etc/shells` editing required |
| Cross-Platform | macOS-specific, documented |
| Configuration Merging | Appends to existing file |
| Documentation-First | Research before implementation |
| Version Control | YAML changes tracked in git |
| Declarative | Pure Ansible modules, no shell scripts |

---

## Technical Constraints Identified

### Hard Constraints
1. **Sudo required**: `/etc/shells` owned by root
2. **Ansible 2.9+**: Uses modern module syntax
3. **macOS only**: `/etc/shells` location and format
4. **Homebrew installed**: Assumes shell binaries exist

### Soft Constraints
1. **Apple Silicon path**: Intel Macs need manual adjustment
2. **Standard Homebrew location**: Custom installs unsupported
3. **Single-line entries**: One shell path per line (UNIX standard)

---

## Validation Strategy

### Idempotency Testing
```bash
# First run - should add entries
ansible-playbook -i playbooks/inventory playbooks/deploy.yml

# Second run - should report no changes
ansible-playbook -i playbooks/inventory playbooks/deploy.yml

# Verify file contents
cat /etc/shells | grep homebrew
```

**Expected Results**:
- Run 1: `changed=true` for shell tasks
- Run 2: `changed=false` (ok status)
- File contains exactly one entry per shell

### Functional Testing
```bash
# Verify shell registration
cat /etc/shells | grep -c homebrew  # Should output: 2

# Test shell switching
chsh -s /opt/homebrew/bin/fish       # Should succeed without error

# Verify active shell
echo $SHELL                           # Should show: /opt/homebrew/bin/fish
```

---

## Open Questions: None

All technical questions resolved during research phase. Implementation straightforward using standard Ansible patterns.

---

## References

**Ansible Documentation**:
- [lineinfile module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html)
- [Conditional execution (when)](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html)
- [Privilege escalation (become)](https://docs.ansible.com/ansible/latest/user_guide/become.html)

**macOS Documentation**:
- `/etc/shells` format: Standard UNIX (one absolute path per line)
- `chsh` command: Validates shell against `/etc/shells` entries

**Homebrew Documentation**:
- [Installation paths](https://docs.brew.sh/Installation)
- Apple Silicon: `/opt/homebrew`
- Intel: `/usr/local`

**Project References**:
- Constitution: `docs/policy/CONSTITUTION.md`
- Existing playbook: `playbooks/deploy.yml`
- ansible-role-dotmodules: External dependency
