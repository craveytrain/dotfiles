" ┌─────────────────────────────────────────────────────────────────────┐
" │ SECTION 1: vim-plug Bootstrap                                       │
" │ Purpose: Auto-install vim-plug if not present                       │
" │ Idempotency: Checks for existence before downloading                │
" └─────────────────────────────────────────────────────────────────────┘

if empty(glob('~/.vim/autoload/plug.vim'))
  " Download vim-plug to autoload directory
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  " On first vim startup after download, install all plugins
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ┌─────────────────────────────────────────────────────────────────────┐
" │ SECTION 2: Plugin Declarations                                      │
" │ Purpose: Declare all plugins to be managed by vim-plug              │
" │ Pattern: Plug 'author/repository'                                   │
" └─────────────────────────────────────────────────────────────────────┘

call plug#begin('~/.vim/plugged')

  " Commentary: Easily comment and uncomment code
  " GitHub: https://github.com/tpope/vim-commentary
  " Usage:
  "   - gcc : toggle comment on current line (normal mode)
  "   - gc  : toggle comment on selection (visual mode)
  "   - gcap: toggle comment on paragraph (motion)
  Plug 'tpope/vim-commentary'

  " Additional plugins can be added by users via .vimrc.local
  " Example:
  "   Plug 'junegunn/fzf.vim'
  "   Plug 'preservim/nerdtree'

call plug#end()

" ┌─────────────────────────────────────────────────────────────────────┐
" │ SECTION 3: Base Vim Configuration                                   │
" │ Purpose: Standard vim settings (pre-existing configuration)         │
" └─────────────────────────────────────────────────────────────────────┘

syntax on

" ┌─────────────────────────────────────────────────────────────────────┐
" │ SECTION 4: Local Configuration Override                             │
" │ Purpose: Load machine-specific settings from .vimrc.local           │
" └─────────────────────────────────────────────────────────────────────┘

" Local configuration (machine-specific overrides)
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif
