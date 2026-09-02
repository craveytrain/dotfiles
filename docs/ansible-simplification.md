# Simplifying or replacing the Ansible deployment layer

Working notes and a recommendation, written to be picked up by an agent with no prior context. Everything below was measured against this repo on 2026-09-02, not inferred. Commands are given so you can re-verify rather than trust.

**Status:** The recommendation was accepted and implemented in this repository on 2026-09-02. Deployment on each Mac remains the final real-world verification. The earlier measurements are retained below to explain the decision.

## Why this exists

The repo owner asked whether Ansible is too heavy-handed for what this repo does, noting they never remember how it works. This is the investigation that followed.

## Architecture before simplification

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

## How other dotfile systems solve this

This survey compares operating models, not feature counts. The relevant question is how each option handles this repo's combination of package installation, live config files, module ownership, occasional post-install actions, and one privileged operation.

### GNU Stow plus a small runner

This is the baseline used by many hand-built dotfile repositories: keep package-shaped directory trees, let Stow own the symlinks, put packages in a `Brewfile`, and use a `Makefile` or shell script to sequence `brew bundle`, `stow`, and post-install commands.

This fits the current file layout especially well because the repo already uses Stow as the real deployment mechanism. Stow is deliberately stateless and refuses to overwrite conflicting target files; unstowing removes links rather than the source files they point to. Homebrew Bundle provides the package-side desired state, including `brew bundle check` and an explicit `brew bundle cleanup`.

The tradeoff is that the runner becomes a small configuration-management implementation. It must provide its own change reporting, error handling, architecture checks, restricted-machine flag, and safe conflict policy. A `Makefile` improves discoverability but not those semantics.

