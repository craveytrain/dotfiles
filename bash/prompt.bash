# set up completion
if [ -z "$BASH_COMPLETION" ]; then
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    if [ "$PS1" ] && [ \( $bmajor -eq 2 -a $bminor '>' 04 \) -o $bmajor -ge 3 ] ; then
      if [ -f $DOTFILES/bin/bash_completion   ] ; then
        BASH_COMPLETION=$DOTFILES/bin/bash_completion
        BASH_COMPLETION_DIR=$HOME/.bash_completion.d
        export BASH_COMPLETION BASH_COMPLETION_DIR
        . $DOTFILES/bin/bash_completion

				export GIT_PS1_SHOWDIRTYSTATE=1
				export GIT_PS1_SHOWSTASHSTATE=1
				export GIT_PS1_SHOWUNTRACKEDFILES=1
				export GIT_DIRTY_COLOR="38;5;161m"
				export GIT_CLEAN_COLOR="38;5;118m"

        # set prompt to show git branch
		if [[ -n $SSH_CONNECTION ]]; then
	        PS1='\[\e[38;5;135m\]\u\[\e[0m\] at \[\e[38;5;166m\]\h\[\e[0m\] in \[\e[38;5;81m\]\w\[\e[0m\]$(__git_ps1 " %s")\n$ '
		else
        	PS1='in \[\e[38;5;81m\]\w\[\e[0m\]$(__git_ps1 "%s")\n$ '
		fi
      fi

      # remove completions I do not want.
      complete -r kill

      # some custom completions
      complete -f -X '!*.tar.gz' cpan-upload-http

      complete -C perldoc-complete perldoc
    fi
    unset bash bmajor bminor
fi
