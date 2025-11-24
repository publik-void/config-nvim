if exists("g:my_features") && !g:my_features["indent_after"]
  finish
endif


" As of 2025-11-24, the `GetJuliaIndent` function of `julia-vim` (and the
" natively shipped indent file that is based on it) still gives some weird
" indentations in various situations that I don't agree with, most notably when
" closing various brackets. Since modifying the function is not so practical,
" I'm disabling some of the `indentkeys`, which happens to result in the right
" thing being done in most cases according to my opinion.
set indentkeys-=0)
set indentkeys-=0]
set indentkeys-=)
set indentkeys-=]
set indentkeys-=}

