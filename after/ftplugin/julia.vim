if exists("g:my_features") && !g:my_features["ftplugin_after"]
  finish
endif

if exists("g:my_features") && g:my_features["nvim_lspconfig"]
  " Disable `julia-vim`'s custom `keywordprg` so that the LSP scripts set the
  " default `K` mapping.
  setlocal keywordprg=
endif

