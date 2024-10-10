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
- 003-local-config-overrides: Added YAML (Ansible 2.9+), Shell scripts (bash/zsh/fish), Config formats (Git, Vim) + Ansible, GNU Stow, ansible-role-dotmodules
- 001-mise-node-module: Added YAML (Ansible 2.9+), TOML (mise config format), Bash (shell integration) + Homebrew (mise package), ansible-role-dotmodules, GNU Stow
- 003-local-config-overrides: Added YAML (Ansible 2.9+), Shell (bash/zsh/fish), Git config format, Vim config forma + ansible-role-dotmodules, GNU Stow, Ansible core modules (file, template, lineinfile), community.general collection
- 001-register-homebrew-shells: Added YAML (Ansible 2.9+), Bash (macOS default) + Ansible, ansible-role-dotmodules, GNU Stow, Homebrew


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
