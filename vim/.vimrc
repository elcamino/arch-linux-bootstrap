execute pathogen#infect()

colors gurunew

syntax on
filetype plugin on 

set t_Co=256

set shell=/bin/sh
set nocompatible  " Use Vim defaults instead of 100% vi compatibility
set backspace=indent,eol,start  " more powerful backspacing

" Now we set some defaults for the editor
set history=500    " keep 50 lines of command line history
set ruler   " show the cursor position all the time

" modelines have historically been a source of security/resource
" vulnerabilities -- disable by default, even when 'nocompatible' is set
set nomodeline

set tabstop=2
set shiftwidth=2
"set expandtab
set wildmenu
set wildmode=list:longest
set ruler
set hlsearch
set incsearch
set hidden
set number
set laststatus=2

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif


"autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1 
"autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
"autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
"autocmd FileType ruby,eruby let g:rubycomplete_load_gemfile = 1

let g:GPGUseAgent = 0
let g:GPGUsePipes = 1


let g:go_disable_autoinstall = 0

let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1

let g:airline_theme='molokai'
" let g:airline_powerline_fonts = 1

" Highlight
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
" let g:go_fmt_command = "goimports"


let g:tagbar_type_go = {  
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

nmap <F8> :TagbarToggle<CR>
nmap <C-N><C-N> :set invnumber<CR>
