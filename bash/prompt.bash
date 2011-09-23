# set up completion
if [ -z "$BASH_COMPLETION" ]; then
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    if [ "$PS1" ] && [ \( $bmajor -eq 2 -a $bminor '>' 04 \) -o $bmajor -ge 3 ] ; then
      if [ -f $HOME/bin/bash_completion   ] ; then
        BASH_COMPLETION=$HOME/bin/bash_completion
        BASH_COMPLETION_DIR=$HOME/.bash_completion.d
        export BASH_COMPLETION BASH_COMPLETION_DIR
        . $HOME/bin/bash_completion

				export GIT_PS1_SHOWDIRTYSTATE=1
				export GIT_PS1_SHOWSTASHSTATE=1
				export GIT_PS1_SHOWUNTRACKEDFILES=1
				export GIT_DIRTY_COLOR="0;31m"
				export GIT_CLEAN_COLOR="0;32m"

        # set prompt to show git branch
        PS1='\u@\h:\[\e[0;33m\]\w\[\e[m\]$(__git_ps1 " (%s)")\n$ '
      fi

      # remove completions I do not want.
      complete -r kill

      # some custom completions
      complete -f -X '!*.tar.gz' cpan-upload-http

      complete -C perldoc-complete perldoc
    fi
    unset bash bmajor bminor
fi