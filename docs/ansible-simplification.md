# Simplifying or replacing the Ansible deployment layer

Working notes and a recommendation, written to be picked up by an agent with no prior context. Everything below was measured against this repo on 2026-09-02, not inferred. Commands are given so you can re-verify rather than trust.

**This document is not a decision.** It ends with a recommendation and a set of open questions for the repo owner. Read "Recommendation" before doing anything.

## Why this exists

The repo owner asked whether Ansible is too heavy-handed for what this repo does, noting they never remember how it works. This is the investigation that followed.

## Current architecture

Deployment is `ansible-playbook -i playbooks/inventory playbooks/deploy.yml`, which does two things:

1. Invokes the external role `ansible-role-dotmodules` with a list of 11 modules to install.
2. Runs 5 `post_tasks` defined inline in the playbook.

The role is at `https://github.com/craveytrain/ansible-role-dotmodules.git`, installed to `~/.ansible/roles/ansible-role-dotmodules` by `ansible-galaxy install -r requirements.yml`. **The repo owner owns that role too** — it is not third-party. This is the single most important fact in this document: the complexity that is hard to remember lives in the owner's own code, split across two repositories.

Each module is `modules/<name>/config.yml` plus `modules/<name>/files/` mirroring paths relative to `$HOME`. Stow symlinks the `files/` tree into `$HOME`.

## What Ansible actually does, measured

The role is 299 lines across 4 task files with 38 named tasks. Only **five** perform real work:

| Action | Ansible module |
| --- | --- |
| Install formulae | `community.general.homebrew` |
| Install casks | `community.general.homebrew_cask` |
| Add taps | `community.general.homebrew_tap` |
| Add a shell to `/etc/shells` | `ansible.builtin.lineinfile` |
| Symlink module files | `command: stow --no-folding` |

The remaining 33 tasks are `set_fact` plumbing (15 calls), plus `find`, `stat`, `file`, `git`, `debug`, and `fail`.

Across all 11 modules, only **four** config keys are ever used:

```
stow_dirs          9 modules
homebrew_packages  7 modules
homebrew_casks     3 modules
register_shell     1 module (fish)
```

Verify with:

```bash
grep -hoE "^[a-z_]+:" modules/*/config.yml | tr -d ':' | sort | uniq -c | sort -rn
```

No module declares a tap, so the `homebrew_tap` task always skips. There is no templating, no handlers, no conditionals, no inter-module dependencies, and no use of Ansible's inventory or connection model — everything runs against `localhost`.

The total declared surface is 27 Homebrew formulae and 7 casks:

```bash
# prints the authoritative list
python3 - <<'PY'
import glob, re
pkgs, casks = [], []
for f in sorted(glob.glob("modules/*/config.yml")):
    key = None
    for line in open(f):
        s = line.rstrip()
        if re.match(r'^\w+:', s):
            key = s.split(':')[0]; continue
        m = re.match(r'^\s+-\s+(\S+)', s)
        if m and key in ("homebrew_packages", "homebrew_casks"):
            (pkgs if key == "homebrew_packages" else casks).append(m.group(1))
print(len(pkgs), "formulae:", " ".join(sorted(pkgs)))
print(len(casks), "casks:", " ".join(sorted(casks)))
PY
```

So the entire job is: *install these Homebrew things, symlink these directories, add fish to `/etc/shells`, then run a handful of follow-up commands.*

## Findings

### 1. `geerlingguy.mac` is a dead dependency

`requirements.yml` requires the `geerlingguy.mac` collection. Nothing references it — not the playbook, not any module, not the role.

```bash
grep -rn "geerlingguy\|homebrew_cask_apps\|mas_" playbooks/ modules/   # no matches
```

Safe to drop regardless of what happens to Ansible.

### 2. The role's only non-trivial logic is broken and has been silently dead

`tasks/stow_module.yml` tries to detect files that would block stow and delete them first. It does not work.

`dotmodules_path` is derived from `dotmodules.repo`, which the playbook sets to `file://{{ playbook_dir }}/../modules`. After stripping the scheme that is the literal, unresolved string `/Users/<user>/dotfiles/playbooks/../modules`. But `ansible.builtin.find` returns *resolved* paths. So this strip at line 26 never matches:

```yaml
| map('regex_replace', '^' + dotmodules_path + '/' + module_name + '/files/', '')
| map('regex_replace', '^', home_dir + '/')
```

The first `regex_replace` is a no-op, then the second prepends `$HOME/` to a path that is already absolute. The result is a doubled path, visible in any run's output:

```
/Users/<user>//Users/<user>/dotfiles/modules/claude/files/.claude/settings.json
```

