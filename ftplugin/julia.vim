if exists("g:my_features") && !g:my_features["ftplugin_before"]
  finish
endif

" Don't have the shiftwidth be set to 4
let g:julia_set_indentation = 0

