" `init.vim` or '`.vimrc`' file thrown together by me.

" (the following line is a modeline)
" vim: foldmethod=marker

" {{{1 General notes and todos

" TODO: Think about porting this to Lua? Or should I try to remain somewhat
" close to regular Vim? -> Maybe with the basics
" TODO: Work through this article: https://aca.github.io/neovim_startuptime.html
" TODO: This looks interesting as well: https://github.com/nathom/filetype.nvim
" TODO: Have individual files for specific file types? E.g. set conceallevel and
" shiftwidth for `filetype`s such as JSON, Python, TeX, …, instead of in here.
" This may come in handy:
" https://vi.stackexchange.com/questions/14371/why-files-in-config-nvim-after-ftplugin-are-not-taken-into-acount
" TODO: Some parts of this file would fit neatly into smaller collections
" representing one 'feature'. Like e.g. all LaTeX stuff could be put into a
" small unit, that I could then enable or disable in the beginning of this file,
" depending on something like hostname, version, availability of binaries, etc.
" I probably don't need LaTex on a Raspberry Pi and I might not be able to use
" some newer plugins on platforms with old nvim version, etc…

" {{{1 Essential initializations and platform info

" POSIX compliance needed
set shell=sh

" Get platform info
" to find out if it's Neovim, run `has('nvim')`
" vim version already resides in variable `v:version`
let s:user = substitute(system('whoami'), '\n', '', '')
let s:hostname = substitute(system('hostname'), '\n', '', '')

" {{{1 Neovim providers

" Set the location of the Python 3 binary. `provider.txt` says setting this
" makes startup faster.
" Note: Python 3 needs the `pynvim` package installed.
if s:hostname == "lasse-mbp-0"
  let g:python3_host_prog = '/usr/local/bin/python3'
elseif s:hostname == "lasse-mba-0"
  let g:python3_host_prog = '/usr/local/bin/python3'
elseif s:hostname == "lasse-alpine-env-0"
  let g:python3_host_prog = '/usr/bin/python3'
elseif s:hostname == "lasse-debian-0"
  let g:python3_host_prog = '/usr/bin/python3'
endif

" Explicitly disable some (unneeded?) providers. Not sure if this is sensible.
let g:loaded_python_provider = 0
"let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0

" Tell Python X to always use Python 3
set pyxversion=3

" {{{1 vim-plug

" `vim-plug` needs to be installed beforehand, I have not automated that here.
" I chose the directory name `plugged` as suggested by the `vim-plug` readme.

" TODO: What about Neovim's native plugin manager? Is it good enough to justify
" dropping `vim-plug` at some point?

call plug#begin('~/.config/nvim/plugged')

" 2022-02: Some general thoughts on autocompletion/linting/LSP plugins: When I
" started using Vim seriously around 2018 or so, I was in search of this
" functionality, particularly in regards to C++. At that time, YouCompleteMe
" seemed to be the de-facto standard for this. Since then, LSP has seen wide
" adoption, and a lot more options have popped up. As far as I can tell, ALE was
" indeed a mere linting engine, while YCM didn't even implement LSP. Today, the
" waters have been muddied because each plugin wants to do it all now. Which
" sort of makes sense, since completion, linting, even syntax highlighting, and
" so on are relatively closely coupled functionalities, so not necessarily the
" kind of stuff that you absolutely want to keep modular and separate. Beyond
" ALE and YCM, there exist a selection of other plugins. Of these, `coc` seems
" to be relatively popular at the moment. It depends on Node.js, however, which
" is something I would be glad to avoid – perhaps without good reasons except my
" taste – I don't know. I am not completely sure what to make of this at the
" moment, but I guess for now I'll simply limit YCM to the CXX-family
" `filetype`s, since I get the feeling that it's still very comprehensive for
" those (although I also get the feeling that the other options can deliver
" similar power), and then try to do the rest with ALE and perhaps Deoplete
" (which is already being gradually replaced by `ddc`, however). Migrating away
" from YCM may prove beneficial in the end, because (a) I can reduce the number
" of (potentially interfering) plugins, (b) YCM is not that light-weight, and
" (c) YCM has this non-trivial post-update hook which tends to fail if things
" are not set up properly, making the process somewhat tedious.
" Another point that adds to all of this is that Neovim is in the process of
" enabling support for LSP natively at the moment, so who knows, perhaps I won't
" need any plugins for this anymore at some point.
" I will probably remove this whole comment block at some point in the future,
" but for now it serves as a reference on the current state of affairs, or at
" least my grasp of it, and I want to have it in the commit history.

