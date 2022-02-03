" init.vim or '.vimrc' file thrown together by me (lasse)

""" Things that need to be done early

" Get hostname to allow for platform-dependent customization
let s:hostname = substitute(system('hostname'), '\n', '', '')

" Remove all autocommands
:autocmd!

""" Neovim providers

" Python needs the neovim package installed.
" Set the location of the python binary.
" 'provider.txt' says setting this makes startup faster
if s:hostname == "lasse-mbp-0"
  let g:python3_host_prog = '/usr/local/bin/python3'
elseif s:hostname == "lasse-mba-0"
  let g:python3_host_prog = '/usr/local/bin/python3'
elseif s:hostname == "lasse-alpine-env-0"
  let g:python3_host_prog = '/usr/bin/python3'
endif
" Not sure if this is sensible, but i guess it doesn't hurt
let g:loaded_python_provider = 1
"let g:loaded_python3_provider = 1
let g:loaded_ruby_provider = 1
let g:loaded_node_provider = 1
let g:loaded_perl_provider = 1

""" vim-plug

" vim-plug needs to be installed beforehand, I have not automated that here.
" I chose the directory name 'plugged' as suggested by the vim-plug readme.

call plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdcommenter'

Plug 'ctrlpvim/ctrlp.vim'

Plug 'ojroques/vim-oscyank'

"" YCM needs a working Python environment and Cmake to install itself
"" Consequently, I enable YCM only on some hosts
if s:hostname == "lasse-mbp-0" || s:hostname == "lasse-mba-0" || s:hostname == "lasse-lubuntu-0"
  Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clang-completer' }
end

"" On alpine, use system libclang
if s:hostname == "lasse-alpine-env-0"
  Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clang-completer --system-libclang' }
end

Plug 'dag/vim-fish'

Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim' " Dependency of ranger.vim

Plug 'thaerkh/vim-indentguides'

" At some point I should probably consider that surround plugin everyone uses 😄

Plug 'junegunn/goyo.vim'

Plug 'matcatc/vim-asciidoc-folding' " I'll need this as long as the official
" Asciidoc syntax support does not support folding

Plug 'https://github.com/arnoudbuzing/wolfram-vim.git' " This is only a syntax
" file, not a 'real' plugin

Plug 'guns/xterm-color-table.vim'

Plug 'lervag/vimtex'

Plug 'JuliaEditorSupport/julia-vim'

Plug 'kdheepak/JuliaFormatter.vim'

call plug#end()

""" Miscellaneous things

set whichwrap+=<,>,h,l,[,],~
set path+=**
"set so=7
"set cmdheight=2
set lazyredraw
set laststatus=2
set statusline=%{getcwd()}%=%f%m%r%h%w%=%l,%c%V\ %P
set cursorline
set shell=fish\ --interactive\ --login
set wildmode=longest:full
set matchpairs=(:),{:},[:],<:>
set nocompatible " is always set in neovim, but doesn't hurt

" Reduce key code delays
set ttimeoutlen=20

" Line Numbering
set number
set relativenumber
set numberwidth=1

nmap <bs> <c-^>

" Show 81st column
set colorcolumn=81
" I don't set an explicit highlight color, since the default light and dark
" solarized colors work nicely

set textwidth=80
" I'll try to use this as a global setting, maybe that's a stupid idea.
" I can still add filetype-dependent overrides though.
" For reformatting, use gq or gw. :help gq and :help gw might help 😉

" Moving lines up and down
nnoremap <c-j> :m .+1<cr>==
nnoremap <c-k> :m .-2<cr>==
inoremap <c-j> <esc>:m .+1<cr>==gi
inoremap <c-k> <esc>:m .-2<cr>==gi
vnoremap <c-j> :m '>+1<cr>gv=gv
vnoremap <c-k> :m '<-2<cr>gv=gv

" Enable spell checking
"set spell spelllang=en_us

" for vim's native netrw browser
" let g:netrw_banner=0
let g:netrw_liststyle=3

set clipboard+=unnamedplus

" TeX flavor for vim's native ft-tex-plugin, also used by vimtex
let g:tex_flavor = 'latex'

" Don't conceal TeX code characters
let g:tex_conceal = ''
autocmd FileType plaintex,context,tex,bib set conceallevel=0

" I can't think of a case where trailing whitespace is needed in .tex files…
" But this thing doesn't work as well as I'd like it to. Maybe I can work on it
" another time if it feels important.
"autocmd BufWritePre *.tex %s/\s\+$//e
"autocmd BufWritePre *.tex execute "normal \<c-o>"

