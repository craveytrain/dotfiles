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

# add user folders
path_unshift $HOME/bin
path_unshift $HOME/local/node/bin


# add /usr/local bindirs
path_unshift /usr/local/bin
path_unshift /usr/local/sbin
pathadd /usr/local/mysql/bin
