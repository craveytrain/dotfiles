# use vim if possible, otherwise vi
if [ -x `which vim` ]; then
    export EDITOR=vim
else
    export EDITOR=vi
fi