""" Mouse Behavior

set mouse=a
set mousemodel=popup_setpos " i might want to configure a menu for this

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

" Remap arrow keys to do scrolling
" This has the added advantage of avoiding bad cursor movement habits 😉
map <up> <c-y>
map <down> <c-e>
map <left> <nop>
map <right> <nop>

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

""" Concealing
set conceallevel=0

""" Search, replace

set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap /<cr> :noh<cr>
nnoremap - :%s///g<left><left><left>
nnoremap _ :%s///g<left><left><left><c-r><c-w><right>

""" Tabbing, whitespace, indenting

set expandtab
set shiftwidth=2
set tabstop=2

" Show whitespace characters
" The following is a line with a tab, trailing whitespace and a nbsp.
" 	This was the tab, here is the nbsp:  And here is some whitespace:    
" Seems like the `+-` for tabs gets overridden by `vim-indentguides`…
set listchars=tab:+-,nbsp:·,trail:·
set list

""" Colors

" Use solarized color scheme 🙂
"let g:solarized_visibility = "low"
function! SolarizedOverrides()
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

function! ToggleBackground()
  " Solarized comes with a ToggleBackground plugin, but I figured I might as
  " well just write a function. Don't know if the plugin does more than just
  " toggling the background like this function, though.
  if &background == "light"
    set background=dark
  else
    set background=light
  endif
endfunction

nnoremap + :call ToggleBackground()<esc>

""" Clang-format integration

" Defined by myself (lasse)
let g:clang_format_on_save = 0

function! Formatonsave()
  if g:clang_format_on_save == 1
    let l:formatdiff = 1
    if s:hostname == "lasse-mbp-0" || s:hostname == "lasse-mba-0"
      py3f /usr/local/opt/llvm/share/clang/clang-format.py
    elseif s:hostname == "lasse-lubuntu-0"
      py3f /usr/share/clang/clang-format-10/clang-format.py
    endif
  endif
endfunction

function! FormatFile()
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

" g:clang_format_path tells clang-format.py where the clang-format binary is
" located
if s:hostname == "lasse-mbp-0"
  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'
  let g:clang_format_on_save = 0
elseif s:hostname == "lasse-mba-0"
  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'
  let g:clang_format_on_save = 0
endif

""" Configuration of plugins

"""" YouCompleteMe configuration

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
"let g:ycm_key_list_stop_completion = ['<c-y>', '<esc>', '<up>', '<down>']
let g:ycm_key_list_stop_completion = ['<c-y>', '<up>', '<down>']
noremap <c-g> :YcmCompleter GoTo<cr>

"""" NERDCommenter configuration

map <c-h> <leader>cu
nmap <c-h> <leader>cu:set whichwrap-=h<cr>2h:set whichwrap+=h<cr>
imap <c-h> <c-o><leader>cu<c-o>:set whichwrap-=[<cr><left><left><c-o>:set whichwrap+=[<cr>
map <c-l> <leader>cl
nmap <c-l> <leader>cl2l
imap <c-l> <c-o><leader>cl<right><right>
let NERDCommentWholeLinesInVMode=1

"""" vim-ranger configuration

let g:ranger_map_keys = 1
let g:ranger_replace_netrw = 1

"""" vim-indentguides configuration

let g:indentguides_spacechar = "▏"
let g:indentguides_tabchar = "▏"

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

"""" oscyank configuration

" Automatically copy the unnamed register to clipboard through ANSI OSC52 on
" every yank operation (not sure if this copies twice if another clipboard
" provider is present, but since OSC52 also isn't guaranteed to work everywhere,
" I guess better risk doing it twice than not doing it at all).
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif

" Automatically compile on write
" Continuous compilation may be possible with a daemon container…
"autocmd BufWritePost *.tex execute "VimtexCompileSS"

let g:vimtex_fold_enabled = 1
let g:vimtex_format_enabled = 1

" Don't use conceal features
let g:vimtex_syntax_conceal_default = 0

""" JuliaFormatter configuration

" At the moment, JuliaFormatter requires 'filetype off', which I don't like. So
" this plugin isn't really useful I guess…

"filetype off
"nnoremap <c-f> :JuliaFormatterFormat<cr>
"vnoremap <c-f> :'<,'>JuliaFormatterFormat<cr>

let g:JuliaFormatter_options = {
        \ 'indent'                    : 2,
        \ 'margin'                    : 80,
        \ 'always_for_in'             : v:true,
        \ 'whitespace_typedefs'       : v:true,
        \ }

autocmd FileType julia nnoremap <buffer> <c-f> :JuliaFormatterFormat<cr>
autocmd FileType julia vnoremap <buffer> <c-f> :'<,'>JuliaFormatterFormat<cr>

