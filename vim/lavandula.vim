" vim-airline companion theme of lavandula
" (https://github.com/josefaidt/lavandula)
"
" Author:       Josef Aidt <https://github.com/josefaidt/>
" Version:      0.1
" License:      MIT

" Normal mode
"
let s:N1 = [ '#9da5fb' , '#f8f6f2','18','15']
let s:N2 = [ '#698991' , '#f8f6f2','62','15']
let s:N3 = [ '#3f8f82' , '#2f0c57' , 64, 235 ]
let s:N4 = [ '#9da5fb' , 18 ]

" Insert mode
let s:I1 = [ '#f8f6f2', '#e76979','15','161']
let s:I2 = [ '#2f0c57', '#e76979','235','161']
let s:I3 = [ '#698991', '#f8f6f2', '62', '15']
let s:I4 = [ '#698991' , 62 ]

" Visual mode
let s:V1 = [ '#3f8f82', '#f8f6f2','22','15']
let s:V2 = [ '#f8f6f2', '#3f8f82','15','22']
let s:V3 = [ '#6d5491', '#f8f6f2','64','15']
let s:V4 = [ '#6d5491' , 64 ]

" Replace mode
let s:R1 = [ '#e6cc98' , '#f8f6f2','66','15']
let s:R2 = [ '#e6cc98' , '#2f0c57','66','235']
let s:R3 = [ '#f8f6f2' , '#e6cc98','15','66']
let s:R4 = [ '#e6cc98' , 66 ]

" Paste mode
let s:PA = [ '#e76979' , 161 ]

" Info modified
let s:IM = [ '#242321' , 235 ]

" Inactive mode
let s:IA = [ s:N2[1], s:N3[1], s:N2[3], s:N3[3], '' ]	

let g:airline#themes#lavandula#palette = {}

let g:airline#themes#lavandula#palette.accents = {
      \ 'red': [ '#e76979' , '' , 196 , '' , '' ],
      \ }

let g:airline#themes#lavandula#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)
let g:airline#themes#lavandula#palette.normal_modified = {
    \ 'airline_a': [ s:N1[0] , s:N4[0] , s:N1[2] , s:N4[1] , ''     ] ,
    \ 'airline_b': [ s:N4[0] , s:IM[0] , s:N4[1] , s:IM[1] , ''     ] ,
    \ 'airline_c': [ s:N4[0] , s:N3[1] , s:N4[1] , s:N3[3] , ''     ] }


let g:airline#themes#lavandula#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#lavandula#palette.insert_modified = {
    \ 'airline_a': [ s:I1[0] , s:I4[0] , s:I1[2] , s:I4[1] , ''     ] ,
    \ 'airline_b': [ s:I4[0] , s:IM[0] , s:I4[1] , s:IM[1] , ''     ] ,
    \ 'airline_c': [ s:I4[0] , s:N3[1] , s:I4[1] , s:N3[3] , ''     ] }


let g:airline#themes#lavandula#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)
let g:airline#themes#lavandula#palette.visual_modified = {
    \ 'airline_a': [ s:V1[0] , s:V4[0] , s:V1[2] , s:V4[1] , ''     ] ,
    \ 'airline_b': [ s:V4[0] , s:IM[0] , s:V4[1] , s:IM[1] , ''     ] ,
    \ 'airline_c': [ s:V4[0] , s:N3[1] , s:V4[1] , s:N3[3] , ''     ] }


let g:airline#themes#lavandula#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)
let g:airline#themes#lavandula#palette.replace_modified = {
    \ 'airline_a': [ s:R1[0] , s:R4[0] , s:R1[2] , s:R4[1] , ''     ] ,
    \ 'airline_b': [ s:R4[0] , s:IM[0] , s:R4[1] , s:IM[1] , ''     ] ,
    \ 'airline_c': [ s:R4[0] , s:N3[1] , s:R4[1] , s:N3[3] , ''     ] }


let g:airline#themes#lavandula#palette.insert_paste = {
    \ 'airline_a': [ s:I1[0] , s:PA[0] , s:I1[2] , s:PA[1] , ''     ] ,
    \ 'airline_b': [ s:PA[0] , s:IM[0] , s:PA[1] , s:IM[1] , ''     ] ,
    \ 'airline_c': [ s:PA[0] , s:N3[1] , s:PA[1] , s:N3[3] , ''     ] }


let g:airline#themes#lavandula#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)
let g:airline#themes#lavandula#palette.inactive_modified = {
    \ 'airline_c': [ s:N4[0] , ''      , s:N4[1] , ''      , ''     ] }



