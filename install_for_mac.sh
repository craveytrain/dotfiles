#!/bin/bash

./install_homebrews.sh
./install_npm_packages.sh

echo "Cloning down helpful repos"
./install_repos.sh

echo "Making OSX for elite hackerz"
./osx-for-hackers.sh

printf "\n#################\n\n"
echo -n "Bounce your shell"

# Interesting spinners
# http://stackoverflow.com/questions/2685435/cooler-ascii-spinners
chars="⢀⠠⠐⠈⠐⠠"

# hide cursor
tput civis

while :; do
  for (( i=0; i<${#chars}; i++ )); do
    sleep 0.15
    echo -n "${chars:$i:1}"
  done
done
