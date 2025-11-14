if exists("g:my_features") && !g:my_features["syntax_before"]
  finish
endif

" Don't highlight operators
let g:julia_highlight_operators = 0

