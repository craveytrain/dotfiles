# Technology Stack: Runtime conf.d Sourcing Migration

**Project:** Dotfiles v1.1 Runtime Includes
**Researched:** 2026-03-10
**Scope:** Stack additions for replacing Ansible-merged files with runtime conf.d sourcing

## Recommended Stack

### Zsh conf.d Sourcing

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Zsh glob with `(N)` qualifier | Zsh 5.9 (installed) | Source `~/.zsh/conf.d/*.sh` safely | `(N)` (NULL_GLOB) prevents errors when directory is empty; no external dependencies |
| Numeric prefix convention | N/A | `00-base.sh`, `10-editor.sh`, etc. | Deterministic ordering via `*(N)` which sorts lexicographically by default |

**Exact sourcing pattern for `.zshrc`:**

```zsh
# Source all conf.d files (sorted lexicographically, safe if empty)
for conf in "$HOME/.zsh/conf.d/"*.sh(N); do
  source "$conf"
done
```

**Why this pattern:**
- `(N)` glob qualifier is zsh-specific and prevents "no matches found" errors when the directory is empty or missing. Without it, zsh throws an error on empty globs (unlike bash with `nullglob`).
- `*.sh` extension gives clear intent. Using `.zsh` extension is also fine but `.sh` matches existing file conventions in this repo (e.g., `aliases.sh`, `environment.sh`).
- The `for` loop is readable and debuggable. Alternatives like `source ~/.zsh/conf.d/*(N)` don't work because `source` takes one argument.
- No need for `(on)` (numeric sort qualifier) because `*(N)` already sorts lexicographically by name, which is what you want with zero-padded numeric prefixes.

**What NOT to use:**
- `setopt NULL_GLOB` globally: Side effects on other globs throughout the session. Use `(N)` qualifier instead, which is per-glob.
- `for f in ~/.zsh/conf.d/*`: Missing `(N)` means it breaks on empty directories.
- `source ~/.zsh/conf.d/*.sh 2>/dev/null`: Silences real errors, not just missing files.
- Bash-style `shopt -s nullglob`: Not available in zsh. Use `(N)` qualifier.

**Confidence:** HIGH - Zsh glob qualifiers are documented in zshexpn(1) and stable since zsh 4.x. Tested on zsh 5.9.

### Fish conf.d (Native)

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Fish native `conf.d/` | Fish 4.2.1 (installed) | Source `~/.config/fish/conf.d/*.fish` automatically | Built-in to fish; no sourcing loop needed |

**How it works:**

Fish automatically sources all `*.fish` files from `~/.config/fish/conf.d/` at startup, *before* `config.fish`. Files load in alphabetical order.

**What modules stow:**

Each module places its conf.d file at:
```
modules/<name>/files/.config/fish/conf.d/<NN>-<name>.fish
```

Stow creates a symlink:
```
~/.config/fish/conf.d/10-shell.fish -> ~/dotfiles/modules/shell/files/.config/fish/conf.d/10-shell.fish
```

**Key behaviors:**
- Files source before `config.fish`, so `config.fish` can override conf.d settings
- All conf.d files run on every shell startup (interactive, login, non-interactive)
- Use `status --is-interactive` and `status --is-login` guards inside conf.d files when appropriate
- Basename deduplication: if same filename exists in user and system conf.d, user wins

**What NOT to use:**
- Manual sourcing loop in `config.fish`: Redundant. Fish already does this natively.
- Placing files directly in `~/.config/fish/` without the `conf.d/` subdirectory: Won't auto-source.
- Relying on conf.d load order to override `config.fish`: Conf.d loads first, so put overrides in `config.fish` or use higher-numbered conf.d files.

