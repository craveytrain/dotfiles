# Architecture: conf.d Runtime Sourcing Migration

**Domain:** Dotfiles configuration management (Stow + Ansible)
**Researched:** 2026-03-10
**Focus:** Migrating from Ansible-time merged files to runtime conf.d sourcing

## Current Architecture (Merge-Based)

### How It Works Today

```
Module files/            Ansible merge_files.yml        ~/.dotmodules/merged/         Stow          ~/
                         (concatenates at deploy)                                      (symlinks)

zsh/files/.zshrc    ──┐
                      ├──> merged .zshrc ──────────> ~/.dotmodules/merged/.zshrc ──> ~/.zshrc (symlink)
dev-tools/files/.zshrc┘

zsh/files/.zsh/aliases.sh ──┐
                            ├──> merged aliases.sh ──> ~/.dotmodules/merged/.zsh/aliases.sh ──> ~/.zsh/aliases.sh
editor/files/.zsh/aliases.sh┘
```

### Current Merge Participants

| Target File | Contributing Modules | Content |
|---|---|---|
| `.zshrc` | zsh, dev-tools | zsh: full shell init (p10k, plugins, sourcing); dev-tools: `eval "$(mise activate zsh)"` |
| `.zsh/aliases.sh` | zsh, editor | zsh: general aliases (ls, grep, ip, mkdir); editor: `alias e='${(z)VISUAL:-${(z)EDITOR}}'` |
| `.zsh/environment.sh` | zsh, editor, shell | zsh: PLATFORM, EDITOR, PAGER, colors, CDPATH; editor: EDITOR/VISUAL (duplicate); shell: EZA_COLORS |
| `.config/fish/config.fish` | fish, dev-tools, editor, shell | fish: full config (env, abbrs, functions, prompt); dev-tools: mise activate; editor: app launcher abbrs; shell: EZA_COLORS |
| `.config/mise/config.toml` | dev-tools, node | dev-tools: [settings] + [tools] python; node: node + pnpm versions (no [tools] header) |

### Problems With Current Approach

1. **Edit-deploy-test cycle**: Changing an alias requires running Ansible to regenerate the merged file
2. **Fragile TOML merging**: node/config.toml must omit `[tools]` header because concatenation would create duplicate headers
3. **Hidden composition**: You can't tell from looking at `~/.zshrc` which module contributed what (it's a merged blob with comments)
4. **Duplicate content**: editor and zsh both define EDITOR/VISUAL in environment.sh

## Target Architecture (conf.d-Based)

### Design Principle

Each module stows its own conf.d fragment file. The shell (or tool) sources all fragments at runtime. No Ansible merging step.

### Zsh conf.d

```
~/.zshrc                          (owned by zsh module, stowed directly)
  sources ~/.zsh/conf.d/*.sh      (glob loop added to .zshrc)
  sources ~/.zsh/aliases.sh       (owned by zsh module, single file)
  sources ~/.zsh/functions.sh     (owned by zsh module, single file)
  sources ~/.zsh/utility.zsh      (owned by zsh module, single file)

~/.zsh/conf.d/                    (directory populated by Stow from multiple modules)
  10-environment.sh               (from zsh module)
  20-shell-utils.sh               (from shell module)
  30-editor.sh                    (from editor module)
  40-dev-tools.sh                 (from dev-tools module)
  90-local.sh                     (machine-specific, gitignored)
```

**Key detail**: The zsh module's `.zshrc` becomes the sole owner of that file. It no longer appears in mergeable_files. Instead of merging two `.zshrc` files, the `mise activate` line moves into a conf.d fragment owned by dev-tools.

### Fish conf.d

Fish natively supports `~/.config/fish/conf.d/*.fish`. Files are sourced alphabetically before `config.fish`.

```
~/.config/fish/config.fish        (owned by fish module, stowed directly)
~/.config/fish/conf.d/            (directory populated by Stow from multiple modules)
  10-shell-utils.fish             (from shell module)
  20-editor.fish                  (from editor module)
  30-dev-tools.fish               (from dev-tools module)
  90-local.fish                   (machine-specific, gitignored)
```

**Key detail**: Fish's native conf.d runs snippets *before* config.fish. This means the fish module's config.fish can depend on variables set by conf.d snippets. Ordering between conf.d and config.fish is the opposite of the zsh pattern where conf.d is sourced during .zshrc execution at a specific point.

### Mise conf.d

Mise natively loads `~/.config/mise/conf.d/*.toml` files. These are treated as additional configuration that merges with the main config.toml using mise's own TOML merge semantics (not concatenation).

