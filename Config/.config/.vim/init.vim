syntax enable
set background=dark
let g:airline_theme = 'catppuccin_mocha'
colorscheme catppuccin

set relativenumber
set cursorline
set cursorcolumn
set number

set ignorecase
set smartcase
set incsearch
set hlsearch

set history=100
set undolevels=100

set confirm
set wildmenu
set wildmode=list:longest,full

set scrolloff=4
set autochdir
set autoread

set showcmd
set showmode
set showmatch

set backspace=indent,eol,start
set tabstop=4
set shiftwidth=4
set expandtab

set clipboard=

let g:clipboard = {
      \ 'name': 'wl-copy/wl-paste',
      \ 'copy': {
      \   '+': 'wl-copy',
      \   '*': 'wl-copy --primary',
      \ },
      \ 'paste': {
      \   '+': 'wl-paste --primary --type text/plain',
      \   '*': 'wl-paste --type text/plain',
      \ },
      \ 'cache_enabled': 1,
      \ }

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
let &t_SR = "\e[4 q"

inoremap jj <Esc>

nnoremap <c-e> 3j
nnoremap <c-y> 3k

nnoremap <Bar> :vsplit<cr>
nnoremap <S--> :split<cr>

vnoremap y y<CR>:call system('wl-copy', @")<CR>
nnoremap yy yy<CR>:call system('wl-copy', @")<CR>
vnoremap p :call setreg('"', system('wl-paste --primary --type text/plain --no-newline'))<CR>p
