if exists("g:my_features") && !g:my_features["ftplugin_after"]
  finish
endif

" There is a convention in some scheme dialects (and I am not sure to which ones
" this applies and to which not) that `;` be used for comments coming right
" after code on the same line, `;;` be used for comments that are indented like
" the code, and `;;;` be used for comments that are supposed to start at the
" beginning of the line regardless of indentation. With the way commenting in
" `vim-commentary` behaves, it makes sense to set the commentstring to the
" two-semicolon variant.
set commentstring=;;%s

" `tpope/vim-commentary` adds a space after the comment token by default. In
" this case, I prefer to not have that.
if g:loaded_commentary
  let b:commentary_format = ";;%s"
endif