Plug 'dense-analysis/ale'

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" YCM needs a working Python environment and Cmake to install itself.
" Consequently, I enable YCM only on some hosts.
" TODO: Separate the hostname-dependent part out and define some general on/off
" and config switches for plugins?
if s:hostname == "lasse-mbp-0" || s:hostname == "lasse-mba-0" || s:hostname == "lasse-debian-0"
  Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clang-completer' }
end

" On alpine, use system libclang.
if s:hostname == "lasse-alpine-env-0"
  Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clang-completer --system-libclang' }
end

Plug 'preservim/nerdcommenter'

" Disabled for now in favor of vim-ranger
"Plug 'ctrlpvim/ctrlp.vim' " TODO: Substitute with Telescope?

Plug 'dag/vim-fish'

" Seems like this is a newer and better fish syntax plugin, but at the moment I
" get errors when using it…
" TODO: Could this be because of my additional config for fish files below?
"Plug 'khaveesh/vim-fish-syntax'

Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim' " Dependency of `ranger.vim`

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat' " Makes `.` work for `vim-surround`.

"Plug 'junegunn/goyo.vim'

Plug 'matcatc/vim-asciidoc-folding' " I'll need this as long as the official
" Asciidoc syntax support does not support folding

"Plug 'https://github.com/arnoudbuzing/wolfram-vim.git' " This is only a syntax
"" file, not a 'real' plugin

"Plug 'guns/xterm-color-table.vim'

" If at some point I'll switch to lazy plugin loading: VimTeX should not be
" loaded lazily.
Plug 'lervag/vimtex'

Plug 'JuliaEditorSupport/julia-vim'

" Modification of Vim's default color scheme, using only ANSI colors
Plug 'jeffkreeftmeijer/vim-dim', {'branch': '1.x'}

call plug#end()

" {{{1 `background` handling

" Note: As a summary for the below notes: Getting iTerm2, tmux and Neovim (and
" possibly also other terminals and SSH/Mosh) to play nicely together so that
" the `background` option is always synchronized automatically is something
" people are definitely working on here and there, but it seems like the state
" of things is not quite ideal at the moment. I'll try to cover some reasonable
" cases but may have to set `background` manually in some instances.
" Note: Setting `background` should be done automatically by Neovim. This seems
" to depend on some `autocmd`, so deleting all autocommands in the beginning of
" the vimrc file (like some do) breaks it. The detection uses an OSC11 escape
" sequence, which is basically a query to the Terminal about its background
" color.
" Note: iTerm2 sends `SIGWINCH` on profile changes and Neovim has an `autocmd
" Signal SIGWINCH`. I don't know if `SIGWINCH` triggers re-detection of
" background color already or if an extra `autocmd` needs to be added here.
" Also, I can't even get any such autocommand to work with my setup…
" Note: The automatic detection does not work inside `tmux`, as `tmux` does not
" respond to the OSC11 escape sequence. This is because `tmux` could be running
" in several terminals simultaneously. If the background color in `tmux` was set
" by the user, it does respond, but this means I would then need to manage the
" synchronization of `tmux`'s background color with the terminal's colors, which
" seems unnecessarily non-elegant and error-prone.
" Note: Neovim removed some code that used the environment variable `COLORFGBG`
" for detecting a light or dark background. This is unfortunate, as it should be
" possible to propagate this variable through `tmux`, `ssh`, etc. Still, another
" problem is that the variable won't be updated on changes.

" Let's put this into a function that can be extended with OSC11 and other
" utilities if I feel the need, and can perhaps be called on certain triggers.
function AttemptBackgroundDetect()
  if empty($COLORFGBG)
    set background=light
  else
    let [l:fg, l:bg] = split($COLORFGBG, ';')
    " So, what to include here and what not? Let's say white and bright colors
    " except bright black.
    let l:light_colors = ['7', '9', '10', '11', '12', '13', '14', '15']
    if index(l:light_colors, l:bg) >= 0
      set background=light
    else
      set background=dark
    endif
  endif
endfunction

" Run it once, now
call AttemptBackgroundDetect()

" And add it as an `autocmd`
augroup MyBackgroundDetect
  " Note: the `++nested` is needed to re-apply the color scheme in response to
  " the `background` option's value changing
  autocmd Signal SIGWINCH ++nested call AttemptBackgroundDetect()
  "" These are a sad workaround because SIGWINCH doesn't seem to work for me
  "autocmd CursorHold * ++nested call AttemptBackgroundDetect()
  "autocmd CursorHoldI * ++nested call AttemptBackgroundDetect()
