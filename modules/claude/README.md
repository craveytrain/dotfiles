# Claude Code

Stows shared Claude Code settings, hooks, and the status line into `~/.claude`. Claude Code itself is installed separately because managed machines may block package-manager installation.

Owned files:

- `~/.claude/settings.json`
- `~/.claude/statusline.js`
- `~/.claude/hooks/ai-usage-nudge.mjs`
- `~/.claude/hooks/attention-notify.js`
- `~/.claude/hooks/scrub-volatile-settings.mjs`

If Claude has already created a regular `~/.claude/settings.json`, deployment moves it to a unique `settings.json.pre-dotfiles-*` backup in the same directory before Stow creates the shared settings symlink. Existing symlinks are left for Stow to validate. Backups are never merged into the shared settings; review any personal settings separately. In check mode, deployment reports the backup without changing files and defers this module's Stow preview until the conflict is removed.

Machine- or project-specific settings belong in Claude's local settings files, not the shared `settings.json`. Claude Code writes some of its own runtime state there anyway, so a `SessionEnd` hook strips those keys back out and `.githooks/pre-commit` blocks a commit that still carries them. `./deploy` points `core.hooksPath` at `.githooks`, so that check needs no per-clone setup.
