# Zsh

Installs Zsh, Powerlevel10k, zsh-autosuggestions, and
zsh-syntax-highlighting. It stows the Zsh startup files, prompt configuration,
shared fragments, colors, and the `colortest` helper.

Use `~/.config/zsh/.zshrc.local` for private or machine-specific settings. The
shared `.zshrc` loads it when present.

To use Zsh as the login shell on an unrestricted machine:

```bash
chsh -s /opt/homebrew/bin/zsh
```
