if !exists("g:my_features") ||
\ g:my_features["native_filetype_plugins_overrides"]

" As of 2025-08, the `stan` filetpe is not natively supported by (neo-)vim, and
" not even the `stan-nvim` plugin seems to set a `commentstring`, so:
setlocal commentstring=//\%s
if g:loaded_commentary
  let b:commentary_format = "//%s"
endif

endif


