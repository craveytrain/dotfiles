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
    # Use -U with guards to work with tide's universal variable model
    # Only writes when the value doesn't match, so no unnecessary writes per shell launch
    test "$tide_left_prompt_items" != "pwd git newline status character"; and set -U tide_left_prompt_items pwd git newline status character
    test "$tide_right_prompt_items" != "cmd_duration jobs direnv node python rustc go terraform"; and set -U tide_right_prompt_items cmd_duration jobs direnv node python rustc go terraform
    test "$tide_git_truncation_length" != 32; and set -U tide_git_truncation_length 32

    # --- Colors (match p10k lean-8colors) ---
    # Character
    test "$tide_character_color" != green; and set -U tide_character_color green
    test "$tide_character_color_failure" != red; and set -U tide_character_color_failure red
    # Git
    test "$tide_git_color_branch" != green; and set -U tide_git_color_branch green
    test "$tide_git_color_conflicted" != red; and set -U tide_git_color_conflicted red
    test "$tide_git_color_dirty" != yellow; and set -U tide_git_color_dirty yellow
    test "$tide_git_color_operation" != red; and set -U tide_git_color_operation red
    test "$tide_git_color_staged" != yellow; and set -U tide_git_color_staged yellow
    test "$tide_git_color_stash" != green; and set -U tide_git_color_stash green
    test "$tide_git_color_untracked" != green; and set -U tide_git_color_untracked green
    test "$tide_git_color_upstream" != green; and set -U tide_git_color_upstream green
    # Status
    test "$tide_status_color" != green; and set -U tide_status_color green
    test "$tide_status_color_failure" != red; and set -U tide_status_color_failure red
    # PWD (keep tide defaults)
    test "$tide_pwd_color_anchors" != 00AFFF; and set -U tide_pwd_color_anchors 00AFFF
    test "$tide_pwd_color_dirs" != 0087AF; and set -U tide_pwd_color_dirs 0087AF
    test "$tide_pwd_color_truncated_dirs" != 8787AF; and set -U tide_pwd_color_truncated_dirs 8787AF
    # Cmd Duration
    test "$tide_cmd_duration_color" != yellow; and set -U tide_cmd_duration_color yellow
    # Jobs
    test "$tide_jobs_color" != red; and set -U tide_jobs_color red
    # Direnv
    test "$tide_direnv_color" != yellow; and set -U tide_direnv_color yellow
    test "$tide_direnv_color_denied" != red; and set -U tide_direnv_color_denied red
    # Node
    test "$tide_node_color" != green; and set -U tide_node_color green
    # Python
    test "$tide_python_color" != cyan; and set -U tide_python_color cyan
    # Rustc
    test "$tide_rustc_color" != blue; and set -U tide_rustc_color blue
    # Go
    test "$tide_go_color" != cyan; and set -U tide_go_color cyan
    # Terraform
    test "$tide_terraform_color" != blue; and set -U tide_terraform_color blue

    # --- Icons (match p10k nerdfont-complete) ---
    test "$tide_pwd_icon" != \uf07b; and set -U tide_pwd_icon \uf07b
    test "$tide_git_icon" != \uf126; and set -U tide_git_icon \uf126
    test "$tide_node_icon" != \ue617; and set -U tide_node_icon \ue617
    test "$tide_go_icon" != \ue626; and set -U tide_go_icon \ue626
    test "$tide_cmd_duration_icon" != \uf252; and set -U tide_cmd_duration_icon \uf252
    test "$tide_jobs_icon" != \uf013; and set -U tide_jobs_icon \uf013
    test "$tide_rustc_icon" != \ue7a8; and set -U tide_rustc_icon \ue7a8
    test "$tide_python_icon" != \ue73c; and set -U tide_python_icon \ue73c
    test "$tide_terraform_icon" != \U000F1062; and set -U tide_terraform_icon \U000F1062
end
