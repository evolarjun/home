execute pathogen#infect()
filetype indent on      " load filetype-specific indent files
filetype plugin on      " Not sure about this one, but required for csv.vim
syntax on " Enable syntax processing
set cindent " Automatic indenting of blocks with {, etc.
set tabstop=4 " Tabstop = 4
set shiftwidth=4 " When you shift using < or > go this many spaces
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set autoindent
set hl=lu
set wrap
set history=50
set ruler
set bs=2
set showmatch           " highlight matching [{()}]
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set title
set wildmenu            " visual autocomplete for command menu

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" set up leader macros leader is spacebar
let mapleader = "\<Space>"
set timeout timeoutlen=1000  " Let you wait longer before typing something
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :wq<CR>
" Insert date with underline
nnoremap <Leader>d :put=strftime('%c')A<CR>--------------------------<CR><ESC>
" Put quotes around a word
nnoremap <leader>" viw<esc>a"<esc>hbi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>hbi'<esc>lel
" Put quotes around a visual region
vnoremap <Leader>" <esc>`>$a"<esc>`<i"<esc>`>$
vnoremap <Leader>' <esc>`>$a"<esc>`<i'<esc>`>$

" toggle gundo (see http://vimcasts.org/episodes/undo-branching-and-gundo-vim/)
nnoremap <leader>u :GundoToggle<CR>

" set invlist; set noexpandtab
" inoremap <F5> <Esc>:set invlist<CR>:set noexpandtab<CR>a
" nnoremap <F5> :set invlist<CR>:set noexpandtab<CR>
nnoremap <leader>T :set invlist<CR>:set noexpandtab<CR>:set copyindent<CR>:set preserveindent<cr>:set shiftwidth=4<CR>:set tabstop=4<CR>
nnoremap <leader>t :set invlist<CR>:set noexpandtab<CR>
nnoremap <leader>e :set invlist<CR>:set expandtab<CR>
nnoremap <leader>q :q <CR>:q <cr>

" Ent leader macros
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'

""" hotkeys
set pastetoggle=<F6> 
" Uppercase the last word
nnoremap <c-u> <Esc><c-v>bUea 
inoremap <c-u> <c-v>bUel 
" highlight last inserted text
nnoremap gV `[v`]

" nerdcommenter https://github.com/scrooloose/nerdcommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1


" fix number pad
if &term =~ "xterm"
  imap ^[Oq 1
  imap ^[Or 2
  imap ^[Os 3
  imap ^[Ot 4
  imap ^[Ou 5
  imap ^[Ov 6
  imap ^[Ow 7
  imap ^[Ox 8
  imap ^[Oy 9
  imap ^[Op 0
  imap ^[On .
  imap ^[Oo /
  imap ^[Oj *
  imap ^[Om -
  imap ^[Ok +
  if has("terminfo")
    set t_Co=8
    set t_Sf=^[[3%p1%dm
    set t_Sb=^[[4%p1%dm

  else
    set t_Co=8
    set t_Sf=^[[3%dm
    set t_Sb=^[[4%dm
  endif
endif

" This is a slew of commands that create language-specific settings for
" certain filetypes/file extensions. It is important to note they are wrapped
" in an augroup as this ensures the autocmd's are only applied once. In
" addition, the autocmd! directive clears all the autocmd's for the current
" group.
augroup configgroup
    " configuration for vim-pandoc and vim-rmarkdown
    let g:pandoc#modules#disabled = ["folding", "spell"]
    let g:pandoc#syntax#conceal#use = 0
    "let g:pandoc#modules#disabled = ['spell']
    " Use xmllint when you press = in normal mode on an XML file
    autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
augroup END


" Show characters where you have blank lines and other wierd whitespace
" From https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif


" Test to fix vimdiff to ignore whitespace (?)
" from https://stackoverflow.com/questions/1265410/is-there-a-way-to-configure-vimdiff-to-ignore-all-whitespaces#4271247
set diffopt+=iwhite
set diffexpr=DiffW()
function DiffW()
  let opt = ""
   if &diffopt =~ "icase"
     let opt = opt . "-i "
   endif
   if &diffopt =~ "iwhite"
     let opt = opt . "-w " " swapped vim's -b with -w
   endif
   silent execute "!diff -a --binary " . opt .
     \ v:fname_in . " " . v:fname_new .  " > " . v:fname_out
endfunction

