# Dotfiles Configuration Management

## What This Is

A modular Ansible-based system for managing tool configurations consistently across multiple macOS machines. Each module owns its own conf.d fragments that are stowed as symlinks, so config edits go live on `git pull` without redeploying. Muscle memory works everywhere - aliases, keybindings, shell functions, and tool settings stay synchronized.

## Core Value

Muscle memory consistency. When you use a command, alias, or keybinding on one machine, it works identically on all your machines.

## Requirements

### Validated

- ✓ 1Password CLI configuration module — existing
- ✓ Development tools module (mise, jq, shellcheck, bat, etc.) — existing
- ✓ Editor module (Vim with vim-plug and plugins) — existing
- ✓ Fish shell configuration module — existing
- ✓ Font management module (Fira Code, Hack Nerd Font, etc.) — existing
- ✓ Git configuration module (config, aliases, GitHub CLI) — existing
- ✓ Node.js version management via mise — existing
- ✓ Shell utilities module (eza, ripgrep, tldr, trash, wget, stow) — existing
- ✓ Zsh configuration module (powerlevel10k, plugins, functions) — existing
- ✓ Ghostty terminal configuration module — v1.0
- ✓ Claude CLI configuration module — v1.0
- ✓ Local override support (.zshrc.local, .vimrc.local, etc.) — existing
- ✓ Shell registration with optional skip for restricted machines — existing
- ✓ Ansible + ansible-role-dotmodules + GNU Stow deployment — existing
- ✓ Idempotent playbook execution — existing
- ✓ Runtime conf.d sourcing for zsh (glob loop in .zshrc) — v1.1
- ✓ Runtime conf.d sourcing for fish (native conf.d mechanism) — v1.1
- ✓ Runtime conf.d sourcing for mise (standalone TOML fragments) — v1.1
- ✓ Merge infrastructure removed from role and all modules — v1.1
- ✓ conf.d ordering convention documented — v1.1

### Active

(No active milestone. Use `/gsd:new-milestone` to start next.)

### Out of Scope

- Full machine provisioning — this is configuration management, not setup automation; software installation is selective
- Mac App Store applications — nerfed versions, not desirable
- Universal software installation — case-by-case; CLI tools via Homebrew fine, GUI apps selective
- Windows/Linux support — macOS only (Apple Silicon assumed)
- Zsh debug mode (DOTFILES_DEBUG=1) — p10k instant prompt intercepts all console output during shell init; may revisit as standalone script

## Context

**Current state:** Shipped v1.1 Runtime Includes. 10 modules, all using conf.d fragments for shell/tool config. No modules use mergeable_files. Config edits go live on `git pull`.

**System architecture:**
- Modular design: each tool/domain is a self-contained module in `modules/`
- Deployment: Ansible playbook uses ansible-role-dotmodules role to process modules
- File management: GNU Stow creates symlinks from module files to home directory
- Configuration: Each module stows its own conf.d fragments; shells source them at runtime

**Constitutional principles (from docs/policy/CONSTITUTION.md v1.0.0):**
1. Modularity - modules are self-contained and independent
2. Idempotency - safe to run playbook repeatedly
3. Automation-First - minimize manual intervention
4. Cross-Platform Awareness - handle platform differences gracefully
5. Documentation-First - document alongside code
6. Version Control - all configurations tracked
7. Declarative Over Imperative - prefer YAML over shell scripts

**Machine landscape:**
- Multiple macOS machines synced via git pull + Ansible deployment
- One machine managed by corporate IT with BeyondTrust (requires `--skip-tags register_shell`)
- Configuration drift is now minimal: conf.d changes are live on git pull

## Constraints

- **Platform**: macOS Apple Silicon only — simplifies Homebrew paths (/opt/homebrew), no Intel compatibility needed
- **Deployment**: Ansible 2.9+ required — core automation framework
- **Privileges**: Must support restricted execution on BeyondTrust-managed machine — shell registration behind `--skip-tags register_shell`
- **Architecture**: Must follow ansible-role-dotmodules patterns — existing modules define the structure
- **Dependencies**: Requires Homebrew, ansible-role-dotmodules (external role), GNU Stow

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| macOS Apple Silicon only | Simplifies deployment, eliminates Intel/ARM path handling complexity | ✓ Good |
| Configuration management over provisioning | Focus on config sync, not machine setup; new machines are rare | ✓ Good |
| Selective software installation | CLI tools fine, GUI apps case-by-case; avoids Mac App Store nerfed versions | ✓ Good |
| ansible-role-dotmodules external dependency | Provides module processing and Stow integration; mature and working | ✓ Good |
| Constitutional principles documented | Clear decision framework for future additions and changes | ✓ Good |
| Replace merged files with runtime conf.d sourcing | Edits go live on git pull instead of requiring Ansible redeploy; negligible startup cost (~2ms) | ✓ Good |
| Clean up merge logic from role | No modules use merging after v1.1; dead code removal | ✓ Good |
| Defer DOTFILES_DEBUG (SHRC-04) | p10k instant prompt intercepts all output during shell init; may revisit as standalone script | ⚠️ Revisit |
| Mise full activate over --shims | Full activation provides hook-based version switching in interactive shells | ✓ Good |
| EDITOR/VISUAL owned by editor module only | Single source of truth, no cross-module duplication | ✓ Good |
| Tens-based prefix grouping (10/50/80) | Clear separation between core, features, and late-loading integrations | ✓ Good |

---
*Last updated: 2026-03-11 after v1.1 milestone*
