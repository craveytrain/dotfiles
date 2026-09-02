# 1Password

Installs the `op` command through the `1password-cli` Homebrew cask. This module
does not stow configuration.

After deployment, connect the CLI to the desktop app or sign in:

```bash
op signin
op whoami
```

Keep credentials in 1Password or local environment files, never in this
repository. See the [1Password CLI documentation](https://developer.1password.com/docs/cli/)
for command usage.
