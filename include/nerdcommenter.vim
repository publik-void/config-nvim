" (the following line is a modeline)
" vim: foldmethod=marker

" The plugin would usually create a whole bunch of `<leader>`… mappings
let g:NERDCreateDefaultMappings = 0

let g:NERDCommentEmptyLines = 1

let g:NERDTrimTrailingWhitespace = 1

" " NOTE: `<gt>` does not exist, instead `<char-62>` can be used
" map <lt> <plug>NERDCommenterUncomment
" map <char-62> <plug>NERDCommenterAlignBoth
" vmap <char-62> <plug>NERDCommenterComment

map <c-h> <plug>NERDCommenterUncomment
map <c-l> <plug>NERDCommenterAlignBoth
vmap <c-l> <plug>NERDCommenterComment

