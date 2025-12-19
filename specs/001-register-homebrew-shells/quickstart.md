# Quickstart: Homebrew Shell Registration

**Feature**: 001-register-homebrew-shells  
**Date**: 2025-12-18  
**Status**: Implemented

## What This Feature Does

Automatically registers Homebrew-installed shells (zsh, fish) in `/etc/shells` when you run the dotfiles playbook. This eliminates the manual step of editing system files before you can change your default shell.

**Before this feature**:
```bash
# Manual steps required
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

**After this feature**:
```bash
# Just run the playbook - shells registered automatically
ansible-playbook -i playbooks/inventory playbooks/deploy.yml
chsh -s /opt/homebrew/bin/fish  # Works immediately
```

---

## Prerequisites

- macOS (Apple Silicon or Intel)
- Homebrew installed
- Ansible 2.9+
- Sudo privileges (you'll be prompted for password)

---

## Usage

### First Time Setup

1. **Configure which shell modules to install**:

   Edit `playbooks/deploy.yml`:
   ```yaml
   dotmodules:
     install:
       - zsh    # Enables zsh registration
       - fish   # Enables fish registration
       # ... other modules
   ```

2. **Run the playbook**:
   ```bash
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml
   ```

3. **Enter sudo password when prompted**:
   ```
   BECOME password: [type your password]
   ```

4. **Verify registration**:
   ```bash
   cat /etc/shells | grep homebrew
   ```

   Expected output:
   ```
   /opt/homebrew/bin/zsh
   /opt/homebrew/bin/fish
   ```

5. **Change your shell**:
   ```bash
   chsh -s /opt/homebrew/bin/fish
   ```

6. **Restart your terminal** to activate the new shell

---

## Updating Configuration

### Add a Shell

1. Add module to install list in `playbooks/deploy.yml`:
   ```yaml
   install:
     - fish  # Add this line
   ```

2. Re-run playbook:
   ```bash
   ansible-playbook -i playbooks/inventory playbooks/deploy.yml
   ```

3. Shell is now registered and available

### Remove a Shell

**Note**: Removing a module from the install list does NOT remove the shell from `/etc/shells`. This is by design - we respect your choice to keep shells available.

To manually remove:
```bash
sudo vi /etc/shells
# Delete the Homebrew shell line
```

---

## Verification

### Check Registration Status

```bash
# List all registered shells
cat /etc/shells

# Count Homebrew shells
grep -c homebrew /etc/shells

# Check for duplicates (should be empty)
sort /etc/shells | uniq -d
```

### Test Idempotency

Run playbook multiple times:
```bash
# First run - should add shells
ansible-playbook -i playbooks/inventory playbooks/deploy.yml

# Second run - should report no changes
ansible-playbook -i playbooks/inventory playbooks/deploy.yml
```

Look for this output on second run:
```
TASK [Ensure Homebrew zsh is in /etc/shells] ***
ok: [localhost]  ← "ok" means no changes (idempotent)
```

### Functional Test

```bash
# Verify you can change shells
chsh -s /opt/homebrew/bin/zsh   # Should succeed without error

# Check current shell
echo $SHELL                      # Should show /opt/homebrew/bin/zsh (after restart)

