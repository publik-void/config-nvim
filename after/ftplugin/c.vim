" NOTE: This file gets sourced for C++ filetypes as well

" Vim comes with a plugin called `ccomplete` which is provides an omnifunc that
" uses `ctags` files for completion. This omnifunc is always set by the `c.vim`
" filetype plugin and simply does not provide matches if no `ctags` files exist.
" As I usually don't use `ctags` but have an autocompletion mechanism that
" decides which completion to run based on whether an omnifunc is set, I would
" rather have it not set.
if &omnifunc == "ccomplete#Complete"
  set omnifunc=
endif
