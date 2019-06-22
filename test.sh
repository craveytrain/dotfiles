#!/usr/bin/env sh

DOCKER_NAME="prompt"

# Build docker container if it does not exist currently
if [ ! "$(docker images -q $DOCKER_NAME)" ]; then
  echo "Image does not exist"
  docker build -t $DOCKER_NAME .
fi

# Exit with error message
bad_arg() {
  echo "Shell must be 'bash' or 'zsh'"
  exit 2
}

# check for empty arguments
[ -z "$1" ] && bad_arg

# validate argument is 'bash' or 'zsh'
while test $# -gt 0
do
    case "$1" in
        "bash") DOCKER_SHELL="bash"
            ;;
        "zsh") DOCKER_SHELL="zsh"
            ;;
        *) bad_arg
    esac
    shift
done

docker run -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 -e TERM="$TERM" -it --rm -v "$(pwd):/root/.dotfiles" -w "/root/.dotfiles" $DOCKER_NAME bash -uxec "exec $DOCKER_SHELL"
