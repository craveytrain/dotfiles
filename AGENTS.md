# Dotfiles

Modular Ansible + GNU Stow dotfiles shared across multiple macOS machines: each tool is a self-contained module in `modules/` whose conf.d fragments are stowed as symlinks, so config edits go live on `git pull`. The goal is muscle-memory consistency — aliases, keybindings, and tool settings work identically everywhere.

## Constraints

- **Platform**: macOS Apple Silicon (primary). A separate minimal bash setup for Debian/Pi OS Linux servers lives in `linux/` — see `linux/README.md`. No Windows support; no full Linux desktop parity.
- **Privileges**: must support restricted execution on BeyondTrust-managed machines via `--skip-tags register_shell`.
- **Architecture**: must follow ansible-role-dotmodules patterns (external role; Ansible 2.9+); existing modules define the structure.
- **Declarative over imperative**: prefer YAML configs over shell scripts where possible.

## Key Conventions

- Modules are self-contained and independent; no hard cross-module dependencies.
- All operations must be idempotent (safe to run repeatedly).
- conf.d fragments use tens-based prefix grouping (10=core, 50=features, 80=late-loading integrations).
  Exception: fish loads conf.d alphabetically and fisher plugin fragments carry no numeric prefix, so
  they always sort after any digit. A fragment that must override a plugin's key bindings needs a
  letter prefix instead (see `zz-shell-atuin.fish`), not a higher number.
- Local overrides via `.local` files (e.g., `.zshrc.local`, `.vimrc.local`).
- No merged/mergeable files; everything uses runtime conf.d sourcing.

## Out of Scope

Full machine provisioning (this is config management, not setup automation); Mac App Store applications.
