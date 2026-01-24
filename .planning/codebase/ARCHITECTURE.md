# Architecture

**Analysis Date:** 2026-01-23

## Pattern Overview

**Overall:** Module-based dotfiles management system using Ansible automation

**Key Characteristics:**
- Modular, composition-based architecture where each domain (shell, git, editor, etc.) is a standalone module
- Configuration-driven deployment using `ansible-role-dotmodules` role
- File merging strategy for cross-module configuration contributions
- Local override pattern for machine-specific customization
- Homebrew-integrated package management with Ansible automation

## Layers

**Orchestration Layer:**
- Purpose: Define and execute deployment workflows
- Location: `playbooks/deploy.yml`
- Contains: Ansible playbook with module installation ordering and configuration
- Depends on: ansible-role-dotmodules role, module definitions
- Used by: Direct user execution via ansible-playbook command

**Module Layer:**
- Purpose: Package self-contained dotfile configurations with dependencies
- Location: `modules/*/` (10 modules: 1password, dev-tools, editor, fish, fonts, git, node, shell, zsh, and merged)
- Contains: Module metadata (`config.yml`), dotfiles (`files/`), and documentation (`README.md`)
- Depends on: Homebrew (for package installation), GNU Stow (for symlinking)
- Used by: ansible-role-dotmodules role which applies configuration

**Configuration Layer:**
- Purpose: Define how modules deploy packages and files
- Location: `modules/*/config.yml` (each module)
- Contains: YAML definitions of Homebrew packages, stow directories, and mergeable files
- Depends on: System package managers
- Used by: ansible-role-dotmodules role during deployment

**File Deployment Layer:**
- Purpose: Store actual dotfiles and configuration files to be deployed to home directory
- Location: `modules/*/files/` (e.g., `modules/zsh/files/.zshrc`, `modules/git/files/.gitconfig`)
- Contains: Dotfiles organized in home directory structure (.zshrc, .vimrc, .gitconfig, .config/)
- Depends on: No dependencies
- Used by: GNU Stow for creating symlinks to home directory

**Merging Layer:**
- Purpose: Combine contributions from multiple modules into single files
- Location: `modules/merged/` (special module containing merged output)
- Contains: Pre-merged files from multiple module contributors (e.g., `.zsh/aliases.sh`, `.zshrc`)
- Depends on: ansible-role-dotmodules merging capability
- Used by: Shell initialization (sourced by `.zshrc` and `.zsh/environment.sh`)

**Local Override Layer:**
- Purpose: Support machine-specific customization without modifying tracked files
- Location: `.zshrc.local`, `.vimrc.local`, `.config/fish/config.local.fish` (in home directory)
- Contains: User's custom configuration that extends or overrides deployed configuration
- Depends on: Sourcing/inclusion from main configuration files
- Used by: Individual applications (Zsh, Vim, Fish) at runtime

## Data Flow

**Deployment Flow:**

1. User runs: `ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass`
2. Playbook loads `dotmodules` role configuration with list of modules to install
3. ansible-role-dotmodules processes each module in order (git, fonts, 1password, shell, fish, zsh, dev-tools, node, editor)
4. For each module:
   - Installs Homebrew packages defined in `config.yml`
   - Uses GNU Stow to symlink files from `modules/*/files/` to home directory
   - Merges files from `mergeable_files` list into single files in `modules/merged/`
5. Symlink results: `~/.zshrc` → `modules/zsh/files/.zshrc`, etc.
6. Merged files stored in: `modules/merged/` with metadata about source modules

**Configuration Sourcing (Zsh):**

1. User opens terminal, Zsh reads `.zshenv`
2. `.zshrc` sources shell configuration in this order:
   - `~/.zsh/environment.sh` (merged from multiple modules)
   - `~/.zsh/aliases.sh` (merged from multiple modules)
   - `~/.zsh/functions.sh` (from zsh module)
   - `~/.zsh/utility.zsh` (from zsh module)
   - `~/.zshrc.local` (local machine overrides if exists)
   - zsh-autosuggestions plugin
   - powerlevel10k prompt theme
   - zsh-syntax-highlighting plugin

**Package Management Flow:**

1. Homebrew packages are declared in `config.yml` files per module
2. ansible-role-dotmodules invokes Homebrew to install declared packages
3. Packages become available in PATH automatically after installation

**State Management:**

