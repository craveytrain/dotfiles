#!/usr/bin/env sh

# Boot2Docker init
boot2docker shellinit 2>/dev/null | . /dev/stdin

# Nice little function to get bash on docker container
dbash () { command sudo docker exec -it "$@" bash; }
