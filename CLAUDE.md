# .dotfiles Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-12-15

## Active Technologies
- Ansible 2.9+, YAML configuration (002-fix-stow-conflicts)
- File system (home directory, backup locations) (002-fix-stow-conflicts)
- YAML (Ansible 2.9+), Bash (macOS default) + Ansible, ansible-role-dotmodules, GNU Stow, Homebrew (001-register-homebrew-shells)
- System file `/etc/shells` (plain text, one path per line) (001-register-homebrew-shells)

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
- 001-register-homebrew-shells: Added YAML (Ansible 2.9+), Bash (macOS default) + Ansible, ansible-role-dotmodules, GNU Stow, Homebrew
- 002-fix-stow-conflicts: Added Ansible 2.9+, YAML configuration

- 001-move-git-scripts: Added Shell scripts (sh, bash) and Ruby script - no version constraints + Git (already installed via git module), GNU Stow (for deployment), Ansible (for automation)

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
