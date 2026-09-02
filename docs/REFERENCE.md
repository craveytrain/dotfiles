# Reference

The root [README](../README.md) is the normal setup and update path. This file
holds commands and implementation details that are useful less often.

## Deployment commands

Run these from the repository root.

| Task | Command |
| --- | --- |
| Install role and collections | `ansible-galaxy install -r requirements.yml` |
| Deploy, including shell registration | `ansible-playbook -i playbooks/inventory playbooks/deploy.yml --ask-become-pass` |
| Deploy without sudo | `ansible-playbook -i playbooks/inventory playbooks/deploy.yml --skip-tags register_shell` |
| Preview without changing anything | `ansible-playbook -i playbooks/inventory playbooks/deploy.yml --check --ask-become-pass` |
| Show more output | `ansible-playbook -i playbooks/inventory playbooks/deploy.yml -v --ask-become-pass` |
| Check playbook syntax | `ansible-playbook -i playbooks/inventory playbooks/deploy.yml --syntax-check` |

Shell registration writes the Homebrew shell path to `/etc/shells`. It is the
only deployment task expected to need elevated privileges.

## How deployment works

`playbooks/deploy.yml` passes its `dotmodules.install` list to the external
`ansible-role-dotmodules` role. For every selected module, the role reads
`modules/<name>/config.yml`, installs declared Homebrew dependencies, and uses
GNU Stow for any declared `stow_dirs`.

Stow creates home-directory symlinks to files in this checkout. Editing a
tracked config therefore changes the deployed config immediately; package or
module-list changes require another playbook run.

## Module layout

```text
modules/<name>/
├── config.yml
├── README.md
└── files/
    └── <paths relative to $HOME>
```

A module may declare:

```yaml
homebrew_packages:
  - example
homebrew_casks:
  - example-app
stow_dirs:
  - module-name
register_shell: example-shell
```

Keep modules independent. Do not make one module's configuration require
another module to load successfully.

## Add or change a module

1. Create `modules/<name>/config.yml`.
2. Put deployable files under `modules/<name>/files/`, preserving their paths
   relative to `$HOME`.
3. Add `stow_dirs` only when the module has deployable files.
4. Add the module to `dotmodules.install` in `playbooks/deploy.yml`.
5. Run the syntax check and check-mode commands above.
6. Run the normal deployment and verify the actual tool.

Shell configuration belongs in runtime-loaded fragments rather than merged
files:

- Zsh: `files/.zsh/conf.d/NN-<module>-<purpose>.sh`
- Fish: `files/.config/fish/conf.d/NN-<module>-<purpose>.fish`
- Mise: `files/.config/mise/conf.d/<module>.toml`

Use prefix groups `10` for core setup, `50` for features, and `80` for
late-loading integrations. Fish loads `conf.d` alphabetically and Fisher plugin
fragments sort after digits. A fragment that must override plugin bindings
therefore needs a letter prefix such as `zz-`, not a larger number.

All operations must be idempotent. Prefer declarative YAML and tool-native
configuration over shell scripts.

## Troubleshooting

### Existing file blocks Stow

Move the existing file aside, deploy, then compare it with the stowed version.
Do not delete it until any local settings have been copied into the appropriate
local override.

### A pulled change is not visible

Restart the application or start a new shell. Re-run the playbook if the change
added a package, module, or newly stowed path.

### Shell registration fails

Use `--skip-tags register_shell`. This leaves `/etc/shells` and the current
login shell unchanged but deploys the remaining configuration.

### Fish prompt or plugins are missing

From Fish, run:

```fish
fisher update
```

Re-run the Tide command in the root README if the prompt baseline is missing.

### mise tools are missing

```bash
mise install
```
