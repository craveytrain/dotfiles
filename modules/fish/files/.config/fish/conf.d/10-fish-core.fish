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
    # --- Abbreviations ---
    abbr dot "cd $DOTFILES"
    abbr dotdot --regex '^\.\.+$' --function multicd
    abbr ip "dig +short myip.opendns.com @resolver1.opendns.com"
    abbr pubkey "cat ~/.ssh/*.pub | pbcopy; echo '=> Public key copied to clipboard.'"
    abbr mkdir "mkdir -p"
    abbr df "df -kh"
    abbr du "du -kh"

    # --- Prompt (Tide) ---
    set -g tide_left_prompt_items pwd git cmd_duration newline status character
    set -g tide_right_prompt_items node python rustc java php ruby go terraform
end
