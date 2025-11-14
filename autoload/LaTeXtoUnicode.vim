" To override the `LaTeXtoUnicode` sub-plugin of `julia-vim`, because I don't
" need it. Like this, its script file should not even be read.

function! LaTeXtoUnicode#Refresh(...) abort
  return ''
endfunction

function! LaTeXtoUnicode#Init(...) abort
  return ''
endfunction

function! LaTeXtoUnicode#Enable(...) abort
  return ''
endfunction

function! LaTeXtoUnicode#Disable(...) abort
  return ''
endfunction

function! LaTeXtoUnicode#Toggle(...) abort
  return ''
endfunction

