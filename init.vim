" init.vim or '.vimrc' file thrown together by me (incredigital)

" get hostname to allow for platform-dependent customization
let s:hostname = substitute(system('hostname'), '\n', '', '')

" --------
" Miscellaneous things
" --------

" To form better habits
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" All kinds of stuff
set whichwrap+=<,>,h,l,[,],~
set path+=**
set clipboard+=unnamedplus
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

" Mouse Behavior
set mouse=a
set mousemodel=popup_setpos " i might want to configure a menu for this
:map <ScrollWheelUp> <C-Y>
:map <S-ScrollWheelUp> <C-U>
:map <ScrollWheelDown> <C-E>
:map <S-ScrollWheelDown> <C-D>

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
elseif s:hostname == "lasse-bsd-0"
  let g:python_host_prog = '/usr/local/bin/python2.7'
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
call plug#end()

" --------
" for YouCompleteMe
" --------

if s:hostname == "lasse-mbp-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python2'
elseif s:hostname == "lasse-mba-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python2'
elseif s:hostname == "lasse-bsd-0"
  let g:ycm_server_python_interpreter = '/usr/local/bin/python2.7'
endif
"let g:ycm_python_binary_path = '/usr/local/bin/python3'
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

