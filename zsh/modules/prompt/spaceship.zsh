# Spaceship Prompt config
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  host          # Hostname section
  dir           # Current directory section
  git_branch    # Git branch
  git_sha       # Git sha
  git_status    # Git status
  # hg            # Mercurial section (hg_branch  + hg_status)
  exec_time     # Execution time
  line_sep      # Line break
  # vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

SPACESHIP_RPROMPT_ORDER=(
  # time          # Time stamps section
  node          # Node.js section
  aws           # Amazon Web Services section
  docker        # Docker section
  package       # Package version
  # venv          # virtualenv section
  # conda         # conda virtualenv section
  # pyenv         # Pyenv section
  # dotnet        # .NET section
  # ember         # Ember.js section
  # kubecontext   # Kubectl context section
  # terraform     # Terraform workspace section
  # ruby          # Ruby section
  # elixir        # Elixir section
  # xcode         # Xcode section
  # swift         # Swift section
  # golang        # Go section
  # php           # PHP section
  # rust          # Rust section
  # haskell       # Haskell Stack section
  # julia         # Julia section
  # battery       # Battery level and status
)


SPACESHIP_GIT_STATUS_PREFIX=""
SPACESHIP_GIT_STATUS_SUFFIX=" "
SPACESHIP_GIT_STATUS_COLOR="red"
SPACESHIP_GIT_STATUS_UNTRACKED="?"
SPACESHIP_GIT_STATUS_ADDED="+"
SPACESHIP_GIT_STATUS_MODIFIED="!"
SPACESHIP_GIT_STATUS_RENAMED="»"
SPACESHIP_GIT_STATUS_DELETED="✘"
SPACESHIP_GIT_STATUS_STASHED="$"
SPACESHIP_GIT_STATUS_UNMERGED="="
SPACESHIP_GIT_STATUS_AHEAD="⇡"
SPACESHIP_GIT_STATUS_BEHIND="⇣"
SPACESHIP_GIT_STATUS_DIVERGED="⇕"
SPACESHIP_GIT_BRANCH_COLOR="yellow"
SPACESHIP_GIT_BRANCH_SUFFIX=""
SPACESHIP_PACKAGE_COLOR="magenta"
SPACESHIP_GIT_SHA_COLOR="242"
SPACESHIP_GIT_SHA_SYMBOL=""
SPACESHIP_GIT_SHA_PREFIX="["
SPACESHIP_GIT_SHA_SUFFIX="] "
SPACESHIP_PACKAGE_PREFIX=""
SPACESHIP_AWS_PREFIX=""
SPACESHIP_DOCKER_PREFIX=""
