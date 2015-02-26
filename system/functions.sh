# Show the IP addresses of this machine, with each interface that the address is on.
ips () {
	local interface=""
	local types='vmnet|en|eth|vboxnet|vnic'
	local i
	# for i in $(
	#   ifconfig \
	#   | egrep -o '(^('$types')[0-9]|inet (addr:)?([0-9]+\.){3}[0-9]+)' \
	#   | egrep -o '(^('$types')[0-9]|([0-9]+\.){3}[0-9]+)' \
	#   | grep -v 127.0.0.1
	# ); do
	#   if ! [ "$( echo $i | perl -pi -e 's/([0-9]+\.){3}[0-9]+//g' )" == "" ]; then
	#     interface="$i":
	#   else
	#     echo $interface $i
	#   fi
	# done

	for i in $(
		ifconfig \
		| ack "^([$types]\w+):" \
		| awk '{ print $1 }'
		); do
	echo "$i $(ipconfig getifaddr ${i%:})"
done
}

# Create a data URL from an image (works for other file types too, if you tweak the Content-Type afterwards)
dataurl () {
	echo "data:image/${1##*.};base64,$(openssl base64 -in "$1")" | tr -d '\n' | pbcopy
}

headers () {
	curl -IL "$@"
}

# Extract most know archives with one command
extract () {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xjf $1     ;;
*.tar.gz)    tar xzf $1     ;;
*.bz2)       bunzip2 $1     ;;
*.rar)       unrar e $1     ;;
*.gz)        gunzip $1      ;;
*.tar)       tar xf $1      ;;
*.tbz2)      tar xjf $1     ;;
*.tgz)       tar xzf $1     ;;
*.zip)       unzip $1       ;;
*.Z)         uncompress $1  ;;
*.7z)        7z x $1        ;;
*)     echo "'$1' cannot be extracted via extract()" ;;
esac
else
	echo "'$1' is not a valid file"
fi
}

# Status web server
# Takes an optional argument of port, otherwise defaults to '8080'
serve () {
	if [[ $OSTYPE == linux* ]]; then
		python2 -m SimpleHTTPServer ${1:-8080}
	else
		python -m SimpleHTTPServer ${1:-8080}
	fi
}
