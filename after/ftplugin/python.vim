if exists("g:my_features") && !g:my_features["ftplugin_after"]
  finish
endif

setlocal textwidth=79

" Vim natively comes with this Python completer, but I don't like it, or maybe I
" just don't understand it…
if &omnifunc == "python3complete#Complete"
  setlocal omnifunc=
endif

