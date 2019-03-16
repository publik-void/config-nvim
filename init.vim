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
  let g:python_host_prog = '/usr/local/bin/python2'
elseif s:hostname == "lasse-mba-0"
  let g:python_host_prog = '/usr/local/bin/python2'
elseif s:hostname == "lasse-bsd-1"
  let g:python_host_prog = '/usr/local/bin/python2.7'
elseif s:hostname == "lasse-ubuntu-0"
  let g:python_host_prog = '/usr/bin/python2.7'
endif
" Not sure if this is sensible, but i guess it doesn't hurt
let g:loaded_python3_provider = 1
let g:loaded_ruby_provider = 1
let g:loaded_node_provider = 1

""" vim-plug

" vim-plug needs to be installed beforehand, I have not automated that here.
" I chose the directory name 'plugged' as suggested by the vim-plug readme.

call plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdcommenter'

Plug 'ctrlpvim/ctrlp.vim'

" YCM needs a working Python environment and Cmake to install itself
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }

Plug 'dag/vim-fish'

Plug 'bfredl/nvim-miniyank' " I'll need miniyank until block pasting on macOS
" with clipboard=unnamed is fixed in Neovim

Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim' " Dependency of ranger.vim

Plug 'thaerkh/vim-indentguides'

" At some point I should probably consider that surround plugin everyone uses 😄

Plug 'junegunn/goyo.vim'

Plug 'matcatc/vim-asciidoc-folding' " I'll need this as long as the official
" Asciidoc syntax support does not support folding

Plug 'https://github.com/arnoudbuzing/wolfram-vim.git' " This is only a syntax
" file, not a 'real' plugin

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
" I should look into using the OSC 52 escape sequence to allow local clipboard
" access over ssh. However, I have a hard time getting this to work properly.
" right now, any vim plugins or functions are not quite working for me and the
" release version of mosh does not even support that escape sequence (yet!).
" Also, tmux needs a workaround for compatibility to mosh. And at the time of
" writing, I still depend on the plugin bfredl/nvim-miniyank to be able to do
" proper block pasting in neovim.
" So all in all, it might be worth waiting a bit until some of that software has
" matured a bit more.

""" Mouse Behavior

set mouse=a
set mousemodel=popup_setpos " i might want to configure a menu for this

" This disables the mouse/touchpad scrolling. Since I'm mostly working with
" Apple touchpads and terminal emulators which support sending arrow keys in
" response to mouse wheel events in alternate screen mode, the smoothness of
" scrolling can be greatly improved by remapping the arrow keys to do the
" scrolling. Unfortunately, as of 2019-02, Neovim has a bug which leaves
" scrolling enabled even when all scroll wheel actions are remapped to <nop>.
" Here's a corresponding GitHub issue:
" https://github.com/neovim/neovim/issues/6211
map <ScrollWheelup> <nop>
map <s-ScrollWheelup> <nop>
map <c-ScrollWheelup> <nop>
map <ScrollWheeldown> <nop>
map <s-ScrollWheeldown> <nop>
map <c-ScrollWheeldown> <nop>
map <ScrollWheelleft> <nop>
map <s-ScrollWheelleft> <nop>
map <c-ScrollWheelleft> <nop>
map <ScrollWheelright> <nop>
map <s-ScrollWheelright> <nop>
map <c-ScrollWheelright> <nop>

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

""" Search, replace

set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap /<cr> :noh<cr>
nnoremap - :%s///g<left><left><left>
nnoremap _ :%s///g<left><left><left><c-r><c-w>

""" Tabbing, whitespace, indenting

set expandtab
set shiftwidth=2
set tabstop=2

" Show whitespace characters
" The following is a line with a tab, trailing whitespace and a nbsp.
" OK… Here is the nbsp:  And here is some whitespace:    
" Well, the tab is missing for now due to auto-indentation. Gotta fix that at
" some point…
set listchars=tab:+-,nbsp:·,trail:·
set list

""" Colors

" Use solarized color scheme 🙂
"let g:solarized_visibility = "low"
function! SolarizedOverrides()
  if &background == "light"
    hi! MatchParen ctermbg=7
    hi! WhiteSpace ctermbg=7
  else
    hi! MatchParen ctermbg=0
    hi! WhiteSpace ctermbg=0
  endif
endfunction

autocmd colorscheme solarized call SolarizedOverrides()

colorscheme solarized
set background=dark

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
    pyf /usr/local/opt/llvm/share/clang/clang-format.py
  endif
endfunction

function! FormatFile()
  let l:lines="all"
  pyf /usr/local/opt/llvm/share/clang/clang-format.py
endfunction

nnoremap <c-f> :call FormatFile()<cr>
vnoremap <c-f> :pyf /usr/local/opt/llvm/share/clang/clang-format.py<cr>
inoremap <c-f> <c-o>:silent pyf /usr/local/opt/llvm/share/clang/clang-format.py<cr>

autocmd BufWritePre *.h,*.hpp,*.hxx,*.c,*.cpp,*.cxx,*.C,*.cc call Formatonsave()

" g:clang_format_path tells clang-format.py where the clang-format binary is
" located
if s:hostname == "lasse-mbp-0"
  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'
  let g:clang_format_on_save = 1
elseif s:hostname == "lasse-mba-0"
  " …
elseif s:hostname == "lasse-bsd-0"
  " …
elseif s:hostname == "lasse-bsd-1"
  " …
endif

""" Configuration of plugins

"""" YouCompleteMe configuration

if s:hostname == "lasse-mbp-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python2'
elseif s:hostname == "lasse-mba-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python2'
elseif s:hostname == "lasse-bsd-1"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python2.7'
elseif s:hostname == "lasse-ubuntu-0"
  let g:ycm_server_python_interpreter = '/usr/bin/python2.7'
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

" I might want to adjust this color to something a little more subtle
" I might also want to find a second color for the bright solarized scheme
let g:indentguides_conceal_color = 'ctermfg=10 ctermbg=NONE guifg=Grey27 guibg=NONE'
let g:indentguides_specialkey_color = 'ctermfg=10 ctermbg=NONE guifg=Grey27 guibg=NONE'
" This character is not ideal as it overlaps into the previous line
let g:indentguides_spacechar = "⎸"

"""" nvim-miniyank configuration

map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)

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

""" Things that need to be done late

" Enable section folding in this file

" vim:fdm=expr:fdl=0
" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='