```
~/.config/mise/config.toml        (owned by dev-tools module, stowed directly)
~/.config/mise/conf.d/            (directory populated by Stow from multiple modules)
  10-node.toml                    (from node module)
```

**Key detail**: With mise's native TOML merging, the node module's conf.d file can include its own `[tools]` header. The fragile "omit the header because concatenation breaks it" problem disappears entirely.

## Component Boundaries

### Components After Migration

| Component | Responsibility | Owns | Communicates With |
|---|---|---|---|
| **zsh module** | Zsh shell init, prompt, plugins, core aliases/functions | `.zshrc`, `.zsh/aliases.sh`, `.zsh/functions.sh`, `.zsh/utility.zsh`, `.zsh/conf.d/10-environment.sh` | Reads conf.d fragments from other modules |
| **fish module** | Fish shell init, prompt, functions, core abbrs | `.config/fish/config.fish`, fish functions | Reads conf.d fragments from other modules |
| **dev-tools module** | mise, bat, shellcheck, dev tool configs | `.config/mise/config.toml`, `.zsh/conf.d/40-dev-tools.sh`, `.config/fish/conf.d/30-dev-tools.fish` | Provides tool activation to shells |
| **shell module** | Shared shell utilities (eza, ripgrep) | `.zsh/conf.d/20-shell-utils.sh`, `.config/fish/conf.d/10-shell-utils.fish` | Provides env vars to shells |
| **editor module** | Vim config, EDITOR/VISUAL vars | `.vimrc`, `.zsh/conf.d/30-editor.sh`, `.config/fish/conf.d/20-editor.fish` | Provides editor env vars to shells |
| **node module** | Node.js + pnpm via mise | `.config/mise/conf.d/10-node.toml`, `.npmrc` | Configures tools via mise |
| **ansible-role-dotmodules** | Module processing, Homebrew, Stow deployment | merge_files.yml (to be removed), stow_module.yml | Processes all modules |

### What Changes Per Module

**zsh module:**
- `.zshrc`: Remove from mergeable_files. Add conf.d glob sourcing loop. Keep existing sourcing of aliases.sh, functions.sh, utility.zsh.
- New file: `files/.zsh/conf.d/10-environment.sh` (current content from `files/.zsh/environment.sh`, minus EDITOR/VISUAL which belong to editor)
- Remove: `files/.zsh/environment.sh` (content moves to conf.d)
- Remove: `files/.zsh/aliases.sh` from mergeable_files (becomes sole owner, stowed directly)
- Remove: mergeable_files from config.yml entirely

**dev-tools module:**
- Remove: `files/.zshrc` (2 lines: mise activate)
- New file: `files/.zsh/conf.d/40-dev-tools.sh` containing `eval "$(mise activate zsh)"`
- Remove: `files/.config/fish/config.fish` (3 lines: mise activate)
- New file: `files/.config/fish/conf.d/30-dev-tools.fish` containing mise activation
- Keep: `files/.config/mise/config.toml` stowed directly (no longer merged)
- Remove: mergeable_files from config.yml entirely

**editor module:**
- Remove: `files/.zsh/aliases.sh` (1 line: alias e)
- New file: `files/.zsh/conf.d/30-editor.sh` combining EDITOR/VISUAL exports and alias e
- Remove: `files/.zsh/environment.sh` (EDITOR/VISUAL, now in conf.d fragment)
- Remove: `files/.config/fish/config.fish` (2 lines: app launcher abbrs)
- New file: `files/.config/fish/conf.d/20-editor.fish` with editor abbrs
- Remove: mergeable_files from config.yml entirely

**shell module:**
- Remove: `files/.zsh/environment.sh` (1 line: EZA_COLORS)
- New file: `files/.zsh/conf.d/20-shell-utils.sh` with EZA_COLORS
- Remove: `files/.config/fish/config.fish` (1 line: EZA_COLORS)
- New file: `files/.config/fish/conf.d/10-shell-utils.fish` with EZA_COLORS
- Remove: mergeable_files from config.yml entirely

**node module:**
- Remove: `files/.config/mise/config.toml`
- New file: `files/.config/mise/conf.d/10-node.toml` (can now include its own `[tools]` header)
- Remove: mergeable_files from config.yml entirely

**fish module:**
- `.config/fish/config.fish`: Remove from mergeable_files. Stow directly. Content stays as-is since other modules' contributions move to conf.d.
- Remove: mergeable_files from config.yml entirely

## How Stow Handles conf.d Directories

### --no-folding Is Already In Use

The ansible-role-dotmodules already uses `stow --no-folding` for all deployments. This is essential for conf.d because:

