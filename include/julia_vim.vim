" vim: foldmethod=marker

" NOTE: Since there is overlap between the `ftplugin`, `indent`, etc. files
" shipped natively and those from `julia-vim`, I'm doing much of the
" configuration through that system instead of here to target both variants.
"
" I'm also specifically overriding `autoload/LaTeXtoUnicode.vim`, which is like
" a sub-plugin of `julia-vim`.

runtime macros/matchit.vim
