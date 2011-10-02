autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

git_dirty() {
  st=$(/usr/bin/git status 2>/dev/null | tail -n 1)
  if [[ $st == "" ]]
  then
    echo ""
  else
    if [[ $st == "nothing to commit (working directory clean)" ]]
    then
      echo "%{\e[38;5;118m%}$(git_prompt_info)%{$reset_color%}"
    else
      echo "%{\e[38;5;161m%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$(/usr/bin/git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
echo "(${ref#refs/heads/})"
}

directory_name () {
  echo "%{\e[38;5;81m%}${PWD/#$HOME/~}%{$reset_color%}"
}

username () {
	echo "%{\e[38;5;135m%}%n%{$reset_color%}"
}

hostname () {
	echo "%{\e[38;5;166m%}%m%{$reset_color%}"
}

export PROMPT=$'$(username) at $(hostname) in $(directory_name) $(git_dirty)\n› '

precmd() {
  title "zsh" "%m" "%55<...<%~"
}

