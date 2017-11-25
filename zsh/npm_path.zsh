autoload -U add-zsh-hook
npm-path() {
  if hash npm 2>/dev/null; then
    path=(
      $(npm bin)
      $path
    )
  fi
}
add-zsh-hook chpwd npm-path
npm-path
