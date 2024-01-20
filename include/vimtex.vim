" (the following line is a modeline)
" vim: foldmethod=marker

" Choose compiler based on availability
let g:vimtex_compiler_method = executable("latexmk") ? "latexmk" : "tectonic"

" NOTE: In the past, I had tried to set up a `latexmk` compiler in a Docker
" container. I believe that this should in theory be perfectly possible to the
" point of basically having a drop-in `latexmk` shell script that forwards all
" the environment variables, dotfiles, and arguments into the container. But
" since I'm not aware of such a thing existing, I'd have to write it myself, at
" which point I'm probably better off just taking the plunge and installing a
" LaTeX distribution on my system.

" Parsing bibliographies for e.g. cite completion: only use `bibtex` if it is
" available. The `"vim"` backend is apparently more robust but slower.
let g:vimtex_parser_bib_backend = executable("bibtex") ? "bibtex" : "vim"

" `:VimtexCompile`, also mapped to `<localleader>ll` by default, runs a one-shot
" compilation, unless the compiler supports continuous mode, in which case it
" toggles the continuous compiler process. Let's define a function here that
" calls `:VimtexCompile` unless a compiler is running, so that either a one-shot
" compilation is triggered unless the last one hasn't finished, or the function
" makes sure a continuous compilation is running and starts one if not.
function MyVimtexCompileUnlessRunning()
  if g:loaded_vimtex && exists("b:vimtex") && !b:vimtex.compiler.is_running()
    VimtexCompile
  endif
endfunction

augroup MyVimtexConfig
  autocmd!

  " NOTE: Commented this out for now, as it may be too much.
  " Start a one-shot or continuous compilation process on initialization
  "autocmd User VimtexEventInitPost call MyVimtexCompileUnlessRunning()

  " For LaTeX filetypes, create an autocommand that compiles on write unless a
  " compiler is already running (possibly in continuous mode and thus taking
  " care of the compile-on-write already)
  autocmd FileType tex
  \ autocmd! MyVimtexConfig BufWritePost * call MyVimtexCompileUnlessRunning()

  " When the last buffer of a LaTeX project is closed, remove auxiliary files
  autocmd User VimtexEventQuit call vimtex#compiler#clean(0)
augroup END

" Disable viewer interface
" NOTE: I'd need to set up a bunch of stuff to be able to use this properly. I
" was fine using `Preview.app` and compile-on-write thus far, so let's keep it
" simple like that for now.
let g:vimtex_view_enabled = 0

" Disable conceal features
let g:vimtex_syntax_conceal_disable = 1