augroup END

" {{{1 Colors

" Use colorscheme `dim` to inherit terminal colors and extend/modify it a bit
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
function! MyHighlights() abort
  highlight StatusLine                   ctermfg=NONE ctermbg=NONE cterm=inverse

  if &background == "light"
    highlight LineNr                     ctermfg=15
    highlight CursorLineNr               ctermfg=7
    highlight Whitespace                 ctermfg=15
    highlight NonText                    ctermfg=15
    highlight ColorColumn                ctermfg=8    ctermbg=15
    highlight Folded                     ctermfg=8    ctermbg=NONE cterm=bold
    highlight StatusLineNC               ctermfg=7    ctermbg=NONE cterm=inverse
    highlight StatusLineWeak             ctermfg=NONE ctermbg=7    cterm=inverse
    highlight StatusLineWeakNC           ctermfg=7    ctermbg=15   cterm=inverse
  else
    highlight LineNr                     ctermfg=8
    highlight CursorLineNr               ctermfg=16
    highlight Whitespace                 ctermfg=8
    highlight NonText                    ctermfg=8
    highlight ColorColumn                ctermfg=7    ctermbg=16
    highlight Folded                     ctermfg=7    ctermbg=NONE cterm=bold
    highlight StatusLineNC               ctermfg=16   ctermbg=NONE cterm=inverse
    highlight StatusLineWeak             ctermfg=NONE ctermbg=8    cterm=inverse
    highlight StatusLineWeakNC           ctermfg=16   ctermbg=8    cterm=inverse
  endif
endfunction

augroup MyColors
  autocmd!
  autocmd ColorScheme dim ++nested call MyHighlights()
augroup END

" Set colorscheme only after all the `background` and custom highlighting
" business has been handled.
colorscheme dim

" {{{1 Miscellaneous setup

" Long lines continue left and right instead of wrapping
set nowrap

" Search wraps at top and bottom of file
set wrapscan

set whichwrap+=<,>,h,l,[,],~

set path+=**

"set lazyredraw " Disabled this on 2023-04-25 to try and see if some occasional
                " glitches would disapper

" Highlight the line the cursor is on
set cursorline

set wildmode=longest:full

" Don't show mode in command line
set noshowmode

