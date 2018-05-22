" init.vim or '.vimrc' file thrown together by me (incredigital)

" get hostname to allow for platform-dependent customization
let s:hostname = substitute(system('hostname'), '\n', '', '')

" --------
" Miscellaneous things
" --------

set whichwrap+=<,>,h,l,[,]
set mouse=a
set path+=**
set clipboard+=unnamedplus
set number
set relativenumber
set so=7
" set cmdheight=2
set ignorecase
set smartcase
set hlsearch
set incsearch 
set lazyredraw 
set expandtab
set shiftwidth=2
set tabstop=2
set cindent
set laststatus=2
set statusline=%{getcwd()}%=%f%m%r%h%w%=%l,%c%V\ %P

" from http://vim.wikia.com/wiki/Moving_lines_up_or_down
nnoremap <c-j> :m .+1<CR>==
nnoremap <c-k> :m .-2<CR>==
inoremap <c-j> <Esc>:m .+1<CR>==gi
inoremap <c-k> <Esc>:m .-2<CR>==gi
vnoremap <c-j> :m '>+1<CR>gv=gv
vnoremap <c-k> :m '<-2<CR>gv=gv

" Use solarized color scheme :)
set background=dark
colorscheme solarized

" for vim's native netrw browser
" let g:netrw_banner=0
let g:netrw_liststyle=3

" --------
" providers
" --------

" Set the location of the python binary. provider.txt says setting this makes startup faster
if s:hostname == "lasse-mbp-0"
  let g:python_host_prog = '/usr/local/bin/python2'
elseif s:hostname == "lasse-bsd-0"
  let g:python_host_prog = '/usr/local/bin/python2.7'
endif
" not sure if this is sensible, but i guess it doesn't hurt, especially when i don't have python3 installed anyway
let g:loaded_python3_provider = 1

" --------
" for clang-format integration
" --------
" this section needs further revision to suit my bsd system

if s:hostname == "lasse-mbp-0"
  " tells clang-format.py where clang-format is located
  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'

  function FormatFile()
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
call plug#end()

" --------
" for YouCompleteMe
" --------

if s:hostname == "lasse-mbp-0"
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

