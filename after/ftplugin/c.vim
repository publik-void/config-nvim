" NOTE: This file gets sourced for C++ filetypes as well

if exists("g:my_features") && !g:my_features["ftplugin_after"]
  finish
endif

" Vim comes with a plugin called `ccomplete` which is provides an omnifunc that
" uses `ctags` files for completion. This omnifunc is always set by the `c.vim`
" filetype plugin and simply does not provide matches if no `ctags` files exist.
" As I usually don't use `ctags` but have an autocompletion mechanism that
" decides which completion to run based on whether an omnifunc is set, I would
" rather have it not set.
if &omnifunc == "ccomplete#Complete"
  setlocal omnifunc=
endif

" The default here seems to be `/*%s*/`, which I tend to use less.
" NOTE: So as far as I can tell, the `/*%s*/` notation has always been the
" default `commentstring` on Vim. However, on some newer Neovim versions (e.g.
" 0.9), there is an additional `c.lua` filetype plugin included with the
" software that also sets this, and if I want to override that, it seems I need
" an extra `c.lua` file doing that.
setlocal commentstring=//\%s

" `tpope/vim-commentary` adds a space after the comment token by default. In
" this case, I prefer to not have that.
if g:loaded_commentary
  let b:commentary_format = "//%s"
endif