**Confidence:** HIGH - Native fish feature, documented at [fishshell.com](https://fishshell.com/docs/current/). Verified on fish 4.2.1.

### Mise conf.d (Native)

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Mise native `conf.d/` | mise 2025.12.12 (installed) | Load `~/.config/mise/conf.d/*.toml` automatically | Built-in directory scanning; files load alphabetically and merge |

**How it works:**

Mise natively scans `~/.config/mise/conf.d/*.toml` and loads all files in alphabetical order. This was verified directly on the installed version -- mise recognized and attempted to parse a test file placed in `~/.config/mise/conf.d/`.

**What modules stow:**

Each module places its conf.d file at:
```
modules/<name>/files/.config/mise/conf.d/<NN>-<name>.toml
```

**Trust requirement:**

Mise requires config files to be trusted before it will execute them. Two approaches:

1. **Per-file trust** (simple, explicit):
   ```bash
   mise trust ~/.config/mise/conf.d/10-dev-tools.toml
   mise trust ~/.config/mise/conf.d/20-node.toml
   ```

2. **Trusted config paths** (better for automation):
   In `~/.config/mise/config.toml`:
   ```toml
   [settings]
   trusted_config_paths = ["~/.config/mise/conf.d"]
   ```
   Or via environment variable:
   ```bash
   export MISE_TRUSTED_CONFIG_PATHS="$HOME/.config/mise/conf.d"
   ```

Use option 2. It's one-time setup and covers all future conf.d additions without requiring `mise trust` after each new module.

**TOML section headers:**

Each conf.d file is a standalone TOML file, so it needs its own section headers:

```toml
# ~/.config/mise/conf.d/10-dev-tools.toml
[settings]
asdf_compat = true

[tools]
python = "3.13.2"
```

```toml
# ~/.config/mise/conf.d/20-node.toml
[tools]
node = "latest"
pnpm = "latest"
```

This is a significant improvement over the current merged file approach, where the node module had to omit the `[tools]` header to avoid duplication when concatenated.

**What NOT to use:**
- `MISE_CONFIG_FILE` environment variable: Points to a single file, doesn't solve the multi-module problem.
- Mise `includes` directive: Only exists for tasks, not for config files.
- Symlinks to a single merged file: Defeats the purpose of runtime sourcing.

**Confidence:** HIGH - Verified by testing on installed mise 2025.12.12. Config was recognized (failed on trust, not parsing).

### Supporting Infrastructure

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| GNU Stow | Existing (via shell module) | Create conf.d symlinks from module files to home directory | Already in use; conf.d files are just more stow targets |
| Ansible | Existing 2.9+ | Deploy modules, create conf.d directories | May need tasks to create conf.d directories before stow runs |

**No new packages or dependencies required.** This migration uses capabilities already present in the installed versions of zsh, fish, and mise.

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Zsh sourcing | `for` loop with `(N)` | `source` with redirect | Silences real errors |
| Zsh sourcing | `(N)` qualifier per-glob | `setopt NULL_GLOB` global | Side effects on all globs |
| Fish conf.d | Native `conf.d/` dir | Manual sourcing in `config.fish` | Redundant; fish already does it |
| Mise config split | Native `conf.d/` dir | Multiple `mise.toml` in dir hierarchy | Hierarchy-based; doesn't map to module concept |
| Mise trust | `trusted_config_paths` setting | Per-file `mise trust` | Doesn't scale; breaks on new module additions |
| File extension (zsh) | `.sh` | `.zsh` | `.sh` matches existing repo convention |
| Ordering scheme | 2-digit prefix (00-99) | No prefix | Nondeterministic ordering across modules |

## Numeric Prefix Convention

All conf.d files across zsh, fish, and mise use the same ordering scheme:

| Range | Purpose | Example |
|-------|---------|---------|
| 00-09 | Core/base (shell module, settings) | `00-settings.toml`, `00-environment.sh` |
| 10-19 | Infrastructure tools (editor, shell utilities) | `10-editor.sh`, `10-shell.fish` |
| 20-29 | Development tools (mise activation, dev-tools) | `20-dev-tools.toml`, `20-mise.sh` |
| 30-39 | Language/runtime (node, python) | `30-node.toml` |
| 40-49 | Application tools (git, 1password) | `40-git.sh` |
| 50-89 | Reserved for future use | |
| 90-99 | Late-loading / overrides | `99-local.sh` |

**Why 2-digit, not 3-digit:** You have 11 modules. Even with growth, 100 slots is plenty. 2-digit prefixes are easier to read and type.

## Integration with Existing Stow/Ansible Workflow

### What Changes

**Before (merged):**
```
Module defines:     mergeable_files: ['.zsh/aliases.sh']
Ansible does:       Concatenates all modules' .zsh/aliases.sh into merged output
Stow deploys:       Merged file symlinked to ~/.zsh/aliases.sh
Edit workflow:      Edit source -> run Ansible -> changes visible
```

**After (conf.d):**
```
Module defines:     stow_dirs: [<module-name>]
Module contains:    files/.zsh/conf.d/10-<module>.sh
Stow deploys:       Symlink ~/.zsh/conf.d/10-<module>.sh -> repo file
Edit workflow:      Edit source -> changes visible immediately (symlink)
```

### What Stays the Same

- `config.yml` still declares `stow_dirs`
- Ansible still runs stow via ansible-role-dotmodules
- Module directory structure under `files/` still mirrors home directory
- `homebrew_packages`, `homebrew_casks`, `register_shell` all unchanged

### Directory Creation

Stow won't create parent directories that don't exist. The conf.d directories need to exist before stow runs:

```
~/.zsh/conf.d/                    # Zsh conf.d (NEW - needs creation)
~/.config/fish/conf.d/            # Fish conf.d (may already exist from fish plugins)
~/.config/mise/conf.d/            # Mise conf.d (NEW - needs creation)
```

Options for creation:
1. **Ansible pre-task**: Add a task that creates these directories before stow runs. Cleanest approach, fits the existing automation model.
2. **Stow folding**: If a module is the only contributor to a conf.d dir, stow will create a symlink to the directory itself rather than individual files. This is fine for single contributors but becomes a problem when multiple modules contribute. Use `--no-folding` or ensure at least the directory exists first.

Use option 1 (Ansible pre-task). It's explicit and avoids stow folding surprises.

## Current Mergeable File Mapping

For reference, here's every module that uses `mergeable_files` and what it contributes:

| Module | Mergeable File | Content |
|--------|---------------|---------|
| zsh | `.zshrc` | P10k, sourcing, compinit, plugins |
| zsh | `.zsh/aliases.sh` | Shell aliases (cd, ls, etc.) |
| zsh | `.zsh/environment.sh` | DOTFILES, XDG, PATH, CDPATH, LS_COLORS |
| dev-tools | `.zshrc` | `eval "$(mise activate zsh)"` |
| dev-tools | `.config/fish/config.fish` | `mise activate fish --shims` |
| dev-tools | `.config/mise/config.toml` | Python version, settings |
| shell | `.zsh/environment.sh` | EZA_COLORS |
| shell | `.config/fish/config.fish` | EZA_COLORS (fish syntax) |
| editor | `.zsh/aliases.sh` | `alias e=...` (editor alias) |
| editor | `.zsh/environment.sh` | EDITOR, VISUAL exports |
| editor | `.config/fish/config.fish` | Editor abbrs (ia, marked) |
| fish | `.config/fish/config.fish` | Full fish config (env, abbrs, prompt) |
| node | `.config/mise/config.toml` | node, pnpm versions |

**Total: 6 unique mergeable files across 6 modules.**

## Sources

- Zsh glob qualifiers: `man zshexpn` (installed locally, zsh 5.9)
- Fish conf.d: [Fish Shell Documentation](https://fishshell.com/docs/current/)
- Fish conf.d sourcing order: [fish-shell/fish-shell#8553](https://github.com/fish-shell/fish-shell/issues/8553)
- Mise configuration: [mise.jdx.dev/configuration](https://mise.jdx.dev/configuration.html)
- Mise settings (trusted_config_paths): [mise.jdx.dev/configuration/settings](https://mise.jdx.dev/configuration/settings.html)
- Mise trust: [mise.jdx.dev/cli/trust](https://mise.jdx.dev/cli/trust.html)
- Dotfiles conf.d patterns: [z0rc/dotfiles](https://github.com/z0rc/dotfiles), [mattmc3/zdotdir](https://github.com/mattmc3/zdotdir)

---

**Analysis completed:** 2026-03-10
**Confidence level:** HIGH across all three technologies (zsh, fish, mise)
**Key finding:** No new dependencies needed. All three tools support conf.d natively or via simple glob patterns already available in installed versions.
