# This loads RVM into a shell session.
if [[ -s "$HOME/.rvm/scripts/rvm" ]] then
	alias rubies='rvm list rubies'
	alias gemsets='rvm gemset list'
	export CC="/usr/local/bin/gcc-4.2"
	. "$HOME/.rvm/scripts/rvm"
fi