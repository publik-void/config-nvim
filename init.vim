" `init.vim` or '`.vimrc`' file thrown together by me.

" TODO: Think about porting this to Lua? Or should I try to remain somewhat
" close to regular Vim?
" TODO: Work through this article: https://aca.github.io/neovim_startuptime.html
" TODO: This looks interesting as well: https://github.com/nathom/filetype.nvim
" TODO: Have individual files for specific file types? E.g. set conceallevel and
" shiftwidth for `filetype`s such as JSON, Python, TeX, … This may come in
" handy: https://vi.stackexchange.com/questions/14371/why-files-in-config-nvim-after-ftplugin-are-not-taken-into-acount

""" Things that need to be done early

" I would love to set this to `fish`, but POSIX compliance is needed for some
" things to work correctly.
set shell=sh

" Get hostname to allow for platform-dependent customization
let s:hostname = substitute(system('hostname'), '\n', '', '')

" Remove all autocommands
:autocmd!

""" Neovim providers

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

""" vim-plug

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
if s:hostname == "lasse-mbp-0" || s:hostname == "lasse-mba-0" || s:hostname == "lasse-lubuntu-0"
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

Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim' " Dependency of `ranger.vim`

Plug 'thaerkh/vim-indentguides'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat' " Makes `.` work for `vim-surround`.

Plug 'junegunn/goyo.vim'

Plug 'matcatc/vim-asciidoc-folding' " I'll need this as long as the official
" Asciidoc syntax support does not support folding

Plug 'https://github.com/arnoudbuzing/wolfram-vim.git' " This is only a syntax
" file, not a 'real' plugin

Plug 'guns/xterm-color-table.vim'

Plug 'lervag/vimtex'

Plug 'JuliaEditorSupport/julia-vim'

call plug#end()

""" Colors

" Note: Doing this early is sensible because colorschemes like this one tend to
" clear all custom `highlight`s.
" TODO: Think about re-doing this in a better way, perhaps leveraging Neovim's
" new Treesitter functionality, and generally less hackiness and better support
" for terminal colors as well as true color?

" Use solarized color scheme 🙂

"let g:solarized_visibility = "low"

function SolarizedOverrides()
  if &background == "light"
    hi! MatchParen ctermbg=7
    hi! WhiteSpace ctermbg=7

    " For vim-indentguides
    let g:indentguides_conceal_color = 'ctermfg=7 ctermbg=NONE'
    let g:indentguides_specialkey_color = 'ctermfg=7 ctermbg=NONE'
  else
    hi! MatchParen ctermbg=0
    hi! WhiteSpace ctermbg=0

    " For vim-indentguides
    let g:indentguides_conceal_color = 'ctermfg=0 ctermbg=NONE'
    let g:indentguides_specialkey_color = 'ctermfg=0 ctermbg=NONE'

  endif
endfunction

autocmd colorscheme solarized call SolarizedOverrides()

colorscheme solarized
set background=light

" Solarized comes with a ToggleBackground plugin, but I figured I might as well
" just write a function. Don't know if the plugin does more than just toggling
" the background like this function, though.
" Note: This function unfortunetaly clears custom `highlight`s.
function ToggleBackground()
  if &background == "light"
    set background=dark
  else
    set background=light
  endif
endfunction

nnoremap + :call ToggleBackground()<esc>

""" Miscellaneous things

set whichwrap+=<,>,h,l,[,],~
set path+=**
"set lazyredraw " Disabled this on 2023-04-25 to try and see if some occasional
                " glitches would disapper
set cursorline
set wildmode=longest:full
set noshowmode

""" Status line
" I chose to not use any plugins and try to do what I want by myself.

" Always put a status line on every window.
set laststatus=2

" Custom `highlight`s for status line coloring. The `NC` versions are for
" out-of-focus windows.
highlight! MyStatuslineStrong ctermfg=15 ctermbg=10
highlight! MyStatuslineStrongNC ctermfg=15 ctermbg=11
highlight! MyStatuslineWeak ctermfg=14 ctermbg=10
highlight! MyStatuslineWeakNC ctermfg=14 ctermbg=11

" Function to get the correct highlight – in principle extensible to match other
" color schemes and so on…
function MyStatuslineHighlightLookup(is_focused, type) abort
  let l:my_statusline_highlight_lookup = {
    \ 'strong': 'MyStatusLineStrong',
    \ 'weak': 'MyStatusLineWeak'}
  let l:default = 'StatusLine'
  let l:highlight = get(l:my_statusline_highlight_lookup, a:type, l:default)
  let l:highlight .= a:is_focused ? '' : 'NC'
  return '%#' . l:highlight . '#'
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

