" init.vim or '.vimrc' file thrown together by me (incredigital)

" get hostname to allow for platform-dependent customization
let s:hostname = substitute(system('hostname'), '\n', '', '')

" --------
" Miscellaneous things
" --------

" All kinds of stuff
set whichwrap+=<,>,h,l,[,],~
set path+=**
"set so=7
"set cmdheight=2
set ignorecase
set smartcase
set incsearch
set lazyredraw
set laststatus=2
set statusline=%{getcwd()}%=%f%m%r%h%w%=%l,%c%V\ %P
set cursorline
set shell=fish\ --interactive\ --login
set wildmode=longest:full

" Clipboard
set clipboard+=unnamedplus
" I should look into using the OSC 52 escape sequence to allow local clipboard
" access over ssh. However, I have a hard time getting this to work properly.
" Right now, any vim plugins or functions are not quite working for me and the
" release version of mosh does not even support that escape sequence (yet!).
" Also, tmux needs a workaround for compatibility to mosh. And at the time of
" writing, I still depend on the plugin bfredl/nvim-miniyank to be able to do
" proper block pasting in neovim.
" So all in all, it might be worth waiting a bit until some of that software has
" matured a bit more.

" Mouse Behavior
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
map <ScrollWheelUp> <nop>
map <S-ScrollWheelUp> <nop>
map <C-ScrollWheelUp> <nop>
map <ScrollWheelDown> <nop>
map <S-ScrollWheelDown> <nop>
map <C-ScrollWheelDown> <nop>
map <ScrollWheelLeft> <nop>
map <S-ScrollWheelLeft> <nop>
map <C-ScrollWheelLeft> <nop>
map <ScrollWheelRight> <nop>
map <S-ScrollWheelRight> <nop>
map <C-ScrollWheelRight> <nop>

" Remap arrow keys to do scrolling
" This has the added advantage of avoiding bad cursor movement habits ;)
map <Up> <C-y>
map <Down> <C-e>
map <Left> <NOP>
map <Right> <NOP>

" Line Numbering
set number
set relativenumber
set numberwidth=1

" Folding
set foldmethod=syntax
set fillchars=vert:\|,fold:\ 
"set foldnestmax=1
"set foldminlines=2
nnoremap <Space> za

" Search
set hlsearch
nnoremap /<CR> :noh<CR>

" Tabbing, Indenting
set expandtab
set shiftwidth=2
set tabstop=2
set cindent

" Show 81st column
set colorcolumn=81
" I don't set an explicit highlight color, since the default light and dark
" solarized colors work nicely

" Show whitespace characters
set listchars=tab:+-,nbsp:·,trail:·
set list
" The following is a line with a tab, trailing whitespace and a nbsp.
	" OK... Here is the nbsp:  And here is some whitespace:    

" Moving lines up and down
nnoremap <c-j> :m .+1<CR>==
nnoremap <c-k> :m .-2<CR>==
inoremap <c-j> <Esc>:m .+1<CR>==gi
inoremap <c-k> <Esc>:m .-2<CR>==gi
vnoremap <c-j> :m '>+1<CR>gv=gv
vnoremap <c-k> :m '<-2<CR>gv=gv

" Enable spell checking
"set spell spelllang=en_us

" Use solarized color scheme :)
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
  " well just write a function. Down't know if the plugin does more than just
  " toggling the background like this function, though.
  if &background == "light"
    set background=dark
  else
    set background=light
  endif
endfunction
nnoremap + :call ToggleBackground()<Esc>

" for vim's native netrw browser
" let g:netrw_banner=0
let g:netrw_liststyle=3

" --------
" providers
" --------

" python needs the neovim package installed
" Set the location of the python binary. provider.txt says setting this makes startup faster
if s:hostname == "lasse-mbp-0"
  let g:python_host_prog = '/usr/local/bin/python2'
elseif s:hostname == "lasse-mba-0"
  let g:python_host_prog = '/usr/local/bin/python2'
elseif s:hostname == "lasse-bsd-1"
  let g:python_host_prog = '/usr/local/bin/python2.7'
elseif s:hostname == "lasse-ubuntu-0"
  let g:python_host_prog = '/usr/bin/python2.7'
endif
" not sure if this is sensible, but i guess it doesn't hurt
let g:loaded_python3_provider = 1
let g:loaded_ruby_provider = 1
let g:loaded_node_provider = 1

