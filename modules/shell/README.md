# Shell utilities

Installs shared command-line tools used from Fish and Zsh: Atuin, eza, ripgrep,
GNU Stow, tldr, trash, and wget.

The module stows Atuin configuration plus shell fragments for eza colors and
Atuin initialization. History sync is optional:

```bash
atuin login -u <username>
atuin sync
```

For a new account, use:

```bash
atuin register -u <username> -e <email>
```