" TODO: I'll have to separate the cross-platform clipboard out from tmux.
"" Use tmux clipboard if available. This has the advantage of letting tmux handle
"" the specifics of copying and pasting, which I have configured for it anyway.
"" Note: In `:help clipboard-tool`, it says that Neovim looks for tmux, but only
"" after it did not find a bunch of other clipboard options. I don't know how to
"" change the priorities of the clipboard tool list's entries or how to re-use
"" the tmux integration. Luckily, they give an example for how to write the tmux
"" integration manually.
"let s:tmux_clipboard = {
"\   'name': 'ManualTmuxClipboard',
"\   'copy': {
"\      '+': 'tmux load-buffer -',
"\      '*': 'tmux load-buffer -',
"\    },
"\   'paste': {
"\      '+': 'tmux save-buffer -',
"\      '*': 'tmux save-buffer -',
"\   },
"\   'cache_enabled': 1,
"\ }
"
"if !empty($TMUX)
"  let g:clipboard = s:tmux_clipboard
"end

" Maximum height of the popup menu for insert mode completion
set pumheight=12
" TODO: Probably also set `pumwidth` as soon as I am on Neovim ≥0.5?

" Reduce key code delays
set ttimeoutlen=20

" Line Numbering
set number
set relativenumber
set numberwidth=1

nmap <bs> <c-^>

" Show 81st column
" I don't set an explicit highlight color, since the default light and dark
" solarized colors work nicely.
set colorcolumn=81

" I'll try to use this as a global setting, maybe that's a stupid idea.
" I can still add filetype-dependent overrides though.
" For reformatting, use gq or gw. :help gq and :help gw might help.
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
nnoremap <c-h> a<c-d><esc>
nnoremap <c-l> a<c-t><esc>
inoremap <c-h> <c-d>
inoremap <c-l> <c-t>
" Note: `gv` keeps the lines selected. However, it does not select the exact
" same content when done like this. I guess that's okay for now.
vnoremap <c-h> <lt>gv
" Note: I'm using `<char-62>` to target the key `>` because there is no `<gt>`.
vnoremap <c-l> <char-62>gv

""" Folding

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

""" Search, replace

set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap /<cr> :noh<cr>
nnoremap - :%s///g<left><left><left>
nnoremap _ :%s///g<left><left><left><c-r><c-w><right>

""" Concealing

set conceallevel=0

""" Tabbing, whitespace, indenting

set expandtab
set shiftwidth=2
set tabstop=2

" Show whitespace characters
" The following is a line with a tab, trailing whitespace and a nbsp.
" 	This was the tab, here is the nbsp:  And here is some whitespace:    
set listchars=tab:+-,nbsp:·,trail:·
set list

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

" Remap arrow keys to do scrolling – has the added advantage of avoiding bad
" cursor movement habits.
map <up> <c-y>
map <down> <c-e>
map <left> <nop>
map <right> <nop>

