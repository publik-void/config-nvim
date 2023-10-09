" (the following line is a modeline)
" vim: foldmethod=marker

if g:loaded_fugitive
  function! MyGitStatuslineField()
    return FugitiveStatusline()
  endfunction
endif
