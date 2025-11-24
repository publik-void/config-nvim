if exists("g:my_features") && !g:my_features["indent_before"]
  finish
endif

" Don't do custom alignment in multi-line `import` etc. lists
let g:julia_indent_align_import = 0

" Don't do custom alignment in multi-line bracketed expressions
let g:julia_indent_align_brackets = 0