Those paths never exist, so the `stat` reports not-found for every file and the "Remove existing files" task never fires. The conflict-resolution feature is entirely dead.

Consequence worth noting: `docs/REFERENCE.md` has a troubleshooting entry titled "Existing file blocks Stow" telling you to move the file aside by hand. That is a documented manual workaround for a problem this dead code was written to solve automatically.

Two secondary problems in the same file: the path is interpolated into a regex without escaping (`.` and `..` are regex metacharacters), and the unstow at line 4 carries `ignore_errors: yes`, which masks real failures.

### 3. The unstow/restow cycle makes every run report changes

`stow_module.yml` unconditionally unstows then restows each module. A fully converged run still reports `changed=18`, so `changed` carries no signal about whether anything actually differed. Verify:

```bash
ansible-playbook -i playbooks/inventory playbooks/deploy.yml --skip-tags register_shell
# converged: ok=127 changed=18 failed=0
```

### 4. The role carries git-clone machinery this repo never uses

`tasks/main.yml` branches on whether `dotmodules.repo` is local, and clones a remote repo to `dotmodules.dest` (`~/.dotmodules`) when it is not. This repo always passes a local `file://` path, so the clone branch and the `dest` default are permanently dead here.

### 5. Per-module post-install commands have nowhere correct to live

`AGENTS.md` states "Modules are self-contained and independent." The role has no hook for per-module commands, so two commands that belong to specific modules were added to `playbooks/deploy.yml` `post_tasks` instead:

- `mise install` belongs to `dev-tools`
- the Fish plugin sync belongs to `fish`

Both are guarded on module membership (`when: "'fish' in dotmodules.install"`), which works but centralizes module-specific knowledge in the playbook. This is the convention bending. One or two instances are tolerable; a third is the signal that the structure needs to change.

### 6. Per-clone setup steps are a recurring failure mode

Two separate instances of "this had to be done by hand on each machine, and wasn't":

- `.git/info/exclude` was supposed to ignore `docs/AI_USAGE.md` (commit `3c8adf7` moved it out of `.gitignore`). That file is per-clone and untracked, and had never been populated on this machine — leaving a work-referencing file exposed as plain untracked in a public repo.
- `core.hooksPath` for `.githooks/` needed setting per clone. This is now automated as a `post_task` precisely because of the above.

**Any replacement must keep automating per-clone git configuration.** Do not regress this into a README instruction.

## Constraints any replacement must satisfy

From `AGENTS.md` and `CLAUDE.md` (same file; `CLAUDE.md` is a symlink to `AGENTS.md`):

