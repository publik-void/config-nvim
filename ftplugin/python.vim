if exists("g:my_features") && !g:my_features["ftplugin_before"]
  finish
endif

" `shiftwidth` and others would otherwise be set to PEP8-conforming values
let g:python_recommended_style = 0

