" (the following line is a modeline)
" vim: foldmethod=marker

" Don't define this native autocompletion if another one is already in place
if !exists("g:loaded_cmp") || !g:loaded_cmp

  " Separated this into an extra script because it seems to me like not sourcing
  " is faster than sourcing a branch that does not get executed. Also, maybe
  " I'll extend this to Lua at some point? Well, probably not…
  call Include("/include/autocompletion/autocompletion", "vim")

endif
