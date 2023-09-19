" This check is recommended by tpope to avoid trouble when accidentally setting
" the `fugitive` file type in the wrong buffer.
if &modifiable
  finish
endif

if !exists("g:my_features") ||
\ g:my_features["native_filetype_plugins_overrides"]

" I'll have to see if this works for me, but thus far, I feel like folding does
" not add much utility and only decreases ease of use in the fugitive buffer.
setlocal nofoldenable

endif

" In a `fugitive` buffer, press `p` to run `:Git push`. I am not sure why a
" mapping like this does not exist in the plugin – it could be that there's a
" good reason or I'm missing something else…
nnoremap <buffer> p :Git push<cr>
if v:version > 800 " NOTE: Version is a guess
  nnoremap <buffer> p <cmd>Git push<cr>
else
  nnoremap <buffer> p :Git push<cr>
endif