**Without --no-folding**: If only the zsh module contributes to `~/.zsh/conf.d/`, Stow creates a directory symlink: `~/.zsh/conf.d -> modules/zsh/files/.zsh/conf.d/`. When shell module then tries to stow its conf.d fragment, Stow sees a directory symlink already exists and cannot add files from a different package.

**With --no-folding**: Stow creates `~/.zsh/conf.d/` as a real directory and creates individual file symlinks:
```
~/.zsh/conf.d/10-environment.sh -> ~/.dotmodules/zsh/files/.zsh/conf.d/10-environment.sh
~/.zsh/conf.d/20-shell-utils.sh -> ~/.dotmodules/shell/files/.zsh/conf.d/20-shell-utils.sh
~/.zsh/conf.d/30-editor.sh      -> ~/.dotmodules/editor/files/.zsh/conf.d/30-editor.sh
~/.zsh/conf.d/40-dev-tools.sh   -> ~/.dotmodules/dev-tools/files/.zsh/conf.d/40-dev-tools.sh
```

This works correctly with the existing `--no-folding` flag. **No Stow configuration changes needed.**

### Stow Processing Order Does Not Matter

The playbook install list order determines Stow processing order. Since `--no-folding` creates real directories and individual file symlinks, the first module that references `~/.zsh/conf.d/` causes Stow to create the directory; subsequent modules add their file symlinks into it. Order is irrelevant for the directory creation.

The *numeric prefix* on filenames controls runtime sourcing order, not Stow processing order.

## Numeric Prefix Convention

```
00-09  Reserved (future use, bootstrapping)
10-19  Core environment (platform detection, PATH, XDG vars)
20-29  Shared utilities (eza colors, tool env vars)
30-39  Tool-specific (editor, git helpers)
40-49  Runtime activation (mise activate, nvm, etc.)
50-89  Available for future modules
90-99  Local overrides (gitignored, machine-specific)
```

**Rationale**: Environment variables (10-19) must be set before tools that reference them (20-39). Runtime activation (40-49) should happen after environment is fully configured. Local overrides (90-99) run last so they can override anything.

## Data Flow

### Zsh Startup (After Migration)

```
1. ~/.zshenv           (zsh module, environment bootstrap)
2. ~/.zprofile         (zsh module, login shell setup)
3. ~/.zshrc            (zsh module, interactive shell)
   a. p10k instant prompt
   b. for f in ~/.zsh/conf.d/*.sh; source "$f"
      - 10-environment.sh   (PLATFORM, PAGER, colors, CDPATH)
      - 20-shell-utils.sh   (EZA_COLORS)
      - 30-editor.sh        (EDITOR, VISUAL, alias e)
      - 40-dev-tools.sh     (eval "$(mise activate zsh)")
   c. source aliases.sh     (zsh-specific aliases, single owner)
   d. source functions.sh   (zsh-specific functions)
   e. source utility.zsh    (zsh-specific utilities)
   f. source .zshrc.local   (machine-specific overrides)
   g. compinit
   h. zsh-autosuggestions, powerlevel10k, zsh-syntax-highlighting
4. ~/.zlogin           (zsh module, post-login)
```

### Fish Startup (After Migration)

```
1. ~/.config/fish/conf.d/*.fish  (native, alphabetical, BEFORE config.fish)
   - 10-shell-utils.fish   (EZA_COLORS)
   - 20-editor.fish         (app launcher abbrs)
   - 30-dev-tools.fish      (mise activate fish)
2. ~/.config/fish/config.fish    (fish module, main config)
   - env vars, abbrs, functions, prompt config
   - source config.local.fish
```

### Mise Config Loading (After Migration)

```
1. ~/.config/mise/config.toml    (dev-tools module, settings + python)
2. ~/.config/mise/conf.d/*.toml  (native, alphabetical)
   - 10-node.toml               (node + pnpm versions, own [tools] header)
```

## Migration Path

### Phase 1: Zsh conf.d (Highest value, most complex)

1. Create conf.d fragment files in each module's `files/` directory
2. Modify zsh module's `.zshrc` to add glob sourcing loop
3. Remove old mergeable files from module `files/` directories
4. Remove `mergeable_files` from affected module `config.yml` files
5. Test: shell startup, all aliases work, mise activates, EDITOR set

**Why first**: Zsh is the primary shell with the most merge participants (5 modules, 3 merged files). Getting this right establishes the pattern for everything else.

### Phase 2: Fish conf.d (Native support, straightforward)

