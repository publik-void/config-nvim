" (the following line is a modeline)
" vim: foldmethod=marker

function! MyGitStatuslineField()
  if exists("g:loaded_fugitive") && g:loaded_fugitive
    return FugitiveStatusline()
  else
    return ""
  endif
endfunction
