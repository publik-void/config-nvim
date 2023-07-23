if !exists("g:my_features") ||
\ g:my_features["native_filetype_plugins_overrides"]

" I'll have to see if this works for me, but thus far, I feel like folding does
" not add much utility and only decreases ease of use in the fugitive buffer.
setlocal nofoldenable

endif