- **Platform**: macOS Apple Silicon primary. A separate minimal bash setup for Debian/Pi OS lives in `linux/` and is out of scope. No Windows, no full Linux desktop parity.
- **Privileges**: must support restricted execution on managed machines. Today that is `--skip-tags register_shell`; the equivalent escape hatch must survive, and the *only* step needing elevation is writing `/etc/shells`.
- **Idempotent**: safe to run repeatedly.
- **Declarative over imperative**: prefer configuration over shell scripting where there is a choice.
- **Modules self-contained and independent**: no hard cross-module dependencies.
- **The repo is public.** Nothing referencing the owner's employer or work specifics goes in, inert or not.
- **Markdown is soft-wrapped.** Do not hard-wrap prose to a column width (this was standardized in PR #38).

Behavioral details a replacement must preserve:

- Stow runs with `--no-folding`. Removing it changes the symlink shape (directory symlinks instead of per-file), which breaks the "new file in a module needs a re-stow, edits go live immediately" model that `docs/REFERENCE.md` documents.
- `register_shell` accepts either a bare shell name or an absolute path, and resolves the Homebrew prefix by architecture (`/opt/homebrew` on arm64, `/usr/local` on x86_64). See `tasks/register_shell.yml`.
- `~/.claude/hooks/` is stowed as **per-file** symlinks into a real directory, not a directory symlink. A new hook file therefore requires a deploy before it is live.

The current 5 `post_tasks` in `playbooks/deploy.yml`, all of which must be preserved:

1. `core.hooksPath` → `.githooks` (via `community.general.git_config`, scope local)
2. `mise install` — `changed_when` reads **stderr**, not stdout; mise writes `all tools are installed` to stderr when there is nothing to do. Keying on stdout makes it report `changed` on every run.
3. Read tracked `fish_plugins` (slurp)
4. Read installed plugins (`fish -c 'fisher list'`)
5. `fish -c 'fisher update'`, only when the two lists differ

On #5: `fisher update` reinstalls every plugin and always prints `Updated N plugin/s`, so it has no "nothing to do" signal. It is triggered on membership drift rather than run blind. Note this catches plugins added to or removed from `fish_plugins`, but not upstream releases — refreshing versions is still a manual `fisher update`. `fish_plugins` pins no versions; it supports `@tag` if determinism is ever wanted.

Deliberately still manual, do not automate:

- `tide configure --auto ...` writes per-machine universal variables as a one-time baseline. The tracked `10-fish-core.fish` layers `set -g` overrides on top of it. Re-running on every deploy would discard the baseline. The root README explains this inline.
- `chsh -s /opt/homebrew/bin/fish` — already covered by `register_shell` where privileges allow.

## Recommendation

**Keep Ansible for now. Do not migrate for its own sake.**

The honest read is that Ansible is oversized for four config keys and five real actions, and the owner is right to be suspicious. But replacing it buys ergonomics, not capability, and the cost is rewriting a working multi-machine setup. The part that is hard to remember is the role internals, which are touched almost never. The part actually touched day to day is a 4-key `config.yml`, which is already about as simple as it gets.

**The trigger to migrate is needing to change the role.** Findings 2 and 5 mean that moment is closer than it looks: the role has dead broken code that should be fixed, and per-module post-install commands have no correct home. If you are about to edit `ansible-role-dotmodules`, do the collapse instead of the patch.

### If migrating: the shape

Collapse the role into this repo as a single script. One repo instead of two, no `ansible-galaxy` bootstrap, no Ansible, no collections. Estimated 100–150 lines.

The script should:

1. Read `modules/<name>/config.yml` for each module in an install list (keep the list in one place; it is currently `dotmodules.install` in `playbooks/deploy.yml`).
2. Aggregate `homebrew_packages` and `homebrew_casks` across modules and install them. Either shell out to `brew install` or generate a `Brewfile` and use `brew bundle`. **`brew bundle` is worth considering**: it is Homebrew-native and supports `brew bundle check` / `cleanup`, which detects drift and can remove things you deleted from a module's config — something the current `homebrew` task cannot do (it only ever adds).
3. `stow --no-folding -d modules/<name> -t $HOME files` per module with `stow_dirs`.
4. Register `register_shell` in `/etc/shells`, gated behind a flag equivalent to `--skip-tags register_shell`, with the same arch-based prefix resolution.
5. Run per-module post-install commands — the thing the role cannot currently express. A `post_commands` key in `config.yml` would let `mise install` and the Fish plugin sync move into `dev-tools` and `fish` where they belong, satisfying the self-containment convention and resolving finding 5.
6. Set `core.hooksPath` and any other per-clone git configuration (finding 6).

Preserve the per-module `config.yml` structure. Do not centralize everything into one Brewfile at the cost of module self-containment — the co-location of "what to install" with "what to stow" per tool is the part of this design worth keeping. A generated Brewfile assembled *from* the module configs gets both.

### Acceptance criteria for a migration

- A converged run reports no changes. This is strictly better than today's `changed=18` (finding 3) and is the clearest signal the rewrite worked.
- All 27 formulae and 7 casks still install; all 9 stowing modules still produce the same symlinks. Diff `ls -laR` of the stowed paths before and after.
- The stow-conflict handling that finding 2 shows is dead either works or is deliberately dropped — decide explicitly, do not port the bug.
- Restricted-machine path still works without sudo.
- All 5 current `post_tasks` still happen, with `mise install` still reading stderr for its no-op signal.
- `docs/REFERENCE.md` and `README.md` updated: deployment commands, "How deployment works", and the troubleshooting entries that reference Ansible.

## Open questions for the repo owner

1. **Migrate now or wait for the trigger?** The recommendation is wait. Overriding that is entirely reasonable if the two-repo split is the thing that actually bothers you.
2. **`brew bundle` or direct `brew install`?** Bundle adds drift detection and cleanup; direct install is fewer moving parts.
3. **Should stow-conflict handling exist at all?** It has been dead this whole time and nothing was obviously worse for it. Dropping it and keeping the manual troubleshooting note is a legitimate answer.
4. **Fix or delete `ansible-role-dotmodules`?** If Ansible stays, finding 2 should be fixed there. If it goes, the repo can be archived.

## Independent of any decision

These are worth doing whether or not Ansible stays:

- Drop `geerlingguy.mac` from `requirements.yml` (finding 1).
- Fix or delete the dead path logic in `stow_module.yml` (finding 2).
- Add `docs/AI_USAGE.md` to `.git/info/exclude` on every other clone of this repo (finding 6). It is per-clone and untracked, so no commit can do this for you.
