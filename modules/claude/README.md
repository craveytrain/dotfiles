# Claude Code

Stows shared Claude Code settings, hooks, and the status line into `~/.claude`.
Claude Code itself is installed separately because managed machines may block
package-manager installation.

Owned files:

- `~/.claude/settings.json`
- `~/.claude/statusline.js`
- `~/.claude/hooks/ai-usage-nudge.mjs`
- `~/.claude/hooks/attention-notify.js`
- `~/.claude/hooks/scrub-volatile-settings.mjs`

Machine- or project-specific settings belong in Claude's local settings files,
not the shared `settings.json`. Claude Code writes some of its own runtime
state there anyway, so a `SessionEnd` hook strips those keys back out and
`.githooks/pre-commit` blocks a commit that still carries them. The deploy
playbook points `core.hooksPath` at `.githooks`, so that check needs no
per-clone setup.
