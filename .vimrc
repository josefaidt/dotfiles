"set rtp+=$GOROOT/misc/vim

" General settings
filetype plugin indent on
set gfn=Operator\ Mono\ Medium:h14
set tabstop=2
set softtabstop=2
set shiftwidth=2
set encoding=UTF-8
set mouse=a
set noerrorbells
set expandtab
set smarttab
set autochdir
set bsdir=last		" Go to last folder when browsing
set incsearch			" Turn on incremental searching
set history=100	  " Keep X commands in history
set undolevels=100
set number        "set relativenumber
set nobackup
" Unless you're editing huge files, leave this line active.
" This disables the swap file and puts all data in memory.
" Modern machines can handle this just fine, but if you're
" limited on RAM, comment this out.
set noswapfile
set undodir=~/.vim/undodir
set undofile
set ignorecase
set smartcase
set backspace=indent,eol,start
set showcmd
set wildmenu
set autoindent "Auto indent
set smartindent "Smart indent
set wrap "Wrap lines
set splitright
" Enable Markdown folding
set foldenable
" Make airline appear all the time
set laststatus=2
" Format the status line
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
"Always show current position
set ruler
" Height of the command bar
set cmdheight=2
" A buffer becomes hidden when it is abandoned
set hid
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

augroup reload_vimrc
  autocmd!
  autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END


call plug#begin('~/.vim/plugged')
" NERDTree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'preservim/nerdcommenter'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" COC
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'w0rp/ale'
Plug 'vim-airline/vim-airline-themes'
Plug 'nelstrom/vim-markdown-folding'
Plug 'tpope/vim-markdown'
Plug 'vim-airline/vim-airline'
Plug 'gorodinskiy/vim-coloresque'
" indent line whitespace
Plug 'yggdroot/indentline'
Plug 'ctrlpvim/ctrlp.vim' " fuzzy find files
Plug 'christoomey/vim-tmux-navigator' " enables tmux navigation
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'justinmk/vim-sneak'
Plug 'jparise/vim-graphql'
" JS
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'yuezk/vim-js'               " JS syntax
Plug 'maxmellon/vim-jsx-pretty'   " JSX syntax
"Plug 'leafgarland/typescript-vim' " TypeScript syntax
Plug 'herringtondarkholme/yats.vim'
Plug 'jparise/vim-graphql'        " GraphQL syntax
" Git Tooling
Plug 'mhinz/vim-signify' " Sign Columns
Plug 'tpope/vim-fugitive' " Run `:git` commands
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim' " Git commit browser
Plug 'airblade/vim-gitgutter'
call plug#end()

" Coc config
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-emmet',
  \ 'coc-css',
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-python',
  \ 'coc-explorer',
  \ ]

set conceallevel=0
let mapleader = ' '

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

"colors
syntax enable
filetype plugin indent on
set t_Co=256			" Enable 256 colors
highlight LineNr ctermfg=darkgrey
highlight Comment ctermfg=darkcyan
highlight Normal ctermfg=white
highlight SpellRare ctermbg=NONE cterm=underline
highlight Error term=underline cterm=underline ctermfg=Red ctermbg=NONE
highlight SpellBad cterm=underline
highlight ColorColumn ctermbg=0 guibg=lightgrey
highlight VertSplit ctermfg=Black ctermbg=DarkGray
" ALE colors
highlight ALESignColumnWithErrors ctermbg=NONE
highlight ALESignColumnWithoutErrors ctermbg=NONE
highlight ALEError ctermbg=NONE ctermfg=Red
highlight ALEErrorSign ctermbg=NONE ctermfg=Red
" CoC Colors
highlight Pmenu guibg=DarkGrey ctermbg=0 ctermfg=white
highlight PmenuSel guibg=Magenta guifg=Black ctermbg=Magenta ctermfg=Black

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

" Indent Line
set conceallevel=0
let g:indentLine_setConceal = 0
" Airline Customization
"let g:airline_section_z = '%{coc#status()}' 

" Set this. Airline will handle the rest.
"let g:airline#extensions#ale#enabled = 1
"let g:ale_fixers = {
      "\   'javascript': ['eslint'],
      "\   'css': ['prettier'],
      "\}

"let g:ale_javascript_prettier_options = '--single-quote --trailing-comma es5 --no-semi true'
"let g:ale_html_prettier_options = '--single-quote --trailing-comma es5 --no-semi true'
"let g:ale_sign_error = '●'
"let g:ale_sign_warning = '.'
"let g:ale_lint_on_text_changed = 'always'
"let g:ale_lint_on_insert_leave = 1
"let g:ale_change_sign_column_color = 1
"

"
" Fish shell
" 
if &shell =~# 'fish$'
    set shell=sh
endif
autocmd FileType fish compiler fish

"
" COC Configuration
"
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}




" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" => Turn persistent undo on
try
  set undodir=~/.vim_runtime/temp_dirs/undodir
  set undofile
catch
endtry

" special syntax
au BufReadPost *.svelte set syntax=html

" Shortcuts
if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif

" sessions
nnoremap <Leader>ss :mks!
nnoremap <Leader>sr :so

:nmap <C-e> :CocCommand explorer<CR>
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>ty :tabn<cr>
map <leader>tr :tabp<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext

" Useful mapping for traversing buffers
"nnoremap <C-h> :bprev<CR>
"nnoremap <C-l> :bnext<CR>

" Move a line of text using ALT+[jk] or Command+[jk] on mac
nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
inoremap <M-j> <Esc>:m .+1<CR>==gi
inoremap <M-k> <Esc>:m .-2<CR>==gi
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv

" Replicate a line of text using ALT+SHIFT+[jk]
nnoremap <M-J> yy$p k<CR>==
nnoremap <M-K> yy$P k<CR>==
inoremap <M-J> <Esc>yy$p k<CR>==gi
inoremap <M-K> <Esc>yy$P k<CR>==gi
vnoremap <M-J> y$p k<CR>gv==gv
vnoremap <M-J> y$p k<CR>gv==gv

" NERDcommentor
" Remap comment key
nmap <leader>++ <plug>NERDCommenterToggle
vmap <leader>++ <plug>NERDCommenterToggle

" NERDTree
" sync open file with NERDTree
" Check if NERDTree is open or active
function! IsNERDTreeOpen()        
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" file, and we're not in vimdiff
function! SyncTree()
  if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
    wincmd p
  endif
endfunction

" Highlight currently open buffer in NERDTree
autocmd BufEnter * call SyncTree()
nmap <C-b> :NERDTreeToggle<CR>

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Prettier Coc
command! -nargs=0 Prettier :CocCommand prettier.formatFile
