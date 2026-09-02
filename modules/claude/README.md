# Claude Code

Stows shared Claude Code settings, hooks, and the status line into `~/.claude`.
Claude Code itself is installed separately because managed machines may block
package-manager installation.

Owned files:

- `~/.claude/settings.json`
- `~/.claude/statusline.js`
- `~/.claude/hooks/ai-usage-nudge.mjs`
- `~/.claude/hooks/attention-notify.js`

Machine- or project-specific settings belong in Claude's local settings files,
not the shared `settings.json`.
