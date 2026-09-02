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
not the shared `settings.json`.

## scrub-volatile-settings.mjs

Claude Code writes its own runtime state — `model` step-ups, `enabledPlugins`, `autoMode` — directly into `settings.json`. That file is stowed into this repo and the repo is public, so anything left there gets committed. This hook runs on `SessionEnd` and deletes those three keys if present, writing back through the `~/.claude/settings.json` symlink so the change lands in the tracked file. It's a no-op when none of the keys are present.

`SessionEnd` was chosen over the alternatives deliberately: `SessionStart` runs *after* Claude Code has already read `settings.json`, and `Stop` fires on every assistant turn, which would delete a deliberate in-session `/model` step-up out from under the running session.

Two backstops cover the case where `SessionEnd` never fires — a killed process, a destroyed terminal:

- `.githooks/pre-commit` blocks any commit that stages `settings.json` with one of those keys still present, and prints the fix command.
- `playbooks/deploy.yml` runs `git config core.hooksPath .githooks` against this repo on every deploy, so the pre-commit hook is wired up automatically with no per-clone step.

The machine-local default model is not one of these keys — it lives in `~/.local/bin/claude-auto` as `ANTHROPIC_MODEL`, which outranks `settings.json`.
