# External Integrations

**Analysis Date:** 2026-01-23

## APIs & External Services

**GitHub:**
- GitHub CLI (gh) - Repository and issue management
  - SDK/Client: `gh` command-line tool
  - Config: `modules/git/files/.config/gh/config.yml`
  - Authentication: Via GitHub token (stored in system keychain via 1Password integration)
  - Protocol: HTTPS (configurable in `git_protocol` setting)
  - Features: PR checkout aliases, repository management

**Homebrew Registry:**
- Homebrew package repository - Package installation and version management
  - Client: Homebrew CLI via geerlingguy.mac Ansible collection
  - Auth: GitHub token (for private tap repositories if configured)
  - Purpose: Installs all development tools, shells, fonts, and utilities

**Version Management Registries:**
- Node Version Registry - JavaScript runtime versions
  - Tool: mise (polyglot version manager)
  - Config: `modules/node/files/.config/mise/config.toml`
  - Version: Latest (dynamic, updated automatically)
- Python Version Registry - Python interpreter versions
  - Tool: mise
  - Config: `modules/dev-tools/files/.config/mise/config.toml`
  - Version: 3.13.2 (pinned)

**Bootstrap/Installation:**
- GitHub raw content endpoint - Used in commented bootstrap script
  - URL: `https://raw.githubusercontent.com/craveytrain/dotfiles/main/.bin/bootstrap.sh`
  - Purpose: Remote dotfiles bootstrapper (present in `modules/zsh/files/.zsh/aliases.sh` as commented alias)

## Data Storage

**Databases:**
- None - This is a configuration management system, not a data application

**File Storage:**
- Local filesystem only
  - Primary location: `~/.dotmodules/` (deployment destination)
  - Source: `modules/` directory in repository
  - Symlink mechanism: GNU Stow for dotfile deployment to home directory

**Caching:**
- Homebrew cache: `/Library/Caches/Homebrew/` (managed by Homebrew)
- mise version cache: `~/.local/share/mise/` (managed by mise)
- Fisher plugin cache: `~/.local/share/fish/vendor_conf.d/` (managed by Fisher)

## Authentication & Identity

**Auth Provider:**
- 1Password CLI (op) - Primary credential and identity provider
  - Implementation: Installed via `modules/1password/config.yml`
  - Purpose: Secure credential storage and retrieval for Git, GitHub, and other services
  - Integration: Works with GitHub CLI for seamless authentication

**GitHub CLI Authentication:**
- GitHub token - Managed via 1Password
- Config: `modules/git/files/.config/gh/config.yml`
- Settings:
  - `git_protocol: https` - Uses HTTPS for git operations
  - `prompt: enabled` - Interactive prompting enabled
  - `prefer_editor_prompt: disabled` - Use terminal prompts

## Monitoring & Observability

**Error Tracking:**
- Not configured - This is a configuration management system

**Logs:**
- Ansible logs - Via Ansible playbook execution output
- System shell logs - `.zsh_history`, `.bash_history` (shell-specific)
- Homebrew installation logs - In Homebrew cache and system logs

**Git Integration:**
- Git hooks support - Via stow-deployed git configuration
- Diff viewers configured:
  - diff-so-fancy - Enhanced diff output for git
  - difftastic - Advanced structural diff viewer
  - Both in `modules/git/config.yml`

## CI/CD & Deployment

**Hosting:**
- GitHub - Repository host for dotfiles
- Local deployment - All configuration deployed to user home directory

**CI Pipeline:**
- GitHub Actions - Implied capability via GitHub CLI configuration
- Deployment: Manual via `ansible-playbook` command
  - Command: `ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass`
  - Inventory: `playbooks/inventory` (localhost)
  - Tags: `dotfiles` tag for selective deployment

**Deployment Mechanism:**
- ansible-role-dotmodules - Handles module installation and file deployment
- GNU Stow - Creates symlinks from `modules/*/files/` to home directory
- Ansible Galaxy - Manages role and collection dependencies

## Environment Configuration

**Required env vars:**
- `HOME` - User home directory (used by ansible-role-dotmodules as deployment destination)
- `PATH` - Updated by shell configurations to include mise-managed tools
- GitHub token - Managed via 1Password, not direct env vars
- 1Password token (OP_SESSION_*) - Session-based, handled by 1Password CLI

**Secrets location:**
- 1Password CLI vault - All sensitive credentials stored here
- No `.env` files committed to repository
- Credentials accessed via `op` command during shell initialization
- GitHub token: Retrieved from 1Password when needed by `gh` or git

## Webhooks & Callbacks

**Incoming:**
- None configured - This is a configuration management system

**Outgoing:**
- GitHub - Via `gh` CLI for repository operations
- Homebrew - Package installation callbacks
- System shell integration - Environment and alias updates

## External Tool Integrations

**Shell Integration:**
- zsh-autosuggestions - Fish-like suggestions for Zsh
- zsh-syntax-highlighting - Syntax highlighting for Zsh
- powerlevel10k - Advanced prompt theme for Zsh
- Fisher plugins - Fish shell plugin management via Fisher package manager

**Editor Plugins:**
- vim-plug - Plugin manager for Vim
- vim-commentary - Comment/uncomment plugin for Vim (tpope/vim-commentary)

**Tool Configuration:**
- bat - Cat replacement configured via `modules/dev-tools/files/.config/bat/config`
- Ghostty - Terminal configuration via `~/.config/ghostty/config` (module-managed)
- npm - Configured via `.npmrc` in `modules/node/files/.npmrc`

**Git Diff Integration:**
- diff-so-fancy - Enhanced git diff output
- difftastic - Structural diff viewer for git

## Version Management

**Mise Configuration:**
- Merged configuration from multiple modules:
  - `modules/dev-tools/files/.config/mise/config.toml` - Python (3.13.2) and settings
  - `modules/node/files/.config/mise/config.toml` - Node (latest) and pnpm (latest)
- Settings: `asdf_compat = true` - Compatibility with asdf version manager format

## Installation Dependencies

**External Requirements:**
1. Homebrew - Must be installed before playbook execution
2. Ansible 2.9+ - Must be installed on system
3. GNU Stow - Will be installed by shell module
4. Python interpreter - System Python or managed via mise

**Ansible Galaxy Dependencies:**
- `ansible-role-dotmodules` - Custom role for modular deployment
- `geerlingguy.mac >= 1.0.0` - macOS system configuration collection

---

*Integration audit: 2026-01-23*
