if [[ $OSTYPE == linux* ]]; then
	alias serve='python2 -m SimpleHTTPServer 8080'
else
	alias serve='python -m SimpleHTTPServer 8080'
fi