""" Status line
" I chose to not use any plugins and try to do what I want by myself.

" Always put a status line on every window.
set laststatus=2

" Function to get the correct highlight
function MyStatuslineHighlightLookup(is_focused, type) abort
  let l:highlight = '%#'
  let l:highlight .= 'StatusLine'
  let l:highlight .= a:type == 'weak' ? 'Weak' : ''
  let l:highlight .= a:is_focused ? '' : 'NC'
  let l:highlight .= '#'
  return l:highlight
endfunction

" Creating the status line from a function gives flexibility, e.g. higlighting
" based on focus is easier/more functional.
function MyStatusline() abort
  if exists("g:statusline_winid") " Not present on older `vim`/`neovim` versions
    let l:is_focused = g:statusline_winid == win_getid(winnr())
  else
    let l:is_focused = v:true
  endif

  let l:statusline = '' " Initialize
  let l:statusline .= '%<' " Truncate from the beginning
  let l:statusline .= MyStatuslineHighlightLookup(l:is_focused, 'weak')
  let l:statusline .= '%{pathshorten(getcwd())}/%=' " Current working directory
  let l:statusline .= MyStatuslineHighlightLookup(l:is_focused, 'strong')
  let l:statusline .= '%f%=' " Current file
  let l:statusline .= ' [%{mode()}]%m%r%h%w%y ' " Mode, flags, and filetype
  let l:statusline .= '%l:%c%V %P' " Cursor position

  return statusline
endfunction

set statusline=%!MyStatusline()

" Bracket pairs matched by `%`
set matchpairs=(:),{:},[:],<:>

" This is always set in neovim, but doesn't hurt to set it here as well.
set nocompatible

" Clipboard
set clipboard+=unnamedplus

" Use CPCP for clipboard handling if available
let s:cpcp_command = ''
for cmd in [$HOME..'/.config/cross-platform-copy-paste/cpcp.sh', 'cpcp', 'cpcp.sh']
  if executable(cmd)
    let s:cpcp_command = cmd
    break
  end
endfor

" The commands in the dictionary below can be written as lists of individual
" arguments in newer versions of Neovim, but on some of the systems I use, the
" Neovim version is too old.
if !empty(s:cpcp_command)
  let s:cpcp_clipboard = {
  \   'name': 'CPCPClipboard',
  \   'copy': {
  \      '+': s:cpcp_command..' --base64=auto',
  \      '*': s:cpcp_command..' --base64=auto',
  \    },
  \   'paste': {
  \      '+': s:cpcp_command..' --base64=auto paste',
  \      '*': s:cpcp_command..' --base64=auto paste',
  \   },
  \   'cache_enabled': 1,
  \ }

  let g:clipboard = s:cpcp_clipboard
endif

" If I'm ever confused about how Neovim handles copying whole lines again: It's
" simple. No metadata or anything. Neovim just copies a line with its trailing
" newline and when pasting determines whether to paste as a new line or as text
" inside the current line depending on whether the pasted buffer ends on a
" newline. I assume it's the same for regular Vim, but don't know for sure at
" the time of writing this.

" Maximum height of the popup menu for insert mode completion
set pumheight=12
" TODO: Probably also set `pumwidth` as soon as I am on Neovim ≥0.5?

" Reduce key code delays
set ttimeoutlen=20

" Line Numbering
set number
set relativenumber
set numberwidth=1

" Switch to alternate file with backspace
nnoremap <bs> <c-^>

" Show 81st column
set colorcolumn=81

" I want this in most cases, therefore let's set it globally. Filetype scripts,
" modelines, etc. can be used to change it when needed.
" For reformatting, use `gq` or `gw`. `:help gq` and `:help gw` might help.
set textwidth=80

" Moving lines up and down – can of course be done with `dd` and `p` as well,
" but does not auto-indent that way, with my configuration.
nnoremap <c-j> :move .+1<cr>==
nnoremap <c-k> :move .-2<cr>==
inoremap <c-j> <esc>:move .+1<cr>==gi
inoremap <c-k> <esc>:move .-2<cr>==gi
vnoremap <c-j> :move '>+1<cr>gv=gv
vnoremap <c-k> :move '<-2<cr>gv=gv

" Moving lines left and right, i.e. indent or unindent
" Note: I like the behavior of this more than `<` and `>` in normal mode.
nnoremap <c-h> a<c-d><esc>
nnoremap <c-l> a<c-t><esc>
inoremap <c-h> <c-d>
inoremap <c-l> <c-t>
" Note: `gv` keeps the lines selected. However, it does not select the exact
" same content when done like this. I guess that's okay for now.
vnoremap <c-h> <lt>gv
" Note: I'm using `<char-62>` to target the key `>` because there is no `<gt>`.
vnoremap <c-l> <char-62>gv

" Folding

set foldmethod=syntax
set fillchars=vert:\|,fold:\ 
"set foldminlines=2

" Here's a function that opens all folds and then folds only the top level
" folds. I'd like to open my files in this way. Unfortunately, I have not found
" a way to make this work properly with autocmd.
"function FoldTopLevel()
"  :%foldo!
"  :%foldc
"endfunction

nnoremap <space> za

" Search, replace

set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap /<cr> :noh<cr>
nnoremap - :%s///g<left><left><left>
nnoremap _ :%s///g<left><left><left><c-r><c-w><right>

" Concealing

set conceallevel=0

" Tabbing, whitespace, indenting

set expandtab
set shiftwidth=2
set tabstop=2

" `listchars` handling (to visualize whitespaces and continuing lines)

set list

" Note: Since I use the `listchars` to show indent guides, I need to synchronize
" them with the `shftwidth`. I have to reset the full `listchars` option
" appropriately each time. That's why the below looks somewhat complicated.

" As a test, the following is a line with a tab, trailing whitespace and a nbsp.
" 	This was the tab, here is the nbsp:  And here is some whitespace:    

let g:constant_listchars = {
\ 'tab':   '▏·',
\ 'nbsp':  '·',
\ 'trail': '·',
\ 'precedes': '…',
\ 'extends': '…'}

" Backwards compatible way of accessing the shiftwidth, from `:help
" shiftwidth`/`builtin.txt`, slightly modified
if exists('*shiftwidth')
  function s:shiftwidth()
    return shiftwidth()
  endfunction
else
  function s:shiftwidth()
    if &shiftwidth == 0
      return &tabstop
    else
      return &shiftwidth
    endif
  endfunction
endif

" Adjusts the `leadmultispace` `listchars` to the `shiftwidth`
function UpdateListchars()
  let &listchars = ''
  for [name, str] in items(g:constant_listchars)
    let &listchars .= name . ':' . str . ','
  endfor
  let &listchars .= 'leadmultispace:▏' . repeat('\x20', shiftwidth() - 1)
endfunction

" Trigger `UpdateListchars` at the appropriate times
augroup MyOptionUpdaters " Not sure about this group name
  autocmd!
  autocmd OptionSet shiftwidth call UpdateListchars()
  " Not sure if the below is necessary
  autocmd BufWinEnter * call UpdateListchars()
augroup END


" Enable spell checking
"set spell spelllang=en_us

" for vim's native netrw browser
" let g:netrw_banner=0
let g:netrw_liststyle=3

" TeX flavor for vim's native ft-tex-plugin, also used by vimtex
let g:tex_flavor = 'latex'

" Don't conceal TeX code characters
let g:tex_conceal = ''
autocmd FileType plaintex,context,tex,bib set conceallevel=0

""" Mouse behavior and scrolling