1. Create conf.d fragment files in each module's `files/` directory
2. Slim down fish module's `config.fish` (remove content that moves to conf.d)
3. Remove old mergeable files from module `files/` directories
4. Remove `mergeable_files` from affected module `config.yml` files
5. Test: fish startup, abbrs work, mise activates

**Why second**: Fish's native conf.d means zero custom sourcing code. The naming pattern from Phase 1 carries over.

### Phase 3: Mise conf.d (Simplest, fewest participants)

1. Create conf.d fragment in node module's `files/` directory
2. Update dev-tools module's config.toml (remove mergeable_files, stow directly)
3. Remove `mergeable_files` from affected module `config.yml` files
4. Test: `mise ls` shows python, node, pnpm with correct versions

**Why third**: Only two modules participate. Lowest risk.

### Phase 4: Cleanup

1. Verify no modules still declare mergeable_files
2. Remove merge logic from ansible-role-dotmodules (merge_files.yml, merged_file.j2)
3. Simplify stow_module.yml (remove mergeable file ignore patterns)
4. Clean up `~/.dotmodules/merged/` directory on deployed machines
5. Update documentation (convention doc for numeric ordering)

**Why last**: The role should continue to work during incremental migration. Cleanup happens only after all modules are migrated.

## Resolving the EDITOR/VISUAL Duplication

Both `zsh/files/.zsh/environment.sh` and `editor/files/.zsh/environment.sh` currently define EDITOR and VISUAL. In the merged file, editor's definition wins (it's concatenated last based on module order).

**Resolution**: Move EDITOR/VISUAL to the editor module's conf.d fragment (`30-editor.sh`). Remove from zsh module's environment conf.d fragment (`10-environment.sh`). The editor module is the correct owner of editor-related environment variables. This is a clean separation of concerns that was not possible with the merge approach.

## Anti-Patterns to Avoid

### Anti-Pattern 1: Large conf.d Fragments
**What**: Moving entire config files into conf.d instead of splitting logically.
**Why bad**: Defeats the purpose. A 50-line conf.d file is just a renamed merged file.
**Instead**: Each conf.d fragment should be a focused, single-concern snippet (3-15 lines typical).

### Anti-Pattern 2: Cross-Fragment Dependencies
**What**: One conf.d fragment depending on variables set by another conf.d fragment.
**Why bad**: Fragile. Renaming a file changes load order and breaks things silently.
**Instead**: conf.d fragments should be independent. If order matters, document it and use numeric prefixes with wide gaps (10, 20, 30 not 01, 02, 03).

### Anti-Pattern 3: Splitting Existing Single-Owner Files
**What**: Breaking aliases.sh into conf.d just because conf.d exists.
**Why bad**: aliases.sh is owned by one module (zsh after migration). No merge conflict to solve.
**Instead**: Only use conf.d for files that previously needed cross-module merging. Single-owner files stay as direct stowed files.

### Anti-Pattern 4: Fish conf.d for Things That Belong in config.fish
**What**: Moving fish environment setup into conf.d when it belongs in config.fish.
**Why bad**: Fish conf.d runs before config.fish. Prompt configuration, function definitions, and core env vars that define the fish module's identity belong in config.fish.
**Instead**: Only cross-module concerns go in conf.d (mise activation, shared env vars from other modules).

## Scalability Considerations

| Concern | At 11 modules (current) | At 20 modules | At 50 modules |
|---|---|---|---|
| Startup time | Negligible (~2ms for glob) | Still negligible (~5ms) | Measure; consider lazy loading |
| conf.d naming | Wide gaps in numbering (10, 20, 30...) | Still room | May need sub-categories |
| Debugging | `ls ~/.zsh/conf.d/` shows all fragments | Same | May need `zsh -x` tracing |
| Adding a module | Create conf.d fragment, pick number | Same | Same |

## Sources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html) - `--no-folding` behavior (HIGH confidence)
- [Fish Shell Configuration](https://deepwiki.com/fish-shell/fish-shell/6.1-configuration-files) - Native conf.d support (HIGH confidence)
- [Mise Configuration](https://mise.jdx.dev/configuration.html) - Config file hierarchy (MEDIUM confidence)
- [Mise Configuration System](https://deepwiki.com/jdx/mise/3.2-configuration-system) - conf.d/*.toml loading (MEDIUM confidence - verified in multiple sources but not tested hands-on)
- ansible-role-dotmodules source: `~/.ansible/roles/ansible-role-dotmodules/` - Current merge and stow logic (HIGH confidence - read directly)

---

*Researched: 2026-03-10*
*Overall confidence: HIGH for zsh/fish patterns, MEDIUM for mise conf.d native loading*
