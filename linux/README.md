# Linux server setup

A small, standalone bash setup for Linux servers (Debian, Ubuntu, Raspberry Pi OS). Separate from the Mac Ansible path; safe to run on a fresh box.

Intended for occasional SSH management — not a full dev environment. If you want the full Mac configuration, use the Ansible playbook in `playbooks/` instead (Mac only).

## What it installs

- **apt packages**: `jq`, `ripgrep`, `direnv`, `shellcheck`, `vim`, `git`, `stow`
- **Starship** prompt (via the official installer, ARM64 or x86_64 auto-detected)

## What it symlinks

- `~/.bashrc.d/dotfiles.sh` — small alias/env file (this directory's `bashrc.d/dotfiles.sh`)
- `~/.config/starship.toml` — prompt config tuned to mirror the Mac tide layout, with language modules disabled
- `~/.config/git/config` — the shared git config from `modules/git/files/.config/git/config`
- `~/.config/git/ignore` — the shared global gitignore
- `~/.vimrc` — the shared vim config from `modules/editor/files/.vimrc` (vim-plug + vim-commentary)

The Mac-only git settings (`~/.config/git/macos`) are intentionally not symlinked; the shared config silently ignores the missing include.

It also appends one line to `~/.bashrc` (idempotent) so the bashrc.d file is sourced.

## Usage

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
bash linux/setup.sh
```

Re-running is safe.

## Remaining Mac-isms in the shared gitconfig

These are inert on Linux unless you explicitly invoke them:

- `pager.diff = diff-so-fancy ...` and `pager.show = diff-so-fancy ...` — overridden by `GIT_PAGER='less -R'` in `bashrc.d/dotfiles.sh`
- `[diff] tool = Kaleidoscope`, `[merge] tool = Kaleidoscope` — only fire on `git difftool` / `git mergetool`; otherwise inert
- `[credential "https://github.com"]` etc. via `gh` — only invoked on HTTPS push; works fine if `gh` is on PATH

If any of these bite, fix locally with `git config --global` rather than editing the shared file.

## Aliases provided

Mirrors a small subset of the Mac zsh/fish alias set:

- `ip` — public IP via `dig`
- `pubkey` — print SSH pubkey to stdout (no clipboard on a headless server)
- `mkdir` — `mkdir -p`
- `df`, `du` — human-readable
- `dot` — `cd $DOTFILES`
- `e <file>` — open in `$VISUAL`/`$EDITOR`/vim

Stock Pi OS / Debian `~/.bashrc` provides `ll`, `la`, `l`, `grep --color=auto` already; we don't override.

## Not included

Tailscale, Node, Claude Code — install these via their official scripts before or after `setup.sh`. They are intentionally outside the dotfiles flow.
