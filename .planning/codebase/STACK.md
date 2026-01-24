# Technology Stack

**Analysis Date:** 2026-01-23

## Languages

**Primary:**
- YAML 1.1 - Ansible configuration and module metadata
- Bash/Shell (sh, bash, zsh) - Scripts and shell configuration
- Vim script (vim 8.0+) - Editor configuration and plugins

**Secondary:**
- TOML - Version management configuration (mise)
- Plain text - Configuration files (fish config, git config, ghostty config)

## Runtime

**Environment:**
- macOS (required for Homebrew integration)
- Ansible 2.9+ (automation engine)

**Package Manager:**
- Homebrew 4.0+ (primary package manager for macOS)
- Fisher (plugin manager for Fish shell)
- vim-plug (plugin manager for Vim)
- mise (version manager for node, python, and other tools)

**Lockfile:**
- `requirements.yml` - Ansible Galaxy requirements (tracks ansible-role-dotmodules and geerlingguy.mac collection)

## Frameworks

**Core:**
- Ansible 2.9+ - Infrastructure automation framework for dotfile deployment
- ansible-role-dotmodules (custom role) - Modular dotfile deployment system
- GNU Stow - Symlink management for dotfile deployment

**Testing:**
- Not formally configured in this codebase

**Build/Dev:**
- mise - Polyglot version manager (handles node, python, ruby, etc.)
- GitHub Actions - CI/CD (implied by presence of GitHub CLI configuration)

## Key Dependencies

**Critical:**
- ansible-role-dotmodules - Custom Ansible role for modular dotfile management
  - Source: `https://github.com/craveytrain/ansible-role-dotmodules.git`
  - Purpose: Core deployment mechanism for all modules
- geerlingguy.mac >= 1.0.0 - Ansible collection for macOS system configuration
  - Purpose: macOS-specific Homebrew integration and system setup

**Shell:**
- zsh - Primary shell with plugins (powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting)
- fish - Alternative shell with fisher plugin manager
- bash - Fallback shell

**Development Tools:**
- Homebrew packages: mise, jq, shellcheck, actionlint, bat, ngrep, nmap
- eza - Modern `ls` replacement
- ripgrep - Fast grep alternative
- diff-so-fancy / difftastic - Enhanced diff viewers
- tldr - Simplified man pages
- trash - Safe `rm` replacement
- wget - File downloader

**Editor:**
- vim 8.0+ with vim-plug
- vim-commentary (tpope/vim-commentary)

**Version Management:**
- node (latest) - JavaScript runtime via mise
- pnpm (latest) - Package manager for JavaScript projects via mise
- python 3.13.2 - Python runtime via mise

**Integration Tools:**
- 1Password CLI - Secure credential management
- GitHub CLI (gh) - GitHub interaction and authentication
- Git - Version control

## Configuration

**Environment:**
Configured via YAML module files and mergeable configuration file system.

**Mergeable Files:**
- `.zshrc` - Merged from multiple modules (git, dev-tools, editor, zsh)
- `.zsh/environment.sh` - Environment variables merged from shell, zsh, editor modules
- `.zsh/aliases.sh` - Aliases merged from zsh and editor modules
- `.config/fish/config.fish` - Fish configuration merged from shell, editor, dev-tools, fish modules
- `.config/mise/config.toml` - Version manager config merged from dev-tools and node modules

**Key Configs Required:**
- Ansible Galaxy requirements installed via `ansible-galaxy install -r requirements.yml`
- Python interpreter: `auto_silent` mode in `ansible.cfg` to avoid discovery warnings
- Module deployment: Registered in `playbooks/deploy.yml` with ordered installation sequence

**Build:**
- `ansible.cfg` - Ansible configuration at `/Users/mcravey/dotfiles/ansible.cfg`
- `playbooks/deploy.yml` - Main deployment playbook
- Module structure: Each module has `config.yml` defining Homebrew packages, stow directories, and mergeable files

## Platform Requirements

**Development:**
- macOS system (required for Homebrew and system integration)
- Ansible 2.9 or later
- GNU Stow (installed via shell module)
- Homebrew (installed before running playbook)
- Sudo/root access for shell registration in `/etc/shells` (can be skipped with `--skip-tags register_shell`)

**Production:**
- Deployment target: User home directory (`~/.dotmodules/` as deploy destination)
- System shell registration: Updates `/etc/shells` with registered shells (Fish, Zsh)
- Stow deployment: Creates symlinks from module files to home directory

## Deployment Architecture

**Module System:**
Each module in `modules/` directory contains:
- `config.yml` - Module metadata and configuration
- `files/` - Dotfiles to deploy (relative to home directory)

**Modules:**
- `shell` - Common shell utilities (eza, ripgrep, tldr, trash, wget, stow)
- `fish` - Fish shell and fisher plugin manager
- `zsh` - Zsh shell with powerlevel10k prompt
- `git` - Git and GitHub CLI tools
- `editor` - Vim editor and configuration
- `dev-tools` - Development utilities (mise, jq, shellcheck, actionlint, bat)
- `node` - Node.js and pnpm version management via mise
- `1password` - 1Password CLI for credential management
- `fonts` - System fonts (Fira Code, Hack Nerd Font, Inconsolata, Input)

**Deployment Flow:**
1. `ansible-playbook` executes `playbooks/deploy.yml`
2. Uses `ansible-role-dotmodules` role to process each module
3. Role installs Homebrew packages defined in each module's `config.yml`
4. Role symlinks files from modules to home directory via GNU Stow
5. Merges configuration files from multiple modules into unified configs
6. Registers shells in `/etc/shells` when `register_shell` config is present

---

*Stack analysis: 2026-01-23*
