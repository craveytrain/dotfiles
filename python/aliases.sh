if [[ $OSTYPE == linux* ]]; then
	alias http='python2 -m SimpleHTTPServer 8080'
else
	alias http='python -m SimpleHTTPServer 8080'
fi
