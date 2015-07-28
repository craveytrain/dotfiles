#!/bin/bash

# Show the IP addresses of this machine, with each interface that the address is on.
ips () {
	local interface=""
	local types='vmnet|en|eth|vboxnet|vnic'
	local i
	# Loop through interfaces in ifconfig and find ones that have inet that match the types list
	for i in $(
	  ifconfig \
	  | egrep -o '(^('$types')[0-9]|inet (addr:)?([0-9]+\.){3}[0-9]+)' \
	  | egrep -o '(^('$types')[0-9]|([0-9]+\.){3}[0-9]+)' \
	  | grep -v 127.0.0.1
	); do
		# If $i is not an ip address, it's the interface name
	  if ! [ "$( echo "$i" | perl -p -e 's/([0-9]+\.){3}[0-9]+//g' )" == "" ]; then
	    interface="$i":
	  else
	    echo "$interface $i"
	  fi
	done
}

# Create a data URL from an image (works for other file types too, if you tweak the Content-Type afterwards)
dataurl () {
	echo "data:image/${1##*.};base64,$(openssl base64 -in "$1")" | tr -d '\n' | pbcopy
}

headers () {
	curl -IL "$@"
}

# Status web server
# Takes an optional argument of port, otherwise defaults to '8080'
serve () {
	if [[ $OSTYPE == linux* ]]; then
		python2 -m SimpleHTTPServer "${1:-8080}"
	else
		python -m SimpleHTTPServer "${1:-8080}"
	fi
}

# All the dig info, 'cause I can never remember it
digg() {
	dig +nocmd "$1" any +multiline +noall +answer
}
