" (the following line is a modeline)
" vim: foldmethod=marker

" Use colorscheme `dim` to inherit terminal colors and extend/modify it a bit
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
function! MyDimModifications() abort
  " Use `cterm` and not `gui` highlights (default, but set explicitly anyway)
  set notermguicolors

  highlight Folded                       ctermfg=NONE ctermbg=NONE cterm=bold
  highlight StatusLine                   ctermfg=NONE ctermbg=NONE cterm=inverse
  highlight Error                        ctermfg=9    ctermbg=NONE
  highlight Todo                         ctermfg=11   ctermbg=NONE
  highlight PmenuThumb                                ctermbg=NONE cterm=inverse
  highlight MatchParen                   ctermfg=14   ctermbg=NONE

  " NOTE: With treesitter, for many filetypes, basically everything that is not
  " a comment, a value, a type, a keyword, or punctuation is considered an
  " identifier, such that pretty much all code is colored. I think that is a bit
  " overkill, thus I'm disabling the highlighting of identifiers here. This may
  " be unfortunate for any languages where identifiers are a distinct from most
  " of the text, so maybe I should go about this smarter (filetype-specific?)…
  " `PreProc` and `Special` have the same color up to here, so let's assign the
  " now-freed `Identifier` color to `PreProc`.
  highlight Identifier                   ctermfg=NONE ctermbg=NONE
  highlight PreProc                      ctermfg=6    ctermbg=NONE

  " For my color scheme family, shades of "grayed-out-ness" work as follows:
  " Color                bg=dark bg=light
  " Grayed out           0       7
  " More grayed out      8       15
  " Foreground, deepened 15      8
  " Foreground, extreme  7       0

  if &background == "light"
    highlight Comment                    ctermfg=7
    highlight LineNr                     ctermfg=15
    highlight CursorLineNr               ctermfg=7
    highlight SignColumn                 ctermfg=15   ctermbg=NONE
    highlight Whitespace                 ctermfg=15
    highlight NonText                    ctermfg=15
    highlight ColorColumn                ctermfg=8    ctermbg=15
    highlight StatusLineNC               ctermfg=7    ctermbg=NONE cterm=inverse
    highlight StatusLineWeak             ctermfg=NONE ctermbg=7    cterm=inverse
    highlight StatusLineNCWeak           ctermfg=7    ctermbg=15   cterm=inverse
    highlight Pmenu                      ctermfg=NONE ctermbg=15
    highlight PmenuSel                   ctermfg=NONE ctermbg=15   cterm=inverse
    highlight PmenuSbar                               ctermbg=7
  else
    highlight Comment                    ctermfg=0
    highlight LineNr                     ctermfg=8
    highlight CursorLineNr               ctermfg=0
    highlight SignColumn                 ctermfg=8    ctermbg=NONE
    highlight Whitespace                 ctermfg=8
    highlight NonText                    ctermfg=8
    highlight ColorColumn                ctermfg=15   ctermbg=8
    highlight StatusLineNC               ctermfg=0    ctermbg=NONE cterm=inverse
    highlight StatusLineWeak             ctermfg=NONE ctermbg=0    cterm=inverse
    highlight StatusLineNCWeak           ctermfg=0    ctermbg=8    cterm=inverse
    highlight Pmenu                      ctermfg=NONE ctermbg=8
    highlight PmenuSel                   ctermfg=NONE ctermbg=8    cterm=inverse
    highlight PmenuSbar                               ctermbg=0
  endif

  if !has("nvim")
    " NOTE: It seems the linking has to be done in this very particular way. (?)
    highlight default clear SpecialKey
    highlight! link SpecialKey Whitespace
  endif
endfunction

augroup MyColors
  if v:version > 800 " NOTE: Version is a guess
    autocmd ColorScheme dim ++nested call MyDimModifications()
  else
    autocmd ColorScheme dim nested call MyDimModifications()
  endif
augroup END

" Set colorscheme only after all the `background` and custom highlighting
" business has been handled.
colorscheme dim

