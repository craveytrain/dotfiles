# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# append an entry to PATH if it is a dir, and not already in path.
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$PATH:$1"
    fi
}

path_unshift() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:$PATH"
    fi
}

pathadd $HOME/bin

# add /usr/local bindirs
pathadd /usr/local/bin
pathadd /usr/local/sbin

# set lang
export LANG=en_US.UTF-8

# use vim if possible, otherwise vi
if [ -x `which vim` ]; then
    export EDITOR=vim
else
    export EDITOR=vi
fi

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

# Mac specific stuff
if [ -f ~/.bash_mac ]; then
. ~/.bash_mac
fi

# This loads RVM into a shell session.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"