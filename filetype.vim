" vim: foldmethod=marker

if exists("g:my_features") && !g:my_features["custom_filetype_detection"]
  finish
endif

" {{{1 Filetype detection settings

" This section is meant for config options used by filetype detection scripts.
" This is a bit different than configuring `ftplugin`, `indent`, or `syntax`
" pre- or post-loading the natively shipped scripts. I think this place of the
" possible ones (see the `new-filetype` help tag) is the best suited to put
" these options in.

" Default TeX flavor
let g:tex_flavor = "latex"