# Verify shell works
zsh --version                    # Should show version number
```

---

## Troubleshooting

### Problem: Permission denied

**Symptom**:
```
fatal: [localhost]: FAILED! => {"msg": "failed to transfer file..."}
```

**Solution**:
- Ensure you entered sudo password when prompted
- Check you have admin privileges: `groups | grep admin`
- Try running with explicit become: `--ask-become-pass`

---

### Problem: Shell not in /etc/shells after playbook run

**Check**:
1. Is module enabled in install list?
   ```bash
   grep -A 10 "install:" playbooks/deploy.yml
   ```

2. Did task run?
   ```bash
   # Look for "Ensure Homebrew zsh" in playbook output
   ansible-playbook ... | grep "Ensure Homebrew"
   ```

3. Was task skipped due to condition?
   ```
   TASK [Ensure Homebrew zsh is in /etc/shells] ***
   skipping: [localhost]  ← Module not in install list
   ```

**Solution**: Add module name to `dotmodules.install` list

---

### Problem: Duplicate entries in /etc/shells

**Check**:
```bash
sort /etc/shells | uniq -d
```

**Cause**: Manual editing or non-Ansible modification

**Solution**: Manually remove duplicates
```bash
sudo cp /etc/shells /etc/shells.backup
sudo vi /etc/shells  # Delete duplicate lines
```

**Prevention**: Let Ansible manage file exclusively

---

### Problem: chsh still rejects shell after registration

**Check**:
1. Is exact path in /etc/shells?
   ```bash
   cat /etc/shells | grep -x "/opt/homebrew/bin/fish"
   ```

2. Does binary exist?
   ```bash
   ls -la /opt/homebrew/bin/fish
   ```

3. Is path correct for your architecture?
   - Apple Silicon: `/opt/homebrew/bin/*`
   - Intel Mac: `/usr/local/bin/*` (requires manual adjustment)

**Solution**: Verify binary path matches /etc/shells entry exactly

---

## Dry-Run Mode

Test what would change without modifying files:

```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --check
```

Look for output:
```
TASK [Ensure Homebrew zsh is in /etc/shells] ***
changed: [localhost]  ← Would add (not yet present)
```

or

```
ok: [localhost]  ← Already present (no changes needed)
```

---

## Advanced Usage

### Verbose Output

See exactly what Ansible is doing:
```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml -v
```

Levels:
- `-v`: Basic task details
- `-vv`: Task results and parameters
- `-vvv`: Full execution details
- `-vvvv`: SSH/connection debugging

### Limit to Shell Tasks Only

Run only shell registration tasks (requires tags - not currently implemented):
```bash
# Current: Run full playbook
ansible-playbook -i playbooks/inventory playbooks/deploy.yml

# Future enhancement: Add tags to tasks
# ansible-playbook ... --tags shell-registration
```

### Intel Mac Users

Manually adjust shell paths in `playbooks/deploy.yml`:

```yaml
tasks:
  - name: Ensure Homebrew zsh is in /etc/shells
    become: yes
    lineinfile:
      path: /etc/shells
      line: /usr/local/bin/zsh  # Changed from /opt/homebrew
      state: present
    when: "'zsh' in dotmodules.install"
```

---

## Files Modified

| File | Changes | Backup Recommended |
|------|---------|-------------------|
| `/etc/shells` | Adds Homebrew shell paths | Yes (automatic via Ansible) |
| `playbooks/deploy.yml` | Adds registration tasks | Yes (git tracked) |

---

## Next Steps

After shell registration:

1. **Change your default shell**:
   ```bash
   chsh -s /opt/homebrew/bin/fish
   ```

2. **Restart terminal** to activate new shell

3. **Configure shell**:
   - Fish: `~/.config/fish/config.fish` (managed by fish module)
   - Zsh: `~/.zshrc` (managed by zsh module)

4. **Verify environment**:
   ```bash
   echo $SHELL          # Should show new shell
   which fish           # Should show Homebrew path
   ```

---

## Related Documentation

- **Feature Spec**: [spec.md](spec.md)
- **Implementation Plan**: [plan.md](plan.md)
- **Research**: [research.md](research.md)
- **Data Model**: [data-model.md](data-model.md)
- **Constitution**: [docs/policy/CONSTITUTION.md](../../../docs/policy/CONSTITUTION.md)

---

## Summary

This feature automates a single manual step (editing `/etc/shells`) with zero configuration required. Just enable your shell modules and run the playbook - your shells are immediately available for use.

**Key Benefits**:
- ✅ No manual system file editing
- ✅ Fully idempotent (safe to re-run)
- ✅ Respects module selection
- ✅ Works immediately after playbook completes