Sources: [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html), [Homebrew Bundle documentation](https://docs.brew.sh/Brew-Bundle-and-Brewfile)

### chezmoi

chezmoi manages a source state and applies the minimum changes needed to make the home directory match it. It has first-class dry runs, diffs, templates, machine-specific data, and scripts that run always, once, or when their content changes. Its own package-installation guide recommends declarative package data rendered into a `run_onchange_` script that invokes `brew bundle`.

This is the strongest dedicated replacement if this repo later needs host-specific templates or secret integration. It is not a simplification for the current goal: adopting it would replace the existing live-symlink workflow and module tree with chezmoi's source-state conventions, while package management and Fish/mise hooks would still be scripts. It solves more problems than this repo currently has.

Sources: [chezmoi quick start](https://www.chezmoi.io/quick-start/), [scripts](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/), [declarative package installation](https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/)

### yadm

yadm treats `$HOME` as a Git work tree, avoiding symlinks and a separate source-to-target mapping. It supports host/OS/class alternates and offers a standard `yadm bootstrap` hook. Its documentation explicitly uses an idempotent shell script plus a Brewfile as the macOS bootstrap example.

That is attractive for a flat collection of dotfiles, but it weakens this repo's strongest design property: each module currently owns both its files and package declarations in one directory. Package installation, shell registration, Fish sync, and mise installation would all move into a user-written bootstrap program. This would trade visible Ansible complexity for hidden script complexity.

Sources: [yadm overview](https://yadm.io/docs/overview), [bootstrap](https://yadm.io/docs/bootstrap), [alternate files](https://yadm.io/docs/alternates)

### Dotbot

Dotbot is a lightweight bootstrapper intended to be checked into the dotfiles repository. A YAML file declares links, directory creation, cleanup, and shell commands, and third-party plugins add package-manager support. It is closer than chezmoi or yadm to the desired one-repo experience.

For this repo, however, Dotbot would duplicate what Stow already does and move Homebrew support either into shell commands or another plugin dependency. It does not remove the need to design idempotent hooks or privileged shell registration. Vendoring a general bootstrap framework is more code and concepts than keeping a small purpose-built Ansible role.

Source: [Dotbot repository and documentation](https://github.com/anishathalye/dotbot)

### Nix, Home Manager, and nix-darwin

Home Manager can declaratively manage packages, programs, configuration files, environment variables, and arbitrary files with strong reproducibility and rollback behavior. Combined with nix-darwin it can also manage macOS system state.

This is the most capable option and the least aligned with the stated simplification goal. It introduces Nix as a second package ecosystem beside or instead of Homebrew, a new language and state model, and significantly more bootstrap policy. It makes sense only if reproducible whole-machine state becomes the primary goal.

Source: [Home Manager manual](https://nix-community.github.io/home-manager/)

### Ansible dotfile repositories

Ansible remains common when a dotfiles repository is also a machine-provisioning repository: installing packages across operating systems, applying macOS defaults, managing services, handling secrets, or selecting host profiles. In those repositories, roles and inventory model real variation.

This repo intentionally does much less. It targets local macOS, leaves full provisioning out of scope, and has only four module keys. That makes a generic reusable role unjustified, but it does not make Ansible's local primitives useless. Check mode, tags, privilege boundaries, idempotent Homebrew modules, and structured failure output all directly serve current requirements.

## Decision matrix

Scores are relative to this repo: 5 is best. "Migration safety" rewards preserving current file layout and behavior; "headroom" rewards useful support for plausible future needs rather than maximum theoretical capability.

| Option | Simplicity | Module fit | Idempotence / preview | Migration safety | Headroom |
| --- | ---: | ---: | ---: | ---: | ---: |
| Keep the external role unchanged | 2 | 3 | 2 | 5 | 3 |
| Vendor the external role unchanged | 3 | 3 | 2 | 5 | 3 |
| Replace it with a small in-repo Ansible role | 4 | 5 | 4 | 5 | 4 |
| Stow + Brewfile + shell/Make runner | 5 | 4 | 3 | 4 | 3 |
| chezmoi | 3 | 2 | 5 | 2 | 5 |
| yadm | 4 | 2 | 3 | 2 | 3 |
| Dotbot | 3 | 3 | 3 | 3 | 3 |
| Home Manager / nix-darwin | 1 | 3 | 5 | 1 | 5 |

## Recommendation

**Keep Ansible, but replace the external generic role with a small purpose-built role inside this repository.**

The original recommendation to wait was too binary: it compared leaving the external role alone with removing Ansible entirely. Bringing a reduced role into this repo is the lower-risk middle path and best matches the actual goal. It removes the owner-maintained cross-repository dependency, makes all deployment behavior inspectable beside the modules that use it, and preserves Ansible features that would otherwise need to be rebuilt.

Do not copy the 299-line role unchanged. That would improve discoverability without simplifying the system. Build the in-repo role from the four supported keys and current behavior, deleting remote-clone support, generic scalar merging, MAS support, git-repository installation, debug output, and unused tap handling unless a current module needs it. The role should be specific enough that `roles/dotmodules/tasks/main.yml` reads as a direct description of this repository.

Add a repository-root `./deploy` wrapper as the only documented entry point. It should pass through useful Ansible arguments and provide a memorable restricted mode, for example `./deploy --restricted`, which translates to `--skip-tags register_shell`. The wrapper removes command memorization without replacing Ansible's execution semantics.

Keep the module `config.yml` files. They are already the simplest and most coherent part of the design. Move module-specific post-install tasks into the corresponding module's deployment definition only if this can be done without allowing arbitrary shell snippets in data. Prefer named task includes such as optional `modules/<name>/tasks.yml`; this keeps behavior reviewable and lets each task express `changed_when`, check-mode behavior, and conditions correctly.

Use Homebrew's Ansible modules initially rather than generating a Brewfile. A generated file adds another derived artifact and a direct Brewfile would centralize package ownership away from modules. Reconsider generation only if package removal or `brew bundle cleanup` becomes an explicit requirement. Never run cleanup implicitly on a personal machine; Homebrew correctly makes it a separate operation because it can remove intentionally installed packages not represented in this repo.

For Stow conflicts, choose safety over automation. Drop the broken delete-and-replace behavior rather than repairing it: silently deleting an existing home-directory file is dangerous, and the documented manual move/compare workflow is appropriate for the rare first-run conflict. Run Stow without an unconditional unstow first, use check/simulate output for change reporting if practical, and fail with a clear message on conflict.

Remove both `ansible-role-dotmodules` and `geerlingguy.mac` from `requirements.yml`. Keep `community.general` while its Homebrew and local Git configuration modules are used. This leaves one mainstream collection dependency fetched by Galaxy, but removes the second repository the owner must design, release, and understand.

### Proposed implementation shape

```text
deploy
roles/
└── dotmodules/
    └── tasks/
        ├── main.yml
        ├── module.yml
        ├── register-shell.yml
        └── stow.yml
modules/
└── <name>/
    ├── config.yml
    ├── tasks.yml        # optional, module-specific Ansible tasks
    └── files/
```

The enabled-module list should remain in one obvious place. `playbooks/deploy.yml` is acceptable; moving it to a plainly named vars file is also reasonable if it makes the playbook easier to scan. Do not add inventory abstractions while the only target is localhost.

### Acceptance criteria

- A converged run reports no changes. This is strictly better than today's `changed=18` (finding 3) and is the clearest signal the rewrite worked.
- All 27 formulae and 7 casks still install; all 9 stowing modules still produce the same symlinks. Diff `ls -laR` of the stowed paths before and after.
- A real non-symlink conflict is preserved and causes an actionable failure; deployment must not delete it.
- Restricted-machine path still works without sudo.
- All 5 current `post_tasks` still happen, with `mise install` still reading stderr for its no-op signal.
- `ansible-playbook --check` does not mutate files or run post-install commands that lack a meaningful preview.
- A new Mac needs no owner-maintained role download; `./deploy` bootstraps or clearly reports the remaining public prerequisites.
- `docs/REFERENCE.md` and `README.md` updated: deployment commands, "How deployment works", and the troubleshooting entries that reference Ansible.

### When to reconsider Ansible

Move to Stow + Brewfile + a small runner if, after internalizing and reducing the role, Ansible still feels harder to operate than the behavior it protects. The concrete signal is that the in-repo role cannot stay small and direct.

Move to chezmoi if machine-specific rendering, secret material, or substantial per-host variation becomes a real requirement. Move to Home Manager only if reproducible package and system state becomes more important than retaining the current Homebrew-native macOS workflow.

After the in-repo replacement has run successfully on every machine, archive `ansible-role-dotmodules` rather than maintaining two implementations. Also ensure the playbook continues setting clone-local exclusions and `core.hooksPath`; per-clone manual setup has already proved unreliable.

## Implementation

The accepted implementation adds:

- `./deploy` as the documented entry point, with `--restricted` translating to the `register_shell` tag exclusion.
- `roles/dotmodules`, which supports only the four module keys this repository uses.
- Optional per-module `tasks.yml` files; Fish plugin synchronization and mise installation now live with their modules.
- A Stow simulation before deployment, so converged runs report no Stow changes and conflicts stop without deleting existing files.

The owner-maintained role and unused `geerlingguy.mac` dependency were removed from `requirements.yml`. `community.general` remains for its Homebrew and local Git configuration modules.
