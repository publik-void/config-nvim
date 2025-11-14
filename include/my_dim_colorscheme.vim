" (the following line is a modeline)
" vim: foldmethod=marker

" Use colorscheme `dim` to inherit terminal colors and extend/modify it a bit
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
function! MyDimModifications() abort
  " Use `cterm` and not `gui` highlights (default, but set explicitly anyway)
  set notermguicolors

  highlight Underlined                 ctermfg=NONE ctermbg=NONE cterm=underline
  highlight Title                      ctermfg=NONE ctermbg=NONE cterm=bold

  highlight Folded                     ctermfg=NONE ctermbg=NONE cterm=bold
  highlight StatusLine                 ctermfg=NONE ctermbg=NONE cterm=inverse
  highlight Error                      ctermfg=9    ctermbg=NONE cterm=NONE
  highlight Todo                       ctermfg=11   ctermbg=NONE cterm=NONE
  highlight PmenuThumb                              ctermbg=NONE cterm=inverse
  highlight MatchParen                 ctermfg=14   ctermbg=NONE cterm=NONE

  highlight Identifier                 ctermfg=4
  highlight PreProc                    ctermfg=12

  " Also, somehow, I am more used to types being yellow and keywords being green
  " than vice versa and would like to keep it that way…
  highlight Statement                  ctermfg=2
  highlight Type                       ctermfg=3

  " For my color scheme family, shades of "grayed-out-ness" work as follows:
  " Color                bg=dark bg=light
  " Grayed out           0       7
  " More grayed out      8       15
  " Foreground, deepened 15      8
  " Foreground, extreme  7       0

  if &background == "light"
    highlight Comment                  ctermfg=7                 cterm=NONE
    highlight LineNr                   ctermfg=15                cterm=NONE
    highlight CursorLineNr             ctermfg=7                 cterm=NONE
    highlight SignColumn               ctermfg=15   ctermbg=NONE cterm=NONE
    highlight Whitespace               ctermfg=15                cterm=NONE
    highlight NonText                  ctermfg=15                cterm=NONE
    highlight ColorColumn              ctermfg=8    ctermbg=15   cterm=NONE
    highlight StatusLineNC             ctermfg=7    ctermbg=NONE cterm=inverse
    highlight StatusLineWeak           ctermfg=NONE ctermbg=7    cterm=inverse
    highlight StatusLineNCWeak         ctermfg=7    ctermbg=15   cterm=inverse
    highlight Pmenu                    ctermfg=NONE ctermbg=15   cterm=NONE
    highlight PmenuSel                 ctermfg=NONE ctermbg=15   cterm=inverse
    highlight PmenuSbar                             ctermbg=7    cterm=NONE
  else
    highlight Comment                  ctermfg=0                 cterm=NONE
    highlight LineNr                   ctermfg=8                 cterm=NONE
    highlight CursorLineNr             ctermfg=0                 cterm=NONE
    highlight SignColumn               ctermfg=8    ctermbg=NONE cterm=NONE
    highlight Whitespace               ctermfg=8                 cterm=NONE
    highlight NonText                  ctermfg=8                 cterm=NONE
    highlight ColorColumn              ctermfg=15   ctermbg=8    cterm=NONE
    highlight StatusLineNC             ctermfg=0    ctermbg=NONE cterm=inverse
    highlight StatusLineWeak           ctermfg=NONE ctermbg=0    cterm=inverse
    highlight StatusLineNCWeak         ctermfg=0    ctermbg=8    cterm=inverse
    highlight Pmenu                    ctermfg=NONE ctermbg=8    cterm=NONE
    highlight PmenuSel                 ctermfg=NONE ctermbg=8    cterm=inverse
    highlight PmenuSbar                             ctermbg=0    cterm=NONE
  endif

  highlight! link NormalFloat Pmenu

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