" Weird looking scroll wheel mapping.
" Here's a corresponding GitHub issue:
" https://github.com/neovim/neovim/issues/6211
map <ScrollWheelUp> <c-y>
map <s-ScrollWheelUp> <c-y>
map <c-ScrollWheelUp> <c-y>
map <ScrollWheelDown> <c-e>
map <s-ScrollWheelDown> <c-e>
map <c-ScrollWheelDown> <c-e>
map <ScrollWheelLeft> <nop>
map <s-ScrollWheelLeft> <nop>
map <c-ScrollWheelLeft> <nop>
map <ScrollWheelRight> <nop>
map <s-ScrollWheelRight> <nop>
map <c-ScrollWheelRight> <nop>
map <2-ScrollWheelUp> <c-y>
map <s-2-ScrollWheelUp> <c-y>
map <c-2-ScrollWheelUp> <c-y>
map <2-ScrollWheelDown> <c-e>
map <s-2-ScrollWheelDown> <c-e>
map <c-2-ScrollWheelDown> <c-e>
map <2-ScrollWheelLeft> <nop>
map <s-2-ScrollWheelLeft> <nop>
map <c-2-ScrollWheelLeft> <nop>
map <2-ScrollWheelRight> <nop>
map <s-2-ScrollWheelRight> <nop>
map <c-2-ScrollWheelRight> <nop>
map <3-ScrollWheelUp> <c-y>
map <s-3-ScrollWheelUp> <c-y>
map <c-3-ScrollWheelUp> <c-y>
map <3-ScrollWheelDown> <c-e>
map <s-3-ScrollWheelDown> <c-e>
map <c-3-ScrollWheelDown> <c-e>
map <3-ScrollWheelLeft> <nop>
map <s-3-ScrollWheelLeft> <nop>
map <c-3-ScrollWheelLeft> <nop>
map <3-ScrollWheelRight> <nop>
map <s-3-ScrollWheelRight> <nop>
map <c-3-ScrollWheelRight> <nop>
map <4-ScrollWheelUp> <c-y>
map <s-4-ScrollWheelUp> <c-y>
map <c-4-ScrollWheelUp> <c-y>
map <4-ScrollWheelDown> <c-e>
map <s-4-ScrollWheelDown> <c-e>
map <c-4-ScrollWheelDown> <c-e>
map <4-ScrollWheelLeft> <nop>
map <s-4-ScrollWheelLeft> <nop>
map <c-4-ScrollWheelLeft> <nop>
map <4-ScrollWheelRight> <nop>
map <s-4-ScrollWheelRight> <nop>
map <c-4-ScrollWheelRight> <nop>
imap <ScrollWheelUp> <c-x><c-y>
imap <s-ScrollWheelUp> <c-x><c-y>
imap <c-ScrollWheelUp> <c-x><c-y>
imap <ScrollWheelDown> <c-x><c-e>
imap <s-ScrollWheelDown> <c-x><c-e>
imap <c-ScrollWheelDown> <c-x><c-e>
imap <ScrollWheelLeft> <nop>
imap <s-ScrollWheelLeft> <nop>
imap <c-ScrollWheelLeft> <nop>
imap <ScrollWheelRight> <nop>
imap <s-ScrollWheelRight> <nop>
imap <c-ScrollWheelRight> <nop>
imap <2-ScrollWheelUp> <c-x><c-y>
imap <s-2-ScrollWheelUp> <c-x><c-y>
imap <c-2-ScrollWheelUp> <c-x><c-y>
imap <2-ScrollWheelDown> <c-x><c-e>
imap <s-2-ScrollWheelDown> <c-x><c-e>
imap <c-2-ScrollWheelDown> <c-x><c-e>
imap <2-ScrollWheelLeft> <nop>
imap <s-2-ScrollWheelLeft> <nop>
imap <c-2-ScrollWheelLeft> <nop>
imap <2-ScrollWheelRight> <nop>
imap <s-2-ScrollWheelRight> <nop>
imap <c-2-ScrollWheelRight> <nop>
imap <3-ScrollWheelUp> <c-x><c-y>
imap <s-3-ScrollWheelUp> <c-x><c-y>
imap <c-3-ScrollWheelUp> <c-x><c-y>
imap <3-ScrollWheelDown> <c-x><c-e>
imap <s-3-ScrollWheelDown> <c-x><c-e>
imap <c-3-ScrollWheelDown> <c-x><c-e>
imap <3-ScrollWheelLeft> <nop>
imap <s-3-ScrollWheelLeft> <nop>
imap <c-3-ScrollWheelLeft> <nop>
imap <3-ScrollWheelRight> <nop>
imap <s-3-ScrollWheelRight> <nop>
imap <c-3-ScrollWheelRight> <nop>
imap <4-ScrollWheelUp> <c-x><c-y>
imap <s-4-ScrollWheelUp> <c-x><c-y>
imap <c-4-ScrollWheelUp> <c-x><c-y>
imap <4-ScrollWheelDown> <c-x><c-e>
imap <s-4-ScrollWheelDown> <c-x><c-e>
imap <c-4-ScrollWheelDown> <c-x><c-e>
imap <4-ScrollWheelLeft> <nop>
imap <s-4-ScrollWheelLeft> <nop>
imap <c-4-ScrollWheelLeft> <nop>
imap <4-ScrollWheelRight> <nop>
imap <s-4-ScrollWheelRight> <nop>
imap <c-4-ScrollWheelRight> <nop>

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

""" Clang-format integration

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

""" Configuration of plugins

" TODO: Only configure plugins when they are present/enabled?

"""" YouCompleteMe configuration

" Disable YCM for any non-CXX-family files.
let g:ycm_filetype_whitelist = {'c': 1, 'cpp': 1}

if s:hostname == "lasse-mbp-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
elseif s:hostname == "lasse-mba-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
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

"""" ALE configuration
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
  \ '--ignore=E111,E114,E121,E128,E201,E221,E222,E226,E241,E251,E261,E262,E302,E303,E305,E501,W391,W504')

"""" Deoplete configuration

" Note: Deoplete latches onto the `ale` source automatically.

let g:deoplete#enable_at_startup = 1

" Disable Deoplete for CXX-family `filetype`s to let YCM take over
autocmd FileType c,cpp
  \ call deoplete#custom#buffer_option('auto_complete', v:false)

"""" NERDCommenter configuration

let g:NERDCommentWholeLinesInVMode = 1
let g:NERDCommentEmptyLines = 1
let g:NERDCreateDefaultMappings = 0

" Note: I'm mapping the arrow keys directly here. Above, they were mapped to
" `<nop>` anyway.
map <left> <plug>NERDCommenterUncomment
map <right> <plug>NERDCommenterAlignBoth

"""" vim-ranger configuration

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

"""" vim-indentguides configuration

let g:indentguides_spacechar = "▏"
let g:indentguides_tabchar = "" " Disable for tabs to show listchars instead

"""" vim-asciidoc-folding configuration

autocmd FileType asciidoc setlocal foldmethod=expr

"""" wolfram-vim configuration

autocmd BufNewFile,BufRead *.wl set syntax=wl
autocmd BufNewFile,BufRead *.wls set syntax=wl
autocmd BufNewFile,BufRead *.m set syntax=wl
autocmd BufNewFile,BufRead *.nb set syntax=wl

"""" vim-fish configuration

" Set up :make to use fish for syntax checking.
autocmd FileType fish compiler fish
" Set this to have long lines wrap inside comments.
autocmd FileType fish setlocal textwidth=80
" Enable folding of block structures in fish.
autocmd FileType fish setlocal foldmethod=expr

"""" vimtex configuration

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