set mouse=a
set mousemodel=popup_setpos " I might want to configure a menu for this.

" Don't scroll further horizontally than the cursor position (default anyway)
set sidescroll=1

" Remap arrow keys to do scrolling – has the added advantage of avoiding bad
" cursor movement habits.
noremap <up> <c-y>
noremap <down> <c-e>
noremap <left> z<left>
noremap <right> z<right>

" Weird looking scroll wheel mapping.
" Here's a corresponding GitHub issue:
" https://github.com/neovim/neovim/issues/6211
noremap <ScrollWheelUp> <c-y>
noremap <s-ScrollWheelUp> <c-y>
noremap <c-ScrollWheelUp> <c-y>
noremap <ScrollWheelDown> <c-e>
noremap <s-ScrollWheelDown> <c-e>
noremap <c-ScrollWheelDown> <c-e>
noremap <ScrollWheelLeft> z<left>
noremap <s-ScrollWheelLeft> z<left>
noremap <c-ScrollWheelLeft> z<left>
noremap <ScrollWheelRight> z<right>
noremap <s-ScrollWheelRight> z<left>
noremap <c-ScrollWheelRight> z<left>
noremap <2-ScrollWheelUp> <c-y>
noremap <s-2-ScrollWheelUp> <c-y>
noremap <c-2-ScrollWheelUp> <c-y>
noremap <2-ScrollWheelDown> <c-e>
noremap <s-2-ScrollWheelDown> <c-e>
noremap <c-2-ScrollWheelDown> <c-e>
noremap <2-ScrollWheelLeft> z<left>
noremap <s-2-ScrollWheelLeft> z<left>
noremap <c-2-ScrollWheelLeft> z<left>
noremap <2-ScrollWheelRight> z<left>
noremap <s-2-ScrollWheelRight> z<left>
noremap <c-2-ScrollWheelRight> z<left>
noremap <3-ScrollWheelUp> <c-y>
noremap <s-3-ScrollWheelUp> <c-y>
noremap <c-3-ScrollWheelUp> <c-y>
noremap <3-ScrollWheelDown> <c-e>
noremap <s-3-ScrollWheelDown> <c-e>
noremap <c-3-ScrollWheelDown> <c-e>
noremap <3-ScrollWheelLeft> z<left>
noremap <s-3-ScrollWheelLeft> z<left>
noremap <c-3-ScrollWheelLeft> z<left>
noremap <3-ScrollWheelRight> z<left>
noremap <s-3-ScrollWheelRight> z<left>
noremap <c-3-ScrollWheelRight> z<left>
noremap <4-ScrollWheelUp> <c-y>
noremap <s-4-ScrollWheelUp> <c-y>
noremap <c-4-ScrollWheelUp> <c-y>
noremap <4-ScrollWheelDown> <c-e>
noremap <s-4-ScrollWheelDown> <c-e>
noremap <c-4-ScrollWheelDown> <c-e>
noremap <4-ScrollWheelLeft> z<left>
noremap <s-4-ScrollWheelLeft> z<left>
noremap <c-4-ScrollWheelLeft> z<left>
noremap <4-ScrollWheelRight> z<left>
noremap <s-4-ScrollWheelRight> z<left>
noremap <c-4-ScrollWheelRight> z<left>
inoremap <ScrollWheelUp> <c-x><c-y>
inoremap <s-ScrollWheelUp> <c-x><c-y>
inoremap <c-ScrollWheelUp> <c-x><c-y>
inoremap <ScrollWheelDown> <c-x><c-e>
inoremap <s-ScrollWheelDown> <c-x><c-e>
inoremap <c-ScrollWheelDown> <c-x><c-e>
inoremap <ScrollWheelLeft> <c-o>z<left>
inoremap <s-ScrollWheelLeft> <c-o>z<left>
inoremap <c-ScrollWheelLeft> <c-o>z<left>
inoremap <ScrollWheelRight> <c-o>z<right>
inoremap <s-ScrollWheelRight> <c-o>z<right>
inoremap <c-ScrollWheelRight> <c-o>z<right>
inoremap <2-ScrollWheelUp> <c-x><c-y>
inoremap <s-2-ScrollWheelUp> <c-x><c-y>
inoremap <c-2-ScrollWheelUp> <c-x><c-y>
inoremap <2-ScrollWheelDown> <c-x><c-e>
inoremap <s-2-ScrollWheelDown> <c-x><c-e>
inoremap <c-2-ScrollWheelDown> <c-x><c-e>
inoremap <2-ScrollWheelLeft> <c-o>z<left>
inoremap <s-2-ScrollWheelLeft> <c-o>z<left>
inoremap <c-2-ScrollWheelLeft> <c-o>z<left>
inoremap <2-ScrollWheelRight> <c-o>z<right>
inoremap <s-2-ScrollWheelRight> <c-o>z<right>
inoremap <c-2-ScrollWheelRight> <c-o>z<right>
inoremap <3-ScrollWheelUp> <c-x><c-y>
inoremap <s-3-ScrollWheelUp> <c-x><c-y>
inoremap <c-3-ScrollWheelUp> <c-x><c-y>
inoremap <3-ScrollWheelDown> <c-x><c-e>
inoremap <s-3-ScrollWheelDown> <c-x><c-e>
inoremap <c-3-ScrollWheelDown> <c-x><c-e>
inoremap <3-ScrollWheelLeft> <c-o>z<left>
inoremap <s-3-ScrollWheelLeft> <c-o>z<left>
inoremap <c-3-ScrollWheelLeft> <c-o>z<left>
inoremap <3-ScrollWheelRight> <c-o>z<right>
inoremap <s-3-ScrollWheelRight> <c-o>z<right>
inoremap <c-3-ScrollWheelRight> <c-o>z<right>
inoremap <4-ScrollWheelUp> <c-x><c-y>
inoremap <s-4-ScrollWheelUp> <c-x><c-y>
inoremap <c-4-ScrollWheelUp> <c-x><c-y>
inoremap <4-ScrollWheelDown> <c-x><c-e>
inoremap <s-4-ScrollWheelDown> <c-x><c-e>
inoremap <c-4-ScrollWheelDown> <c-x><c-e>
inoremap <4-ScrollWheelLeft> <c-o>z<left>
inoremap <s-4-ScrollWheelLeft> <c-o>z<left>
inoremap <c-4-ScrollWheelLeft> <c-o>z<left>
inoremap <4-ScrollWheelRight> <c-o>z<right>
inoremap <s-4-ScrollWheelRight> <c-o>z<right>
inoremap <c-4-ScrollWheelRight> <c-o>z<right>

