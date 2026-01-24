# Ghostty Terminal Module

**Module for Ghostty terminal emulator configuration**

Provides synchronized Ghostty terminal configuration across all machines with customized theme, fonts, and window settings.

## Core Features

- **Configuration sync** - Ghostty settings synchronized via git
- **Symlink deployment** - Files deployed via GNU Stow (edits in modules/ reflected immediately)
- **Theme configuration** - Shades of Purple color scheme
- **Font settings** - MonoLisa Nerd Font configuration
- **Window customization** - Padding, titlebar style, and display preferences

## Installation Components

**Files Deployed:**
- `~/.config/ghostty/config` - Ghostty terminal configuration

**Optional Software:**
- Ghostty terminal emulator (via Homebrew cask)

## Prerequisites

- **Ghostty** - Terminal emulator must be installed (handled by module via Homebrew cask)
- **MonoLisa Nerd Font** - Font must be available (installed via fonts module)

## Deployment

Module is automatically deployed when included in `playbooks/deploy.yml`:

```yaml
dotmodules:
  install:
    - ghostty
```

Run the deployment playbook:

```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass
```

## Configuration

### Editing Configuration

Since files are symlinked, edits can be made directly in the module:

```bash
vim modules/ghostty/files/.config/ghostty/config
```

Changes are immediately reflected in `~/.config/ghostty/config`.

### Syncing Changes

After editing, commit and push to sync across machines:

```bash
git add modules/ghostty/files/.config/ghostty/config
git commit -m "Update Ghostty configuration"
git push
```

On other machines, pull and redeploy:

```bash
git pull
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass
```

## Configuration Options

The current configuration includes:

- **Font**: MonoLisa Nerd Font, size 14, Regular style
- **Theme**: Shades of Purple (custom palette with purple/pink accents)
- **Window**: 8px padding, tabs titlebar style, inherit font size

For all available options, see [Ghostty documentation](https://ghostty.org/docs/config).

## Files

```text
modules/ghostty/
├── config.yml                      # Module configuration for ansible-role-dotmodules
├── README.md                       # This file
└── files/
    └── .config/
        └── ghostty/
            └── config              # Ghostty terminal configuration
```

## References

- [Ghostty Official Site](https://ghostty.org)
- [Ghostty Configuration Documentation](https://ghostty.org/docs/config)
- [ansible-role-dotmodules](https://github.com/mccurdyc/ansible-role-dotmodules)

---
*Module follows dotfiles Constitutional principles: modular, idempotent, documented*
