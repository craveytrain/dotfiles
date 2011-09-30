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
      echo "%{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}"
    else
      echo "%{$fg_bold[red]%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$(/usr/bin/git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
echo "(${ref#refs/heads/})"
}

directory_name () {
  echo "%{$fg_bold[cyan]%}${PWD/#$HOME/~}%{$reset_color%}"
}

username () {
	echo "%{$fg_bold[magenta]%}%n%{$reset_color%}"
}

hostname () {
	echo "%{$fg_bold[yellow]%}%m%{$reset_color%}"
}

export PROMPT=$'$(username) at $(hostname) in $(directory_name) $(git_dirty)\n› '

precmd() {
  title "zsh" "%m" "%55<...<%~"
}

