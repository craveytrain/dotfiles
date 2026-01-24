# Dotfiles Configuration Management

## What This Is

A modular Ansible-based system for managing tool configurations consistently across multiple macOS machines. Eliminates configuration drift so muscle memory works everywhere - aliases, keybindings, shell functions, and tool settings stay synchronized without manual copying.

## Core Value

Muscle memory consistency. When you use a command, alias, or keybinding on one machine, it works identically on all your machines.

## Requirements

### Validated

These capabilities already exist and work:

- ✓ 1Password CLI configuration module — existing
- ✓ Development tools module (mise, jq, shellcheck, bat, etc.) — existing
- ✓ Editor module (Vim with vim-plug and plugins) — existing
- ✓ Fish shell configuration module — existing
- ✓ Font management module (Fira Code, Hack Nerd Font, etc.) — existing
- ✓ Git configuration module (config, aliases, GitHub CLI) — existing
- ✓ Node.js version management via mise — existing
- ✓ Shell utilities module (eza, ripgrep, tldr, trash, wget, stow) — existing
- ✓ Zsh configuration module (powerlevel10k, plugins, functions) — existing
- ✓ Configuration merging across modules (multiple modules contribute to shared files) — existing
- ✓ Local override support (.zshrc.local, .vimrc.local, etc.) — existing
- ✓ Shell registration with optional skip for restricted machines — existing
- ✓ Ansible + ansible-role-dotmodules + GNU Stow deployment — existing
- ✓ Idempotent playbook execution — existing

### Active

Current work and planned additions:

- [ ] Fix duplicate 1password module entry in deploy.yml
- [ ] Ghostty terminal configuration module
- [ ] Claude CLI configuration module
- [ ] Discover and add additional config files from home directory audit (ongoing)

### Out of Scope

- Full machine provisioning — this is configuration management, not setup automation; software installation is selective
- Mac App Store applications — nerfed versions, not desirable
- Universal software installation — case-by-case; CLI tools via Homebrew fine, GUI apps selective
- Windows/Linux support — macOS only (Apple Silicon assumed)
- Version numbers or formal releases — continuous improvement, no artificial milestones

## Context

**System architecture:**
- Modular design: each tool/domain is a self-contained module in `modules/`
- Deployment: Ansible playbook uses ansible-role-dotmodules role to process modules
- File management: GNU Stow creates symlinks from module files to home directory
- Configuration merging: Multiple modules can contribute to shared files (`.zshrc`, `.config/fish/config.fish`, etc.) with ansible-role-dotmodules handling the merge

**Constitutional principles (from docs/policy/CONSTITUTION.md v1.0.0):**
1. Modularity - modules are self-contained and independent
2. Idempotency - safe to run playbook repeatedly
3. Automation-First - minimize manual intervention
4. Cross-Platform Awareness - handle platform differences gracefully
5. Configuration Merging - intelligent conflict resolution
6. Documentation-First - document alongside code
7. Version Control - all configurations tracked
8. Declarative Over Imperative - prefer YAML over shell scripts

**Machine landscape:**
- Multiple macOS machines synced via git pull + Ansible deployment
- One machine managed by corporate IT with BeyondTrust (requires `--skip-tags register_shell`)
- Configuration drift is temporal (between deployments), not permanent

**Migration context:**
- Transitioning from SpecKit to GSD workflow
- SpecKit artifacts exist in `specs/` and `docs/policy/`
- Long-running repo that has evolved through multiple formats over years

## Constraints

- **Platform**: macOS Apple Silicon only — simplifies Homebrew paths (/opt/homebrew), no Intel compatibility needed
- **Deployment**: Ansible 2.9+ required — core automation framework
- **Privileges**: Must support restricted execution on BeyondTrust-managed machine — shell registration behind `--skip-tags register_shell`
- **Architecture**: Must follow ansible-role-dotmodules patterns — existing modules define the structure
- **Dependencies**: Requires Homebrew, ansible-role-dotmodules (external role), GNU Stow

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| macOS Apple Silicon only | Simplifies deployment, eliminates Intel/ARM path handling complexity | — Pending |
| Configuration management over provisioning | Focus on config sync, not machine setup; new machines are rare | — Pending |
| Selective software installation | CLI tools fine, GUI apps case-by-case; avoids Mac App Store nerfed versions | — Pending |
| ansible-role-dotmodules external dependency | Provides module processing, merging, and Stow integration; mature and working | ✓ Good |
| Constitutional principles documented | Clear decision framework for future additions and changes | ✓ Good |

---
*Last updated: 2026-01-23 after initialization*
