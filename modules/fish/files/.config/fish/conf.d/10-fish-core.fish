# fish module - core environment, abbreviations, and prompt configuration

# --- Environment ---
set -gx DOTFILES "$HOME/dotfiles"
set -gx XDG_CONFIG_HOME "$HOME/.config"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
fish_add_path ~/.local/bin
fish_add_path ~/.bin

set -gx CDPATH . ~ (test -e ~/Work; and echo ~/Work)
set -gx LS_COLORS 'rs=0:di=00;38;5;39:ex=00;32:ln=00;38;5;5:'

if status --is-interactive
    # Pin the key-binding mode before plugin conf.d files load. Fish's
    # generated conf.d/fish_frozen_key_bindings.fish erases the universal
    # `fish_key_bindings`, so plugins that bind keys (puffer-fish) would
    # otherwise see it unset and bind into `insert` mode instead of `default`.
    set -g fish_key_bindings fish_default_key_bindings

    # --- Abbreviations ---
    abbr dot "cd $DOTFILES"
    abbr ip "dig +short myip.opendns.com @resolver1.opendns.com"
    abbr pubkey "cat ~/.ssh/*.pub | pbcopy; echo '=> Public key copied to clipboard.'"
    abbr mkdir "mkdir -p"
    abbr df "df -kh"
    abbr du "du -kh"

    # --- Prompt (Tide) ---
    # The baseline is written ONCE into fish's universal variables by the
    # `tide configure --auto ...` command in modules/fish/README.md. Re-run it
    # when setting up a new machine; it is idempotent.
    #
    # Only genuine deviations from that baseline belong here, and they use
    # `set -g`, not `set -U`. Tide resolves its config through ordinary
    # variable lookup, so a global shadows the universal at prompt-render
    # time. That keeps this non-destructive: the universal store stays
    # whatever `tide configure` last wrote, so the prompt can be re-tuned
    # interactively without this file silently reverting it on the next shell.
    set -g tide_git_truncation_length 32

end

# Git icon follows the remote host, the way p10k's nerdfont-complete mode does:
# octocat for GitHub, fox for GitLab, else a plain fork. Same codepoints p10k
# uses (internal/icons.zsh).
#
# Deliberately OUTSIDE `status --is-interactive`. Tide renders the prompt in a
# spawned non-interactive `fish -c`, and that child is what actually calls
# _tide_item_git, so anything behind the interactive guard never reaches it.
#
# Wrapping the item rather than setting the variable at conf.d load keeps the
# `git config` lookup off the shell-startup path: it runs only when the git
# segment actually renders.
if functions -q _tide_item_git; and not functions -q _tide_item_git_upstream
    functions --copy _tide_item_git _tide_item_git_upstream
    function _tide_item_git
        switch (git config --get remote.origin.url 2>/dev/null)
            case '*github.com*'
                set -g tide_git_icon \uf113
            case '*gitlab.com*'
                set -g tide_git_icon \uf296
            case '*bitbucket.org*'
                set -g tide_git_icon \uf171
            case '*'
                set -g tide_git_icon \uf126
        end
        _tide_item_git_upstream
    end
end
