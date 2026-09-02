# Development tools

Installs `actionlint`, `bat`, `direnv`, `jq`, `mise`, `ngrep`, `nmap`, and `shellcheck`.

The module stows configuration for bat, direnv, mise, npm, and EditorConfig. Shell fragments activate direnv and mise and provide on-demand `npx` shortcuts in Fish and Zsh. It also installs the `curledit` and `serve` helpers in `~/.local/bin`.

Install versions declared in the shared mise config after the first deployment:

```bash
mise install
```

Put machine-specific environment variables in the Fish or Zsh local override listed in the root README.
