# todo.sh: https://github.com/ginatrapani/todo.txt-cli
function t() {
  if [ $# -eq 0 ]; then
    todo ls
  else
    todo $*
  fi
}

alias n="t ls +next"