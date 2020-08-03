" vim-airline companion theme of lavandula
" (https://github.com/josefaidt/lavandula)
"
" Author:       Josef Aidt <https://github.com/josefaidt/>
" Version:      0.1
" License:      MIT

let g:airline#themes#lavandula#palette = {}

function! airline#themes#lavandula#refresh()
  let g:airline#themes#lavandula#palette.accents = {
    \ 'red': airline#themes#get_highlight('Constant'),
    \ }

  " [ guifg, guibg, ctermfg, ctermbg, opts ]. See "help attr-list" for valid
  " values for the "opt" value.
  let s:N1   = [ '#040119' , '#5ee3cf' , 'Black' , 'Cyan' , 'bold' ]
  let s:N2   = [ '#040119' , '#9da5fb' , 'Black' , 'White' , 'bold' ]
  let s:N3   = [ '#9da5fb' , '#040119' , ''  , ''  , 'bold' ]
  let g:airline#themes#lavandula#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)


  let group = airline#themes#get_highlight('vimCommand')
  let g:airline#themes#lavandula#palette.normal_modified = {
    \ 'airline_c': [ group[0], '', group[2], '', '' ]
    \ }

  " let s:I1 = [ '#47414c' , '#5ee3cf' , 'Black' , 'Green' , 'bold']
  " " let s:I1 = airline#themes#get_highlight2(['PmenuSel', 'bg'], ['MoreMsg', 'fg'], 'bold')
  " let s:I2 = airline#themes#get_highlight2(['MoreMsg', 'fg'], ['PmenuSel', 'bg'])
  " let s:I3 = s:N3
  " let g:airline#themes#lavandula#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
  " let g:airline#themes#lavandula#palette.insert_modified = g:airline#themes#lavandula#palette.normal_modified


  " REPLACE

  " let s:R1   = [ '#040119' , '#e76979' , 'Black'  , 'Red'  , 'bold' ]
  " let s:R2   = [ '#040119' , '#9da5fb' , 'Black' , 'White'  , 'bold' ]
  " let s:R3   = [ '#9da5fb' , '#040119' , ''  , ''  , 'bold' ]
  " let g:airline#themes#lavandula#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)
  " let g:airline#themes#lavandula#palette.replace_modified = g:airline#themes#lavandula#palette.normal_modified

  " let s:R1 = airline#themes#get_highlight2(['PmenuSel', 'bg'], ['Error', 'fg'], 'bold')
  " let s:R2 = s:N2
  " let s:R3 = s:N3
  " let g:airline#themes#lavandula#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)
  " let g:airline#themes#lavandula#palette.replace_modified = g:airline#themes#lavandula#palette.normal_modified

  " let s:E1   = [ '#040119' , '#e76979' , 'Black'  , 'Red'  , 'bold' ]
  " let s:E2   = [ '#040119' , '#9da5fb' , 'Black' , 'White'  , 'bold' ]
  " let s:E3   = [ '#9da5fb' , '#040119' , ''  , ''  , 'bold' ]
  " let g:airline#themes#lavandula#palette.error = airline#themes#generate_color_map(s:E1, s:E2, s:E3)
  " let g:airline#themes#lavandula#palette.error = 
  let s:E1 = [ '#040119' , '#e76979' , 'Black' , 'Red' , '' ]
  let g:airline#themes#lavandula#palette.normal.airline_error = s:E1
  let s:W1 = [ '#040119' , '#e6cc98' , 'Black' , 'Yellow' , '' ]
  let g:airline#themes#lavandula#palette.normal.airline_warning = s:W1
  " let g:airline#themes#lavandula#palette.insert.airline_error = s:E1
  " let g:airline#themes#lavandula#palette.replace.airline_error = s:E1
  " let g:airline#themes#lavandula#palette.inactive.airline_error = s:E1
  " call airline#highlighter#exec('airline_error', s:E1)

  " let pal = g:airline#themes#lavandula#palette
  " for item in ['insert', 'replace', 'visual', 'inactive', 'ctrlp', 'normal']
  "   " exe "let pal.".item." = pal.normal"
  "   exe "let pal.".item".airline_error = s:E1"
  "   " for suffix in ['_modified', '_paste']
  "   "   exe "let pal.".item.suffix. " = s:E1"
  "   " endfor
  " endfor

  " let s:V1 = airline#themes#get_highlight2(['PmenuSel', 'bg'], ['Constant', 'fg'], 'bold')
  " let s:V2 = airline#themes#get_highlight2(['Constant', 'fg'], ['PmenuSel', 'bg'])
  " let s:V3 = s:N3
  " let g:airline#themes#lavandula#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)
  " let g:airline#themes#lavandula#palette.visual_modified = g:airline#themes#lavandula#palette.normal_modified

  " let s:IA = airline#themes#get_highlight2(['NonText', 'fg'], ['CursorLine', 'bg'])
  " let g:airline#themes#lavandula#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)
  " let g:airline#themes#lavandula#palette.inactive_modified = {
  "   \ 'airline_c': [ group[0], '', group[2], '', '' ]
  "   \ }

  let pal = g:airline#themes#lavandula#palette
  for item in ['insert', 'replace', 'visual', 'inactive', 'ctrlp']
    " why doesn't this work?
    " get E713: cannot use empty key for dictionary
    "let pal.{item} = pal.normal
    exe "let pal.".item." = pal.normal"
    for suffix in ['_modified', '_paste']
      exe "let pal.".item.suffix. " = pal.normal"
    endfor
  endfor
endfunction

call airline#themes#lavandula#refresh()