"map <ScrollWheelUp> <nop>
"map <s-ScrollWheelUp> <nop>
"map <c-ScrollWheelUp> <nop>
"map <ScrollWheelDown> <nop>
"map <s-ScrollWheelDown> <nop>
"map <c-ScrollWheelDown> <nop>
"map <ScrollWheelLeft> <nop>
"map <s-ScrollWheelLeft> <nop>
"map <c-ScrollWheelLeft> <nop>
"map <ScrollWheelRight> <nop>
"map <s-ScrollWheelRight> <nop>
"map <c-ScrollWheelRight> <nop>
"map <2-ScrollWheelUp> <nop>
"map <s-2-ScrollWheelUp> <nop>
"map <c-2-ScrollWheelUp> <nop>
"map <2-ScrollWheelDown> <nop>
"map <s-2-ScrollWheelDown> <nop>
"map <c-2-ScrollWheelDown> <nop>
"map <2-ScrollWheelLeft> <nop>
"map <s-2-ScrollWheelLeft> <nop>
"map <c-2-ScrollWheelLeft> <nop>
"map <2-ScrollWheelRight> <nop>
"map <s-2-ScrollWheelRight> <nop>
"map <c-2-ScrollWheelRight> <nop>
"map <3-ScrollWheelUp> <nop>
"map <s-3-ScrollWheelUp> <nop>
"map <c-3-ScrollWheelUp> <nop>
"map <3-ScrollWheelDown> <nop>
"map <s-3-ScrollWheelDown> <nop>
"map <c-3-ScrollWheelDown> <nop>
"map <3-ScrollWheelLeft> <nop>
"map <s-3-ScrollWheelLeft> <nop>
"map <c-3-ScrollWheelLeft> <nop>
"map <3-ScrollWheelRight> <nop>
"map <s-3-ScrollWheelRight> <nop>
"map <c-3-ScrollWheelRight> <nop>
"map <4-ScrollWheelUp> <nop>
"map <s-4-ScrollWheelUp> <nop>
"map <c-4-ScrollWheelUp> <nop>
"map <4-ScrollWheelDown> <nop>
"map <s-4-ScrollWheelDown> <nop>
"map <c-4-ScrollWheelDown> <nop>
"map <4-ScrollWheelLeft> <nop>
"map <s-4-ScrollWheelLeft> <nop>
"map <c-4-ScrollWheelLeft> <nop>
"map <4-ScrollWheelRight> <nop>
"map <s-4-ScrollWheelRight> <nop>
"map <c-4-ScrollWheelRight> <nop>

