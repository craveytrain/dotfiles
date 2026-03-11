# .dotfiles Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-12-15

## Active Technologies
- Ansible 2.9+, YAML configuration (002-fix-stow-conflicts)
- File system (home directory, backup locations) (002-fix-stow-conflicts)
- YAML (Ansible 2.9+), Bash (macOS default) + Ansible, ansible-role-dotmodules, GNU Stow, Homebrew (001-register-homebrew-shells)
- System file `/etc/shells` (plain text, one path per line) (001-register-homebrew-shells)
- YAML (Ansible 2.9+), TOML (mise config format), Bash (shell integration) + Homebrew (mise package), ansible-role-dotmodules, GNU Stow (001-mise-node-module)
- File system (home directory dotfiles, ~/.dotmodules/merged/ for mergeable files) (003-local-config-overrides)
- YAML (Ansible 2.9+), Shell scripts (bash/zsh/fish), Config formats (Git, Vim) + Ansible, GNU Stow, ansible-role-dotmodules (003-local-config-overrides)
- Filesystem-based configuration files in module directory structure (001-mise-node-module)
- YAML (Ansible 2.9+), Bash (macOS default) + Ansible Core Modules (set_fact, lineinfile, include_tasks), community.general collection (Homebrew modules) (001-optional-shell-registration)
- File-based configuration in YAML (module config.yml files), system files (/etc/shells) (001-optional-shell-registration)
- File-based configuration in YAML (module config.yml files), system files (/etc/shells), Ansible extra variables (runtime) (002-runtime-skip-shell-registration)
- Vim script (vim 8.0+), YAML (Ansible 2.9+), Bash (for vim-plug installation) + vim (already installed), vim-plug (plugin manager - to be added), vim-commentary (tpope/vim-commentary plugin), ansible-role-dotmodules, GNU Stow, Homebrew (001-vim-plug-commentary)
- File-based configuration (`.vimrc`, module `config.yml`) (001-vim-plug-commentary)
- YAML (Ansible 2.9+), Ghostty config format (plain text key=value) + ansible-role-dotmodules, GNU Stow (already installed via shell module) (001-ghostty-module)
- File-based configuration (`~/.config/ghostty/config`) (001-ghostty-module)

- Shell scripts (sh, bash) and Ruby script - no version constraints + Git (already installed via git module), GNU Stow (for deployment), Ansible (for automation) (001-move-git-scripts)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Shell scripts (sh, bash) and Ruby script - no version constraints

## Code Style

Shell scripts (sh, bash) and Ruby script - no version constraints: Follow standard conventions

## Recent Changes
- 001-ghostty-module: Added YAML (Ansible 2.9+), Ghostty config format (plain text key=value) + ansible-role-dotmodules, GNU Stow (already installed via shell module)
- 001-vim-plug-commentary: Added Vim script (vim 8.0+), YAML (Ansible 2.9+), Bash (for vim-plug installation) + vim (already installed), vim-plug (plugin manager - to be added), vim-commentary (tpope/vim-commentary plugin), ansible-role-dotmodules, GNU Stow, Homebrew
- 002-runtime-skip-shell-registration: Added YAML (Ansible 2.9+), Bash (macOS default) + Ansible Core Modules (set_fact, lineinfile, include_tasks), community.general collection (Homebrew modules)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
