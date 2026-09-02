# Fish

Installs Fish and Fisher, registers Fish in `/etc/shells`, and stows shell configuration, plugins, and functions.

Deployment installs the plugins listed in `fish_plugins`. The prompt baseline is the one manual step, run from Fish:

```fish
tide configure --auto --style=Lean --prompt_colors='True color' \
  --show_time=No --lean_prompt_height='Two lines' \
  --prompt_connection=Disconnected --prompt_spacing=Sparse \
  --icons='Many icons' --transient=No
```

The Tide command stores its baseline in per-machine universal variables. The tracked `10-fish-core.fish` fragment applies shared adjustments on top.

Use `~/.config/fish/config.local.fish` for private or machine-specific settings. The tracked `config.fish` loads it when present.