" {{{1 Clang-format integration

" TODO: ALE supports `clang-format` as a fixer, so perhaps I should use that
" instead. This whole section is a little hacky and platform-dependent anyway.

let g:clang_format_on_save = 0 " Defined by myself

function Formatonsave()
  if g:clang_format_on_save == 1
    let l:formatdiff = 1
    if s:hostname == "lasse-mbp-0" || s:hostname == "lasse-mba-0"
      py3f /usr/local/opt/llvm/share/clang/clang-format.py
    elseif s:hostname == "lasse-lubuntu-0"
      py3f /usr/share/clang/clang-format-10/clang-format.py
    endif
  endif
endfunction

function FormatFile()
  let l:lines="all"
    if s:hostname == "lasse-mbp-0" || s:hostname == "lasse-mba-0"
      py3f /usr/local/opt/llvm/share/clang/clang-format.py
    elseif s:hostname == "lasse-lubuntu-0"
      py3f /usr/share/clang/clang-format-10/clang-format.py
    endif
endfunction

autocmd FileType c,cpp nnoremap <buffer> <c-f> :call FormatFile()<cr>
autocmd FileType c,cpp vnoremap <buffer> <c-f> :py3f /usr/local/opt/llvm/share/clang/clang-format.py<cr>
autocmd FileType c,cpp inoremap <buffer> <c-f> <c-o>:silent py3f /usr/local/opt/llvm/share/clang/clang-format.py<cr>

autocmd BufWritePre *.h,*.hpp,*.hxx,*.c,*.cpp,*.cxx,*.C,*.cc call Formatonsave()

" `g:clang_format_path` tells `clang-format.py` where the clang-format binary is
" located.
if s:hostname == "lasse-mbp-0"
  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'
elseif s:hostname == "lasse-mba-0"
  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'
endif

" {{{1 Configuration of plugins

" TODO: Only configure plugins when they are present/enabled?

" {{{2 YouCompleteMe configuration

" Disable YCM for any non-CXX-family files.
let g:ycm_filetype_whitelist = {'c': 1, 'cpp': 1}

if s:hostname == "lasse-mbp-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
elseif s:hostname == "lasse-mba-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
elseif s:hostname == "lasse-debian-0"
  let g:ycm_server_python_interpreter = '/usr/bin/python3'
elseif s:hostname == "lasse-alpine-env-0"
  let g:ycm_server_python_interpreter = '/usr/bin/python3'
endif
let g:ycm_error_symbol = 'E>'
let g:ycm_warning_symbol = 'W>'
let g:ycm_complete_in_comments = 1
let g:ycm_key_list_select_completion = ['<tab>']
let g:ycm_key_list_previous_completion = ['<s-tab>']
let g:ycm_key_list_stop_completion = ['<c-y>', '<c-e>', '<up>', '<down>']
noremap ? :YcmCompleter GoTo<cr> " I don't use `?` for backward search anyway.

" Note that the above tab key assignments seem to happen if YCM is loaded, even
" if it is disabled. That way, the popup menu as used by ALE also works with the
" tab key. That's nice, but it'd be better if it worked without YCM.

" {{{2 ALE configuration
" ALE runs all available linters by default. I would like to choose my linters
" by myself and enable them one by one here. Hence the following setting. This
" also mitigates interference with YouCompleteMe.
let g:ale_linters_explicit = 1

