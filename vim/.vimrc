"set rtp+=$GOROOT/misc/vim
filetype plugin indent on
syntax on
set gfn=Operator\ Mono\ Medium:h14,Hack:h14,Source\ Code\ Pro:h15,Menlo:h15
set tabstop=2
set softtabstop=2
set shiftwidth=2
set ruler
set expandtab
set smarttab
set autochdir
set bsdir=last			" Go to last folder when browsing
set incsearch			" Turn on incremental searching
set history=100			" Keep X commands in history
set undolevels=100
set t_Co=256			" Enable 256 colors

"set relativenumber
set number

set nobackup
" Unless you're editing huge files, leave this line active.
" This disables the swap file and puts all data in memory.
" Modern machines can handle this just fine, but if you're
" limited on RAM, comment this out.
set noswapfile

augroup reload_vimrc
  autocmd!
  autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END


call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'mattn/emmet-vim'
Plug 'w0rp/ale'
Plug 'vim-airline/vim-airline-themes'
Plug 'nelstrom/vim-markdown-folding'
Plug 'tpope/vim-markdown'
Plug 'vim-airline/vim-airline'
Plug 'gorodinskiy/vim-coloresque'
Plug 'yggdroot/indentline'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
call plug#end()

" Enable Markdown folding
set foldenable

" Make airline appear all the time
set laststatus=2

" Show word count
let g:airline#extensions#wordcount#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_left_sep=''
let g:airline_right_sep=''

" enable indent lines
let g:indentLine_enabled = 1
let g:indentLine_setColors = 1
let g:indentLine_char_list = ['▏']
let g:indentLine_color_term = 239

" Force Airline to refresh after setup so settings work
":autocmd!
":autocmd VimEnter * :AirlineRefresh

"...
"
"colors
highlight LineNr ctermfg=darkgrey
highlight Comment ctermfg=darkcyan
highlight Normal ctermfg=white
highlight SpellRare ctermbg=NONE cterm=underline
highlight Error term=underline cterm=underline ctermfg=Red ctermbg=NONE
highlight SpellBad cterm=underline
highlight ALESignColumnWithErrors ctermbg=NONE
highlight ALESignColumnWithoutErrors ctermbg=NONE
highlight ALEError ctermbg=NONE ctermfg=Red
highlight ALEErrorSign ctermbg=NONE ctermfg=Red
let g:airline_theme='lavandula'
let g:go_highlight_structs = 1
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_function_parameters = 0
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_function_calls = 1

" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1
let g:ale_fixers = {
      \   'javascript': ['eslint'],
      \   'css': ['prettier'],
      \}

let g:ale_javascript_prettier_options = '--single-quote --trailing-comma es5 --no-semi true'
let g:ale_html_prettier_options = '--single-quote --trailing-comma es5 --no-semi true'
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_on_insert_leave = 1
let g:ale_change_sign_column_color = 1

set ignorecase
set smartcase
set mouse=a

set backspace=indent,eol,start

set showcmd
set wildmenu

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines
set splitright

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /
map <C-space> ?

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext

" useful shortcuts
cnoreabbrev Q qa
cnoreabbrev vertt vert ter

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

"Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" A buffer becomes hidden when it is abandoned
set hid

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" Move a line of text using ALT+[jk] or Command+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfun

" Disable scrollbars
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Turn persistent undo on
"    means that you can undo even when you close a buffer/VIM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
  set undodir=~/.vim_runtime/temp_dirs/undodir
  set undofile
catch
endtry

" Map auto complete of (, ", ', [
inoremap $1 ()<esc>i
inoremap $2 []<esc>i
inoremap $3 {}<esc>i
inoremap $4 {<esc>o}<esc>O
inoremap $q ''<esc>i
inoremap $e ""<esc>i


"autocmd vimenter * NERDTree
"map <C-j> :NERDTreeToggle<CR>
"map <C-k> :NERDTreeFocus<CR>
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"autocmd BufWritePost * NERDTreeFocus | execute 'normal R' | wincmd p


" special syntax
au BufReadPost *.svelte set syntax=html
" au BufRead *.txt highlight Normal ctermfg=Gray

" emmet
"let g:user_emmet_leader_key='<Tab>'
let g:user_emmet_expandabbr_key='<Tab>'
imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

" sessions
nnoremap <Leader>ss :mks!
nnoremap <Leader>sr :so
