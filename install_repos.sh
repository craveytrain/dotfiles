#!/usr/bin/env bash
# to enforce bash 4

declare -A repos
repos["powerline_fonts"]="https://github.com/powerline/fonts.git"
repos["solarized"]="https://github.com/altercation/solarized.git"
repos["google_fonts"]="https://github.com/google/fonts.git"
repos["tomorrow_theme"]="https://github.com/chriskempson/tomorrow-theme.git"
repos["FiraCode"]="https://github.com/tonsky/FiraCode.git"

DIR="$HOME/Src"

if [ ! -d "$DIR" ]; then
  mkdir $DIR
fi

cd $DIR || exit

for repo in "${!repos[@]}"; do
  if [ ! -d "$repo" ]; then
    # only install it if it's not already there
    git clone ${repos[${repo}]} "$repo"
  fi
done
