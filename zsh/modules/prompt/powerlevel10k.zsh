# Original location: https://github.com/romkatv/dotfiles-public/blob/master/.purepower.
# If you copy this file, keep the link to the original and this sentence intact; you are encouraged to change everything else.

# if not on a capable terminal, dumb it down
[[ $TERM == xterm* ]] || : ${PURE_POWER_MODE:=portable}

() {
  zmodload zsh/terminfo
  if (( terminfo[colors] >= 256 )); then
    function _pp_c() { print -nr -- $2 }
  else
    function _pp_c() { print -nr -- $1 }
    typeset -g POWERLEVEL9K_IGNORE_TERM_COLORS=true
  fi

  # `$(_pp_s x y`) evaluates to `x` in portable mode and to `y` in fancy mode.
  if [[ ${PURE_POWER_MODE:-fancy} == fancy ]]; then
    function _pp_s() { print -nr -- $2 }
  else
    if [[ $PURE_POWER_MODE != portable ]]; then
      echo -En "purepower: invalid mode: ${(qq)PURE_POWER_MODE}; " >&2
      echo -E  "valid options are 'fancy' and 'portable'; falling back to 'portable'" >&2
    fi
    function _pp_s() { print -nr -- $1 }
  fi

  local ins=$(_pp_s '>' '❯')
  local cmd=$(_pp_s '<' '❮')
  if (( ${PURE_POWER_USE_P10K_EXTENSIONS:-1} )); then
    local p="\${\${\${KEYMAP:-0}:#vicmd}:+${${ins//\\/\\\\}//\}/\\\}}}"
    p+="\${\${\$((!\${#\${KEYMAP:-0}:#vicmd})):#0}:+${${cmd//\\/\\\\}//\}/\\\}}}"
  else
    local p=$ins
  fi

  # source "${0:h}/purepower.zsh"

  typeset -ga POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # icon for os
    context                 # user@host
    dir                     # current directory
    vcs                     # git status
  )
  typeset -ga POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    nodenv
  )

  # general
  typeset -g POWERLEVEL9K_MODE='nerdfont-complete'
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{%(?.$(_pp_c 2 76).$(_pp_c 1 196))}$p%f "
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_WHITESPACE_BETWEEN_{LEFT,RIGHT}_SEGMENTS=
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_END_SEPARATOR=


  # os icon
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$POWERLEVEL9K_OS_ICON_BACKGROUND
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=none

  # context
  typeset -g DEFAULT_USER="$USER"
  typeset -g POWERLEVEL9K_USER_ICON="\uF415"
  typeset -g POWERLEVEL9K_ROOT_ICON="#"
  typeset -g POWERLEVEL9K_SUDO_ICON=$'\uF09C'
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,ROOT,REMOTE_SUDO,REMOTE,SUDO}_BACKGROUND=none
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,REMOTE_SUDO,REMOTE,SUDO}_FOREGROUND=$(_pp_c 7 244)
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='red'

  # dir
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true
  typeset -g POWERLEVEL9K_DIR_{ETC,HOME,HOME_SUBFOLDER,DEFAULT,NOT_WRITABLE}_BACKGROUND=none
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND=$(_pp_c 3 209)
  typeset -g POWERLEVEL9K_DIR_{HOME,HOME_SUBFOLDER,ETC,DEFAULT}_FOREGROUND=$(_pp_c 4 39)

  # VCS
  typeset -g POWERLEVEL9K_SHOW_CHANGESET=true
  typeset -g POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
  typeset -g POWERLEVEL9K_VCS_GIT_ICON=$'\uf09b '
  typeset -g POWERLEVEL9K_VCS_GIT_GITHUB_ICON=$'\uf09b '
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON=$'\ufc16 '
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED}_MAX_NUM=99
  # typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  # typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
  # typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
  # typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=$(_pp_s '<' '⇣')
  # typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=$(_pp_s '>' '⇡')
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON=$'\uf06a '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON=$'\uf059 '
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON=$'\uf055 '
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=$'\uf0ab '
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=$'\uf0aa '
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED,LOADING}_BACKGROUND=none
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$(_pp_c 2 76)
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$(_pp_c 6 14)
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$(_pp_c 3 11)
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=$(_pp_c 5 244)
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_UNTRACKEDFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_UNSTAGEDFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_MODIFIED_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_STAGEDFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_MODIFIED_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_INCOMING_CHANGESFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_CLEAN_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_OUTGOING_CHANGESFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_CLEAN_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_STASHFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_CLEAN_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_ACTIONFORMAT_FOREGROUND=1
  typeset -g POWERLEVEL9K_VCS_LOADING_ACTIONFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_LOADING_FOREGROUND

  # status
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=none
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$(_pp_c 1 9)

  # command execution time
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=none
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$(_pp_c 5 101)

  # background jobs
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=none
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_COLOR=2
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_ICON=$(_pp_s '%%' '⇶')

  # node
  typeset -g POWERLEVEL9K_NODE_ICON=$' \uf7d7'
  typeset -g POWERLEVEL9K_NODENV_BACKGROUND='none'
  typeset -g POWERLEVEL9K_NODENV_FOREGROUND='green'

  unfunction _pp_c _pp_s
} "$@"

# source "${0:h}/external/powerlevel10k/powerlevel10k.zsh-theme"
