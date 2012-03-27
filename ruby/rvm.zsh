# This loads RVM into a shell session.
if [[ -s "$HOME/.rvm/scripts/rvm" ]] then
	export CC="/usr/local/bin/gcc-4.2"
	. "$HOME/.rvm/scripts/rvm"
fi