" ALE linters to enable, by language
" Note: Doing `:ALEInfo` shows supported and enabled linters for the buffer.
" Note: For the `julia` `languageserver` linter to work, make sure the following
" packages are installed: `LanguageServer`, `SymbolServer`, and `StaticLint`.
" For ALE to start the linter, the respective Julia file needs to belong to a
" Julia Project with a `Project.toml` file.
" Also see the Julia- and LanguageServer.jl-specific source files of ALE if
" things should change in the future.
let g:ale_linters = {
  \ 'fish': ['fish'],
  \ 'sh': ['shell'],
  \ 'cpp': [],
  \ 'python': ['flake8'],
  \ 'julia': []} " ['languageserver']}

let g:ale_sign_error = 'E>'
let g:ale_sign_warning = 'W>'

let g:ale_echo_msg_format = '%s [%linter%% code%]'

" Disable ALE completion. This is the default, but I set it here explicitly to
" emphasize that I'm using other means of completion.
let g:ale_completion_enabled = 0

" Set flake8 ignore list in this vim config
" Could use flake8's config files alternatively
call ale#Set('python_flake8_options',
  \ '--ignore=E111,E114,E121,E128,E201,E203,E221,E222,E226,E241,E251,E261,E262,E302,E303,E305,E501,E702,E731,W391,W504')

" {{{2 Deoplete configuration

" Note: Deoplete latches onto the `ale` source automatically.

let g:deoplete#enable_at_startup = 1

" Disable Deoplete for CXX-family `filetype`s to let YCM take over
autocmd FileType c,cpp
  \ call deoplete#custom#buffer_option('auto_complete', v:false)

" {{{2 NERDCommenter configuration

let g:NERDCommentWholeLinesInVMode = 1
let g:NERDCommentEmptyLines = 1
let g:NERDCreateDefaultMappings = 0

" Note: `<gt>` does not exist, instead `<char-62>` can be used
map <lt> <plug>NERDCommenterUncomment
map <char-62> <plug>NERDCommenterAlignBoth

" {{{2 vim-ranger configuration

let g:ranger_map_keys = 0
let g:ranger_replace_netrw = 1

" If the current buffer is modified, open vim-ranger in a new window, unless
" `hidden` is set.
" vim-ranger will throw the error "E37: No write since last change" if the same
" file as the currently open modified buffer is opened. I was not able to catch
" or silence the error. I think this is because vim-ranger runs asynchronously
" and the code of the below function just continues without waiting for the user
" to quit ranger.
function RangerSmart()
  if !&hidden && getbufinfo("%")[0].changed
    split +Ranger
  else
    Ranger
  end
endfunction

command RangerSmart call RangerSmart()

nmap <c-p> :RangerSmart<cr>

" {{{2 vim-asciidoc-folding configuration

autocmd FileType asciidoc setlocal foldmethod=expr

" {{{2 wolfram-vim configuration

autocmd BufNewFile,BufRead *.wl set syntax=wl
autocmd BufNewFile,BufRead *.wls set syntax=wl
autocmd BufNewFile,BufRead *.m set syntax=wl
autocmd BufNewFile,BufRead *.nb set syntax=wl

" {{{2 vim-fish configuration

" Set up :make to use fish for syntax checking.
autocmd FileType fish compiler fish
" Set this to have long lines wrap inside comments.
autocmd FileType fish setlocal textwidth=80
" Enable folding of block structures in fish.
autocmd FileType fish setlocal foldmethod=expr

" {{{2 vimtex configuration

" Don't try to use bibtex
let g:vimtex_parser_bib_backend = 'vim'

" Don't run document viewer automatically
let g:vimtex_view_enabled = 0

" Set up latexmk compiler
let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_compiler_latexmk = {
  \ 'build_dir' : '',
  \ 'callback' : 0,
  \ 'continuous' : 0,
  \ 'executable' : 'latexmk',
  \ 'hooks' : [],
  \ 'options' : [
  \   '-verbose',
  \   '-file-line-error',
  \   '-synctex=1',
  \   '-interaction=nonstopmode',
  \ ],
  \}

" Automatically compile on write
" Continuous compilation may be possible with a daemon container…
"autocmd BufWritePost *.tex execute "VimtexCompileSS"

let g:vimtex_fold_enabled = 1
let g:vimtex_format_enabled = 1

" Don't use conceal features
let g:vimtex_syntax_conceal_default = 0

" {{{2 julia-vim configuration

" Don't have the filetype plugin set the shiftwidth to 4
let g:julia_set_indentation = 0

" Don't highlight operators
let g:julia_highlight_operators = 0
