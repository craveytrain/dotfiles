# Dotfiles

## What This Is

A modular Ansible-based system for managing tool configurations consistently across multiple macOS machines. Each module owns its own conf.d fragments that are stowed as symlinks, so config edits go live on `git pull` without redeploying. Muscle memory works everywhere: aliases, keybindings, shell functions, and tool settings stay synchronized.

## Core Value

Muscle memory consistency. When you use a command, alias, or keybinding on one machine, it works identically on all your machines.

## Architecture

- **Modular design**: each tool/domain is a self-contained module in `modules/`
- **Deployment**: Ansible playbook uses ansible-role-dotmodules role to process modules
- **File management**: GNU Stow creates symlinks from module files to home directory
- **Configuration**: each module stows its own conf.d fragments; shells source them at runtime
- **Platform**: macOS Apple Silicon only (Homebrew at /opt/homebrew)

## Constraints

- **Platform**: macOS Apple Silicon only
- **Deployment**: Ansible 2.9+ required
- **Privileges**: must support restricted execution on BeyondTrust-managed machines via `--skip-tags register_shell`
- **Architecture**: must follow ansible-role-dotmodules patterns; existing modules define the structure
- **Dependencies**: Homebrew, ansible-role-dotmodules (external role), GNU Stow
- **Declarative over imperative**: prefer YAML configs over shell scripts where possible

## Key Conventions

- Modules are self-contained and independent; no hard cross-module dependencies
- All operations must be idempotent (safe to run repeatedly)
- conf.d fragments use tens-based prefix grouping (10=core, 50=features, 80=late-loading integrations)
- Local overrides via `.local` files (e.g., `.zshrc.local`, `.vimrc.local`)
- No merged/mergeable files; everything uses runtime conf.d sourcing

## Out of Scope

- Full machine provisioning (this is config management, not setup automation)
- Mac App Store applications
- Windows/Linux support