- **Immutable truth:** `modules/*/files/` - the canonical source of all dotfiles
- **Generated state:** `modules/merged/` - automatically created by ansible-role-dotmodules from mergeable contributions
- **Deployed state:** Home directory dotfiles via symlinks (via GNU Stow)
- **User customization:** `.*.local` files override deployed configuration without modifying tracked files

## Key Abstractions

**Module:**
- Purpose: Self-contained package representing a functional domain (shell config, git config, etc.)
- Examples: `modules/shell/`, `modules/zsh/`, `modules/git/`, `modules/editor/`
- Pattern: Each module has `config.yml` (metadata) and `files/` (dotfiles). Modules can depend on others (e.g., node requires dev-tools for mise).

**Mergeable Files:**
- Purpose: Support multi-module configuration of single files
- Examples: `.zshrc`, `.zsh/aliases.sh`, `.config/fish/config.fish`, `.config/mise/config.toml`
- Pattern: Multiple modules can contribute to same file; ansible-role-dotmodules merges with module name headers showing source

**Stow Directory:**
- Purpose: Organize dotfiles for deployment via GNU Stow
- Examples: `zsh/`, `shell/`, `git/`, `editor/` within `modules/*/files/`
- Pattern: Directory structure mirrors home directory structure (e.g., `stow_dirs: [zsh]` means `modules/zsh/files/zsh/` symlinks to `~/.zsh/`)

**Local Override:**
- Purpose: Allow per-machine customization without committing sensitive or machine-specific data
- Examples: `.zshrc.local`, `.vimrc.local`
- Pattern: Main configuration files explicitly source `.*.local` if it exists; files are .gitignored

## Entry Points

**Deployment Entry Point:**
- Location: `playbooks/deploy.yml`
- Triggers: User execution of `ansible-playbook` command
- Responsibilities: Define module list, configure ansible-role-dotmodules behavior, specify shell registration behavior via tags

**Shell Entry Point (Zsh):**
- Location: `modules/zsh/files/.zshrc` (symlinked to `~/.zshrc`)
- Triggers: Interactive shell session start
- Responsibilities: Initialize Zsh, load shared configuration, apply local overrides, load plugins and theme

**Zsh Configuration Entry Point:**
- Location: `modules/zsh/files/.zsh/environment.sh` (merged file from shell + zsh + editor modules)
- Triggers: Sourced by `.zshrc`
- Responsibilities: Provide shell aliases and environment variables across modules

**Vim Entry Point:**
- Location: `modules/editor/files/.vimrc` (symlinked to `~/.vimrc`)
- Triggers: Vim editor startup
- Responsibilities: Bootstrap vim-plug, declare plugins, apply base configuration, source local overrides

**Git Entry Point:**
- Location: `modules/git/files/.gitconfig` (symlinked to `~/.gitconfig`)
- Triggers: Git commands
- Responsibilities: Configure git user, aliases, diff tools, global behavior

## Error Handling

**Strategy:** Fail-safe defaults with optional features gracefully degraded

**Patterns:**
- Plugin sourcing uses conditional checks (e.g., `.zsh/aliases.sh` checks `if whence eza >/dev/null` before using eza aliases)
- Local override files use conditional sourcing: `[ -f ~/.zshrc.local ] && source ~/.zshrc.local` (only loads if exists)
- Vim-plug auto-installs plugins on first run: if `~/.vim/autoload/plug.vim` doesn't exist, downloads and installs via curl
- Module dependencies are documented but not enforced at deployment time (e.g., node module requires dev-tools for mise, but playbook doesn't enforce order)

## Cross-Cutting Concerns

**Package Management:** Homebrew packages declared per-module in `config.yml`; ansible-role-dotmodules handles installation orchestration

**Configuration Organization:** Files organized by functional domain in modules; merging handled by ansible-role-dotmodules for multi-module files; local overrides via `.*.local` pattern

**Symlink Deployment:** GNU Stow used for safe, reversible dotfile deployment; stow_dirs specified in `config.yml` map to directory structure in `files/`

**Local Customization:** Machine-specific configuration isolated in `.*.local` files to avoid committing sensitive data; main configs explicitly source these files

**Plugin Management:** Vim uses vim-plug for plugin management (auto-bootstraps); Zsh loads plugins from Homebrew-installed packages sourced in `.zshrc`

**Version Management:** Node.js and development tools managed via mise (version manager declared in dev-tools module, configured by node module)

---

*Architecture analysis: 2026-01-23*