" --------
" for clang-format integration
" --------
" this section needs further revision to suit my bsd system

if s:hostname == "lasse-mbp-0"
  " tells clang-format.py where clang-format is located
  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'

  function! FormatFile()
    let l:lines="all"
    pyf /usr/local/opt/llvm/share/clang/clang-format.py
  endfunction
  
  " defined by myself (incredigital)
  let g:no_clang_format_on_save = 0
  
  function! Formatonsave()
    if g:no_clang_format_on_save == 0
      let l:formatdiff = 1
      pyf /usr/local/opt/llvm/share/clang/clang-format.py
    endif
  endfunction
  autocmd BufWritePre *.h,*.hpp,*.hxx,*.c,*.cpp,*.cxx,*.C,*.cc call Formatonsave()
  
  nnoremap <c-f> :call FormatFile()<cr>
  vnoremap <c-f> :pyf /usr/local/opt/llvm/share/clang/clang-format.py<cr>
  inoremap <c-f> <c-o>:silent pyf /usr/local/opt/llvm/share/clang/clang-format.py<cr>
  
elseif s:hostname == "lasse-mba-0"
  
elseif s:hostname == "lasse-bsd-0"
  
endif

" --------
" vim-plug
" --------

" vim-plug needs to be installed beforehand, no autoinstall here
" i chose the directory name plugged as suggested by the vim-plug readme
call plug#begin('~/.config/nvim/plugged')
Plug 'scrooloose/nerdcommenter'
Plug 'ctrlpvim/ctrlp.vim'
" YCM needs a working python environment and cmake to install itself
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
Plug 'dag/vim-fish'
" I'll need miniyank until block pasting on macos with clipboard=unnamed is
" fixed in neovim
Plug 'bfredl/nvim-miniyank'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim' " Dependency of ranger.vim
"Plug 'thaerkh/vim-indentguides'
" at some point I should probably consider that surround plugin everyone uses :D
Plug 'junegunn/goyo.vim'
Plug 'matcatc/vim-asciidoc-folding' " I'll need this as long as the official
" asciidoc syntax support does not support folding
call plug#end()

" --------
" for YouCompleteMe
" --------

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
let g:ycm_key_list_select_completion = ['<TAB>']
let g:ycm_key_list_previous_completion = ['<S-TAB>']
"let g:ycm_key_list_stop_completion = ['<C-y>', '<Esc>', '<Up>', '<Down>']
let g:ycm_key_list_stop_completion = ['<C-y>', '<Up>', '<Down>']
noremap <c-g> :YcmCompleter GoTo<cr>

" --------
" for NERDCommenter
" --------
map <c-h> <leader>cu
nmap <c-h> <leader>cu:set whichwrap-=h<cr>2h:set whichwrap+=h<cr>
imap <c-h> <c-o><leader>cu<c-o>:set whichwrap-=[<cr><left><left><c-o>:set whichwrap+=[<cr>
map <c-l> <leader>cl
nmap <c-l> <leader>cl2l
imap <c-l> <c-o><leader>cl<right><right>
let NERDCommentWholeLinesInVMode=1

" --------
" for vim-fish
" --------

" Set up :make to use fish for syntax checking.
autocmd FileType fish compiler fish
" Set this to have long lines wrap inside comments.
autocmd FileType fish setlocal textwidth=79
" Enable folding of block structures in fish.
autocmd FileType fish setlocal foldmethod=expr

" --------
" for nvim-miniyank
" --------

map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)

" --------
" for vim-ranger
" --------

let g:ranger_map_keys = 1
let g:ranger_replace_netrw = 1

"" --------
"" for vim-indentguides
"" --------
"
"" I might want to adjust this color to something a little more subtle
"" I might also want to find a second color for the bright solarized scheme
"let g:indentguides_conceal_color = 'ctermfg=10 ctermbg=NONE guifg=Grey27 guibg=NONE'
"let g:indentguides_specialkey_color = 'ctermfg=10 ctermbg=NONE guifg=Grey27 guibg=NONE'
"" This character is not ideal as it overlaps into the previous line
"let g:indentguides_spacechar = "⎸"

" --------
" for vim-asciidoc-folding
" --------

autocmd FileType asciidoc setlocal foldmethod=expr
