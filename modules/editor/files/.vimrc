syntax on

" Local configuration (machine-specific overrides)
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
