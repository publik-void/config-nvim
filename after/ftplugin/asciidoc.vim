if exists("g:my_features") && !g:my_features["ftplugin_after"]
  finish
endif

" Seems like this is not set by default, so I'm setting it manually
setlocal commentstring=//\%s

" `tpope/vim-commentary` adds a space after the comment token by default. In
" this case, I prefer to not have that.
if g:loaded_commentary
  let b:commentary_format = "//%s"
endif

