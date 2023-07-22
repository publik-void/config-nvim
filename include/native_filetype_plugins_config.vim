" (the following line is a modeline)
" vim: foldmethod=marker

" The filetype plugins included with (Neo-)Vim have configuration options.
" This script configures some of them.

" {{{1 TeX
" Default TeX flavor
let g:tex_flavor = "latex"

" Disable concealing
let g:tex_conceal = ""

" {{{1 Python
" `shiftwidth` and others would otherwise be set to PEP8-conforming values
let g:python_recommended_style = 0

" {{{1 Julia
" Don't have the shiftwidth be set to 4
let g:julia_set_indentation = 0

" Don't highlight operators
let g:julia_highlight_operators = 0

