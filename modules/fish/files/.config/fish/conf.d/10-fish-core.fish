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
    set -g tide_left_prompt_items pwd git newline status character
    set -g tide_right_prompt_items cmd_duration jobs direnv node python rustc go terraform
    set -g tide_git_truncation_length 32

    # --- Icons (match p10k nerdfont-complete) ---
    set -g tide_pwd_icon \uf115
    set -g tide_node_icon \ue617
    set -g tide_go_icon \ue626
    set -g tide_cmd_duration_icon \uf252
    set -g tide_jobs_icon \uf013
end
