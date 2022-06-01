call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'artur-shaik/vim-javacomplete2'

Plug 'tanvirtin/monokai.nvim'

Plug 'Mofiqul/dracula.nvim'

Plug 'itchyny/lightline.vim'

Plug 'ryanoasis/vim-devicons'

Plug 'luochen1990/rainbow'
call plug#end()

hi MatchParen cterm=none ctermbg=none ctermfg=magenta

let g:rainbow_active = 0

autocmd FileType java setlocal omnifunc=javacomplete#Complete

"Import sense
nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
imap <F4> <Plug>(JavaComplete-Imports-AddSmart)
nmap <F5> <Plug>(JavaComplete-Imports-Add)
imap <F5> <Plug>(JavaComplete-Imports-Add)
nmap <F6> <Plug>(JavaComplete-Imports-AddMissing)
imap <F6> <Plug>(JavaComplete-Imports-AddMissing)
nmap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
imap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)

let g:JavaComplete_EnableDefaultMappings = 0

colorscheme dracula

set laststatus=2
set noshowmode
