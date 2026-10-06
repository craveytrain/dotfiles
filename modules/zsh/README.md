# Zsh

Installs Zsh, Powerlevel10k, zsh-autosuggestions, and zsh-syntax-highlighting. It stows the Zsh startup files, prompt configuration, shared fragments, colors, and the `colortest` helper.

Use `~/.config/zsh/.zshrc.local` for private or machine-specific settings. The shared `.zshrc` loads it when present.

Prompt colors are explicit `#RRGGBB` values in the `DOTFILES_ZSH_PROMPT_COLORS` palette near the top of `~/.config/zsh/.p10k.zsh`, matching Tide's Lean / True color settings. Zsh keeps its own palette and does not need Fish installed. Edit that palette for shared changes, or override individual colors in `.zshrc.local`:

```zsh
typeset -gA DOTFILES_ZSH_PROMPT_COLOR_OVERRIDES=(
  pwd_anchors '#00AFFF'
  git_branch  '#5FD700'
  character   '#5FD700'
)
```

Run `exec zsh` to reload. Color names and ANSI indexes follow the terminal theme; hex values keep the exact colors you choose. Later Tide customizations are independent—update this palette too when you want both prompts to match.
