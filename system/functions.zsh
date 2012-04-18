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