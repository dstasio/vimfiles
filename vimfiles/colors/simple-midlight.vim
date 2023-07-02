" vi:syntax=vim

" by Davide Stasio, loosely based on base26-atelier-forest-light
" NOTE: gui_cyan and gui_yellow used for unset values
hi clear
syntax reset
let g:colors_name = "simple-light"

" GUI colors
let g:shi_bg       = "D5D3D2" " gui00
let g:shi_bg_alt   = "2E3238" " gui01
let g:shi_fg       = "2E3238" " gui05?
let g:shi_fg_alt   = "2E3238" " gui04
let g:shi_accent   = "2E3238" " gui02
let g:shi_comment  = "2E3238" " gui0D?
let g:shi_keyword  = "209530"  " gui0E
let g:shi_str      = "2E3238"  " gui0B
let g:shi_str_alt  = "2E3238"  " gui0C
let g:shi_number   = "2E3238"  " gui09
let g:shi_preproc  = "2E3238"  " gui08
let g:shi_cursor   = g:shi_accent
let g:shi_error    = g:shi_preproc

let g:shi_err_yellow   = "FFFF00"
let g:shi_err_cyan     = "00FFFF"
let g:shi_err_magenta  = "FF00FF"
let g:shi_err_red      = "FF0000"
let g:shi_err_green    = "00FF00"
let g:shi_err_blue     = "0000FF"

"func highlight()
ru colors/simple-template.vim

" Remove color variables
unlet g:shi_bg g:shi_bg_alt g:shi_fg g:shi_fg_alt g:shi_accent g:shi_comment g:shi_keyword g:shi_str g:shi_str_alt g:shi_number g:shi_preproc g:shi_cursor g:shi_error
unlet g:shi_err_yellow g:shi_err_cyan g:shi_err_magenta g:shi_err_red g:shi_err_green g:shi_err_blue
