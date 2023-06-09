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

" NOTE: `.` gets deprecated in favor of `..`. See `:h expr-..`

" NOTE: There is an issue with syntax highlighting that I may encounter for a
" while when editing this file. Specifically, lua code blocks may show closing
" parentheses as erroneous when in fact they aren't and this may also break the
" syntax highlighting underneath…
" See https://github.com/neovim/neovim/issues/20456
" Treesitter does a better job, so I'll manually enable it here for now
augroup MyVimscriptLuaHighlightWorkaround
  autocmd FileType vim lua vim.treesitter.start()
augroup END

" {{{1 Essential initializations

" This is always set in Neovim, but doesn't hurt to set it explicitly.
" It resets some other options in Vim, which is why it should be set early
set nocompatible

" POSIX compliance needed
set shell=/bin/sh

" Neovim providers
if has("nvim")
lua << EOF
  -- Set the location of the Python 3 binary. `provider.txt` says setting this
  -- makes startup faster.
  -- NOTE: Python 3 needs the `pynvim` package installed.
  local hostname = vim.fn.hostname()
  if hostname == "lasse-mbp-0" then
    vim.g.python3_host_prog = "/usr/local/bin/python3"
  elseif hostname == "lasse-mba-0" then
    vim.g.python3_host_prog = "/usr/local/bin/python3"
  elseif hostname == "lasse-alpine-env-0" then
    vim.g.python3_host_prog = "/usr/bin/python3"
  end

  -- Explicitly disable some (unneeded?) providers.
  vim.g.loaded_python_provider = 0
  -- vim.g.loaded_python3_provider = 0
  vim.g.loaded_ruby_provider = 0
  vim.g.loaded_node_provider = 0
  vim.g.loaded_perl_provider = 0
EOF

  " Use CPCP for clipboard handling if available
  let s:cpcp_command = ''
  for cmd in 
  \   [$HOME..'/.config/cross-platform-copy-paste/cpcp.sh', 'cpcp', 'cpcp.sh']
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
    \      '+': s:cpcp_command .. ' --base64=auto',
    \      '*': s:cpcp_command .. ' --base64=auto',
    \    },
    \   'paste': {
    \      '+': s:cpcp_command .. ' --base64=auto paste',
    \      '*': s:cpcp_command .. ' --base64=auto paste',
    \   },
    \   'cache_enabled': 1,
    \ }

    let g:clipboard = s:cpcp_clipboard
  endif

  " If I'm ever confused about how Neovim handles copying whole lines again:
  " It's simple. No metadata or anything. Neovim just copies a line with its
  " trailing newline and when pasting determines whether to paste as a new line
  " or as text inside the current line depending on whether the pasted buffer
  " ends on a newline. I assume it's the same for regular Vim, but don't know
  " for sure at the time of writing this.
endif

" Tell Python X to always use Python 3
if has("pythonx") | set pyxversion=3 | endif

" If this file is used from Vim (not Neovim)
if !has("nvim")
  set runtimepath+=$HOME/.config/nvim
endif

" Set leader key to backslash. This is the default, but I do it here explicitly
" to remind myself that this should be done before any leader-dependent mappings
" are created.
let g:mapleader = "\\"

" {{{1 Features and plugins

" * To check for platforms or features, use `has`
"   * e.g. to find out if it's Neovim, run `has('nvim')`
" * Vim version resides in variable `v:version`
" * `hostname()` returns the hostname.
" * `exists("+foo")` to check if an option exists (see `:h hidden-options`)

" NOTE: I'd like the two dictionaries below to be script-local, but then they
" wouldn't be accessible by lua.

" Feature list: used to enable/disable sections of this file
" Values should be numbers, not `v:true`/`v:false`
let g:my_features = {
\ "automatic_background_handling": has("nvim"),
\ "basic_editor_setup": 1,
\ "native_filetype_plugins_config": 1,
\ "plugin_management": has("nvim"),
\ "my_dim_colorscheme": 1,
\ "vim_commentary": 0,
\ "nerdcommenter": 1,
\ "julia_vim": 1}

" Plugin list: I chose to do the old "another layer of indirection" here and
" write these out into this dictionary, so that I can separate my plugin list
" from the plugin manager. The key for every entry is the corresponding feature
" name, the value is a dictionary containing the plugin name and author plus
" another dictionary with optional further specifications.
let g:my_plugins = {
\ "my_dim_colorscheme": {
\   "name": "vim-dim",
\   "author": "jeffkreeftmeijer",
\   "options": {"branch": "1.x"}},
\ "nerdcommenter": {
\   "name": "nerdcommenter",
\   "author": "preservim",
\   "options": {}},
\ "vim_commentary": {
\   "name": "vim-commentary",
\   "author": "tpope",
\   "options": {}},
\ "julia_vim": {
\   "name": "julia-vim",
\   "author": "JuliaEditorSupport",
\   "options": {"lazy": v:true, "event": "FileType julia"}}
\ } " Separated this `}` to not unintentionally create a fold marker

" Notes about features/plugins:
"
" Regarding `tpope/vim-commentary` vs. `preservim/nerdcommenter`:
" `vim-commentary` is a nice plugin insofar as it's very small and leverages a
" bunch of vanilla vim functionality, including operators/motions. Seems to me
" like it does exactly what needs to be done, exactly how it needs to be done,
" without a lot of bells and whistles. `nerdcommenter` has more configurable
" behavior, e.g. how to handle empty lines, whether to comment small pieces
" instead of whole lines out if possible, etc. Seems like both plugins are very
" stable and here to stay, as of 2023-06.
"
" `JuliaEditorSupport/julia-vim`: This plugin, as of 2023-06, does two things:
" LaTeX-to-unicode substitutions and block-wise movements with `matchit`. It is
" not a syntax or indentation plugin, as these are already included with vim.
" It seems to me that the block-wise movements work without the plugin too, not
" sure why, but if I explicitly disable them for the plugin they don't work
" anymore. Since this plugin adds like 30ms startup time, I lazy load it if
" possible. For some reason it doesn't work with `lazy.nvim`s `ft` option, but
" with `event = "FileType julia"` it's fine. Maybe I should see if there's some
" other LaTeX-to-unicode plugin that's better than this one and always
" available, as that's really the only functionality I seem to need from this.

if g:my_features["plugin_management"] " {{{1

if has("nvim")
lua << EOF
  -- Use `lazy.nvim` as plugin manager
  -- This is the installation code recommended in their readme file:
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  -- Construct plugin spec, disable based on feature switches
  -- NOTE: I had a hard time finding a neater way of constructing tables than
  -- consecutive assignments or `insert` calls.
  local plugins = {}
  for feature, plugin in pairs(vim.g.my_plugins) do
    local spec = {string.format("%s/%s", plugin.author, plugin.name),
      enabled = vim.g.my_features[feature] ~= 0}
    for key, value in pairs(plugin.options) do
      spec[key] = value
    end
    table.insert(plugins, spec)
  end

  -- Options
  opts = nil -- nothing for now

  -- Run `lazy.nvim`
  require("lazy").setup(plugins, opts)
EOF
else " has("nvim")
  echo "Plugin management requested for non-neovim: \
    I don't have one set up in init.vim"
endif

else " g:my_features["plugin_management"]

  " Let's add putative plugin locations, as these can still be used without
  " plugin management.

  let plugin_root_dirs = [
\     expand("$HOME/.local/share/nvim/lazy/"),
\     expand("$HOME/.config/nvim/plugged/")]

  let plugin_root_dirs = filter(plugin_root_dirs, "isdirectory(v:val)")

  for [feature, plugin] in items(g:my_plugins)
    if g:my_features[feature]
      for plugin_root_dir in plugin_root_dirs
        let plugin_dir = plugin_root_dir .. plugin["name"]
        if isdirectory(plugin_dir)
          let &runtimepath ..= "," .. plugin_dir
          break
        endif
      endfor
    endif
  endfor
endif " g:my_features["plugin_management"]

" {{{1 vim-plug

" `vim-plug` needs to be installed beforehand, I have not automated that here.
" I chose the directory name `plugged` as suggested by the `vim-plug` readme.

" TODO: What about Neovim's native plugin manager? Is it good enough to justify
" dropping `vim-plug` at some point?

"call plug#begin('$HOME/.config/nvim/plugged')
"
"" 2022-02: Some general thoughts on autocompletion/linting/LSP plugins: When I
"" started using Vim seriously around 2018 or so, I was in search of this
"" functionality, particularly in regards to C++. At that time, YouCompleteMe
"" seemed to be the de-facto standard for this. Since then, LSP has seen wide
"" adoption, and a lot more options have popped up. As far as I can tell, ALE was
"" indeed a mere linting engine, while YCM didn't even implement LSP. Today, the
"" waters have been muddied because each plugin wants to do it all now. Which
"" sort of makes sense, since completion, linting, even syntax highlighting, and
"" so on are relatively closely coupled functionalities, so not necessarily the
"" kind of stuff that you absolutely want to keep modular and separate. Beyond
"" ALE and YCM, there exist a selection of other plugins. Of these, `coc` seems
"" to be relatively popular at the moment. It depends on Node.js, however, which
"" is something I would be glad to avoid – perhaps without good reasons except my
"" taste – I don't know. I am not completely sure what to make of this at the
"" moment, but I guess for now I'll simply limit YCM to the CXX-family
"" `filetype`s, since I get the feeling that it's still very comprehensive for
"" those (although I also get the feeling that the other options can deliver
"" similar power), and then try to do the rest with ALE and perhaps Deoplete
"" (which is already being gradually replaced by `ddc`, however). Migrating away
"" from YCM may prove beneficial in the end, because (a) I can reduce the number
"" of (potentially interfering) plugins, (b) YCM is not that light-weight, and
"" (c) YCM has this non-trivial post-update hook which tends to fail if things
"" are not set up properly, making the process somewhat tedious.
"" Another point that adds to all of this is that Neovim is in the process of
"" enabling support for LSP natively at the moment, so who knows, perhaps I won't
"" need any plugins for this anymore at some point.
"" I will probably remove this whole comment block at some point in the future,
"" but for now it serves as a reference on the current state of affairs, or at
"" least my grasp of it, and I want to have it in the commit history.
"
"Plug 'dense-analysis/ale'
"
"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"
"" YCM needs a working Python environment and Cmake to install itself.
"" Consequently, I enable YCM only on some hosts.
"" TODO: Separate the hostname-dependent part out and define some general on/off
"" and config switches for plugins?
"if hostname() == "lasse-mbp-0" || hostname() == "lasse-mba-0" || hostname() == "lasse-debian-0"
"  Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clang-completer' }
"end
"
"" On alpine, use system libclang.
"if hostname() == "lasse-alpine-env-0"
"  Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clang-completer --system-libclang' }
"end
"
"Plug 'preservim/nerdcommenter'
"
"" Disabled for now in favor of vim-ranger
""Plug 'ctrlpvim/ctrlp.vim' " TODO: Substitute with Telescope?
"
"Plug 'dag/vim-fish'
"
"" Seems like this is a newer and better fish syntax plugin, but at the moment I
"" get errors when using it…
"" TODO: Could this be because of my additional config for fish files below?
""Plug 'khaveesh/vim-fish-syntax'
"
"" NOTE: There are many claims that netrw is a bad and buggy piece of software
"" and should probably be rewritten entirely. However, it does more than just
"" being a file browser, which is why it's not a good idea to fully disable it.
"" However, replacing the file browsing part with another plugin makes sense.
"" The situation with netrw is unfortunate. On the one hand, it would be more
"" unix-y to separate the text editor and the file browser into two loosely
"" coupled standalone programs. On the other hand, given that this thing already
"" exists, it would be nice to make use of it as a vanilla part of vim. Still, I
"" think the best solution for now is to just ignore it and hope that it gets
"" deprecated in favor of a better solution or something.
"Plug 'francoiscabrol/ranger.vim'
"Plug 'rbgrouleff/bclose.vim' " Dependency of `ranger.vim`
"
"Plug 'tpope/vim-surround'
"Plug 'tpope/vim-repeat' " Makes `.` work for `vim-surround`.
"
""Plug 'junegunn/goyo.vim'
"
"Plug 'matcatc/vim-asciidoc-folding' " I'll need this as long as the official
"" Asciidoc syntax support does not support folding
"
""Plug 'https://github.com/arnoudbuzing/wolfram-vim.git' " This is only a syntax
""" file, not a 'real' plugin
"
""Plug 'guns/xterm-color-table.vim'
"
"" If at some point I'll switch to lazy plugin loading: VimTeX should not be
"" loaded lazily.
"Plug 'lervag/vimtex'
"
"Plug 'JuliaEditorSupport/julia-vim'
"
"" Modification of Vim's default color scheme, using only ANSI colors
"Plug 'jeffkreeftmeijer/vim-dim', {'branch': '1.x'}
"
"call plug#end()

if g:my_features["automatic_background_handling"] " {{{1

" NOTE: As a summary for the below notes: Getting iTerm2, tmux and Neovim (and
" possibly also other terminals and SSH/Mosh) to play nicely together so that
" the `background` option is always synchronized automatically is something
" people are definitely working on here and there, but it seems like the state
" of things is not quite ideal at the moment. I'll try to cover some reasonable
" cases but may have to set `background` manually in some instances.
" NOTE: Setting `background` should be done automatically by Neovim. This seems
" to depend on some `autocmd`, so deleting all autocommands in the beginning of
" the vimrc file (like some do) breaks it. The detection uses an OSC11 escape
" sequence, which is basically a query to the Terminal about its background
" color.
" NOTE: iTerm2 sends `SIGWINCH` on profile changes and Neovim has an `autocmd
" Signal SIGWINCH`. I don't know if `SIGWINCH` triggers re-detection of
" background color already or if an extra `autocmd` needs to be added here.
" Also, I can't even get any such autocommand to work with my setup…
" NOTE: The automatic detection does not work inside `tmux`, as `tmux` does not
" respond to the OSC11 escape sequence. This is because `tmux` could be running
" in several terminals simultaneously. If the background color in `tmux` was set
" by the user, it does respond, but this means I would then need to manage the
" synchronization of `tmux`'s background color with the terminal's colors, which
" seems unnecessarily non-elegant and error-prone.
" NOTE: Neovim removed some code that used the environment variable `COLORFGBG`
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
  " NOTE: the `++nested` is needed to re-apply the color scheme in response to
  " the `background` option's value changing
  autocmd Signal SIGWINCH ++nested call AttemptBackgroundDetect()
  "" These are a sad workaround because SIGWINCH doesn't seem to work for me
  "autocmd CursorHold * ++nested call AttemptBackgroundDetect()
  "autocmd CursorHoldI * ++nested call AttemptBackgroundDetect()
augroup END

endif " g:my_features["automatic_background_handling"]

if g:my_features["my_dim_colorscheme"] " {{{1

" Use colorscheme `dim` to inherit terminal colors and extend/modify it a bit
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
function! MyDimModifications() abort
  highlight StatusLine                   ctermfg=NONE ctermbg=NONE cterm=inverse
  highlight Error                        ctermfg=9    ctermbg=NONE
  highlight Todo                         ctermfg=11   ctermbg=NONE

  if &background == "light"
    highlight LineNr                     ctermfg=15
    highlight CursorLineNr               ctermfg=7
    highlight SignColumn                 ctermfg=15   ctermbg=NONE
    highlight Whitespace                 ctermfg=15
    highlight NonText                    ctermfg=15
    highlight ColorColumn                ctermfg=8    ctermbg=15
    highlight Folded                     ctermfg=8    ctermbg=NONE cterm=bold
    highlight StatusLineNC               ctermfg=7    ctermbg=NONE cterm=inverse
    highlight StatusLineWeak             ctermfg=NONE ctermbg=7    cterm=inverse
    highlight StatusLineNCWeak           ctermfg=7    ctermbg=15   cterm=inverse
  else
    highlight LineNr                     ctermfg=8
    highlight CursorLineNr               ctermfg=16
    highlight SignColumn                 ctermfg=8    ctermbg=NONE
    highlight Whitespace                 ctermfg=8
    highlight NonText                    ctermfg=8
    highlight ColorColumn                ctermfg=7    ctermbg=16
    highlight Folded                     ctermfg=7    ctermbg=NONE cterm=bold
    highlight StatusLineNC               ctermfg=16   ctermbg=NONE cterm=inverse
    highlight StatusLineWeak             ctermfg=NONE ctermbg=8    cterm=inverse
    highlight StatusLineNCWeak           ctermfg=16   ctermbg=8    cterm=inverse
  endif
endfunction

augroup MyColors
  autocmd ColorScheme dim ++nested call MyDimModifications()
augroup END

" Set colorscheme only after all the `background` and custom highlighting
" business has been handled.
colorscheme dim

endif " g:my_features["my_dim_colorscheme"]

if g:my_features["basic_editor_setup"] " {{{1

" Use quoteplus register for clipboard
set clipboard+=unnamedplus

" Long lines continue left and right instead of wrapping
set nowrap

" Search wraps at top and bottom of file
set wrapscan

" Make some left/right-movements wrap to the previous/next line
set whichwrap+=<,>,h,l,[,],~

" TODO: What did I add this for?
" I think it's a way to do fuzzy finding in vanilla Vim
set path+=**

"set lazyredraw " Disabled this on 2023-04-25 to try and see if some occasional
                " glitches would disapper

" Highlight the line the cursor is on
set cursorline

" Command line completion behavior
set wildchar=<tab>
set wildignorecase
set wildmode=full
set wildoptions=fuzzy,pum,tagfile
cnoremap <Left> <Space><BS><Left>
cnoremap <Right> <Space><BS><Right>

" Don't show mode in command line
set noshowmode

" {{{2 Status line definitions
" I chose to not use any plugins and try to do what I want by myself.

" Function to get the correct highlight
function MyStatuslineHighlightLookup(is_focused, type) abort
  let l:highlight = "%#"
  let l:highlight ..= a:is_focused ? "StatusLine" : "StatusLineNC"
  if a:type == "weak"
    let l:highlight_weak = l:highlight .. "Weak"
    if hlexists(l:highlight_weak)
      let l:highlight = l:highlight_weak
    endif
  endif
  let l:highlight ..= "#"
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
  let l:statusline ..= '%<' " Truncate from the beginning
  let l:statusline ..= MyStatuslineHighlightLookup(l:is_focused, 'weak')
  let l:statusline ..= '%{pathshorten(getcwd())}/%=' " Current working directory
  let l:statusline ..= MyStatuslineHighlightLookup(l:is_focused, 'strong')
  let l:statusline ..= '%f%=' " Current file
  let l:statusline ..= ' [%{mode()}]%m%r%h%w%y ' " Mode, flags, and filetype
  let l:statusline ..= '%l:%c%V %P' " Cursor position

  return statusline
endfunction " }}}2

" Use custom status line defined above
set statusline=%!MyStatusline()

" Always put a status line on every window.
set laststatus=2

" Bracket pairs matched by `%`
set matchpairs=(:),{:},[:],<:>

" Maximum height of the popup menu for insert mode completion
set pumheight=12

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
" NOTE: I like the behavior of this more than `<` and `>` in normal mode.
nnoremap <c-h> a<c-d><esc>
nnoremap <c-l> a<c-t><esc>
inoremap <c-h> <c-d>
inoremap <c-l> <c-t>
" NOTE: `gv` keeps the lines selected. However, it does not select the exact
" same content when done like this. I guess that's okay for now.
vnoremap <c-h> <lt>gv
" NOTE: I'm using `<char-62>` to target the key `>` because there is no `<gt>`.
vnoremap <c-l> <char-62>gv

" Rely on syntax highlighting to create folds
set foldmethod=syntax

" Don't print a line of `·`s or `-`s behind a closed fold
set fillchars+=fold:\ 

" Allow closing folds that only take up one line
set foldminlines=0

" Open and close folds with space bar
nnoremap <space> za

" NOTE: I had a function here that opened all folds and then only closed the
" outermost ones. I had planned on calling that function every time a new file
" was opened, but failed to do it with `autocmd`. Thinking about it now, it's
" probably not the best way to do it anyway. Sometimes I definitely want nested
" folds being closed by default. It's probably rather a question of not folding
" every single little for-loop in some filetypes and so on. But should I need
" the function in the future, it should be in the commit history up to 2023-05
" or so.

" Don't use an additional sign column ("gutter"), place signs on number columns
set signcolumn=number

" When writing, show "[w]" isntead of "written"
set shortmess+=w

" Search, replace
set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap /<cr> :nohlsearch<cr>
nnoremap - :%s///g<left><left><left>
nnoremap _ :%s///g<left><left><left><c-r><c-w><right>

" By default, don't conceal
set conceallevel=0

" Use spaces as tabs and indent with a width of 2 by default
set expandtab
set shiftwidth=2
set tabstop=2

" `list` mode to visualize whitespaces, continuing lines, etc.
set list

" {{{2 `listchars` handling

" NOTE: Since I use the `listchars` to show indent guides, I need to synchronize
" them with the `shiftwidth`. I have to reset the full `listchars` option
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
    let &listchars ..= name . ':' . str . ','
  endfor
  let &listchars ..= 'leadmultispace:▏' . repeat('\x20', shiftwidth() - 1)
endfunction

" Trigger `UpdateListchars` at the appropriate times
augroup MyOptionUpdaters " Not sure about this group name
  autocmd OptionSet shiftwidth call UpdateListchars()
  " Not sure if the below is necessary
  autocmd BufWinEnter * call UpdateListchars()
augroup END
" }}}2

" Show a tree-style listing in netrw browser by default
let g:netrw_liststyle=3

" Use arrow keys for scrolling
noremap <up> <c-y>
noremap <down> <c-e>
noremap <left> z<left>
noremap <right> z<right>

" Use mouse in all modes
set mouse=ar

" Use right-clicking to open a context menu
set mousemodel=popup_setpos " I might want to configure a menu for this.

" Don't scroll further horizontally than the cursor position (default anyway)
set sidescroll=1

" {{{2 Scroll wheel mapping

" Weird looking scroll wheel mapping.
" Here's a corresponding GitHub issue:
" https://github.com/neovim/neovim/issues/6211
" NOTE: This has one limitation: Inactive windows can not be scrolled with the
" mouse
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
" }}}2

endif " g:my_features["basic_editor_setup"]

if g:my_features["native_filetype_plugins_config"] " {{{1

  " The filetype plugins included with (neo)vim have configuration options. This
  " section configures some of them.

  " TeX {{{2
  " Default TeX flavor
  let g:tex_flavor = 'latex'

  " Disable concealing
  let g:tex_conceal = ''

  " Julia {{{2
  " Don't have the shiftwidth be set to 4
  let g:julia_set_indentation = 0

  " Don't highlight operators
  let g:julia_highlight_operators = 0

  " }}}2

endif

if g:my_features["nerdcommenter"] " {{{1

" The plugin would usually create a whole bunch of `<leader>`… mappings
let g:NERDCreateDefaultMappings = 0

let g:NERDCommentEmptyLines = 1

let g:NERDTrimTrailingWhitespace = 1

" NOTE: `<gt>` does not exist, instead `<char-62>` can be used
map <lt> <plug>NERDCommenterUncomment
map <char-62> <plug>NERDCommenterAlignBoth
vmap <char-62> <plug>NERDCommenterComment

endif " g:my_features["nerdcommenter"]

" {{{1 Clang-format integration

"" TODO: ALE supports `clang-format` as a fixer, so perhaps I should use that
"" instead. This whole section is a little hacky and platform-dependent anyway.
"
"let g:clang_format_on_save = 0 " Defined by myself
"
"function Formatonsave()
"  if g:clang_format_on_save == 1
"    let l:formatdiff = 1
"    if hostname() == "lasse-mbp-0" || hostname() == "lasse-mba-0"
"      py3f /usr/local/opt/llvm/share/clang/clang-format.py
"    elseif hostname() == "lasse-lubuntu-0"
"      py3f /usr/share/clang/clang-format-10/clang-format.py
"    endif
"  endif
"endfunction
"
"function FormatFile()
"  let l:lines="all"
"    if hostname() == "lasse-mbp-0" || hostname() == "lasse-mba-0"
"      py3f /usr/local/opt/llvm/share/clang/clang-format.py
"    elseif hostname() == "lasse-lubuntu-0"
"      py3f /usr/share/clang/clang-format-10/clang-format.py
"    endif
"endfunction
"
"autocmd FileType c,cpp nnoremap <buffer> <c-f> :call FormatFile()<cr>
"autocmd FileType c,cpp vnoremap <buffer> <c-f> :py3f /usr/local/opt/llvm/share/clang/clang-format.py<cr>
"autocmd FileType c,cpp inoremap <buffer> <c-f> <c-o>:silent py3f /usr/local/opt/llvm/share/clang/clang-format.py<cr>
"
"autocmd BufWritePre *.h,*.hpp,*.hxx,*.c,*.cpp,*.cxx,*.C,*.cc call Formatonsave()
"
"" `g:clang_format_path` tells `clang-format.py` where the clang-format binary is
"" located.
"if hostname() == "lasse-mbp-0"
"  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'
"elseif hostname() == "lasse-mba-0"
"  let g:clang_format_path = '/usr/local/opt/llvm/bin/clang-format'
"endif

" {{{1 Configuration of plugins

"" TODO: Only configure plugins when they are present/enabled?
"
"" {{{2 YouCompleteMe configuration
"
"" Disable YCM for any non-CXX-family files.
"let g:ycm_filetype_whitelist = {'c': 1, 'cpp': 1}
"
"if hostname() == "lasse-mbp-0"
"  let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
"elseif hostname() == "lasse-mba-0"
"  let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
"elseif hostname() == "lasse-debian-0"
"  let g:ycm_server_python_interpreter = '/usr/bin/python3'
"elseif hostname() == "lasse-alpine-env-0"
"  let g:ycm_server_python_interpreter = '/usr/bin/python3'
"endif
"let g:ycm_error_symbol = 'E>'
"let g:ycm_warning_symbol = 'W>'
"let g:ycm_complete_in_comments = 1
"let g:ycm_key_list_select_completion = ['<tab>']
"let g:ycm_key_list_previous_completion = ['<s-tab>']
"let g:ycm_key_list_stop_completion = ['<c-y>', '<c-e>', '<up>', '<down>']
"noremap ? :YcmCompleter GoTo<cr> " I don't use `?` for backward search anyway.
"
"" NOTE that the above tab key assignments seem to happen if YCM is loaded, even
"" if it is disabled. That way, the popup menu as used by ALE also works with the
"" tab key. That's nice, but it'd be better if it worked without YCM.
"
"" {{{2 ALE configuration
"" ALE runs all available linters by default. I would like to choose my linters
"" by myself and enable them one by one here. Hence the following setting. This
"" also mitigates interference with YouCompleteMe.
"let g:ale_linters_explicit = 1
"
"" ALE linters to enable, by language
"" NOTE: Doing `:ALEInfo` shows supported and enabled linters for the buffer.
"" NOTE: For the `julia` `languageserver` linter to work, make sure the following
"" packages are installed: `LanguageServer`, `SymbolServer`, and `StaticLint`.
"" For ALE to start the linter, the respective Julia file needs to belong to a
"" Julia Project with a `Project.toml` file.
"" Also see the Julia- and LanguageServer.jl-specific source files of ALE if
"" things should change in the future.
"let g:ale_linters = {
"  \ 'fish': ['fish'],
"  \ 'sh': ['shell'],
"  \ 'cpp': [],
"  \ 'python': ['flake8'],
"  \ 'julia': []} " ['languageserver']}
"
"let g:ale_sign_error = 'E>'
"let g:ale_sign_warning = 'W>'
"
"let g:ale_echo_msg_format = '%s [%linter%% code%]'
"
"" Disable ALE completion. This is the default, but I set it here explicitly to
"" emphasize that I'm using other means of completion.
"let g:ale_completion_enabled = 0
"
"" Set flake8 ignore list in this vim config
"" Could use flake8's config files alternatively
"call ale#Set('python_flake8_options',
"  \ '--ignore=E111,E114,E121,E128,E201,E203,E221,E222,E226,E241,E251,E261,E262,E302,E303,E305,E501,E702,E731,W391,W504')
"
"" {{{2 Deoplete configuration
"
"" NOTE: Deoplete latches onto the `ale` source automatically.
"
"let g:deoplete#enable_at_startup = 1
"
"" Disable Deoplete for CXX-family `filetype`s to let YCM take over
"autocmd FileType c,cpp
"  \ call deoplete#custom#buffer_option('auto_complete', v:false)
"
"" {{{2 vim-ranger configuration
"
"let g:ranger_map_keys = 0
"let g:ranger_replace_netrw = 1
"
"" If the current buffer is modified, open vim-ranger in a new window, unless
"" `hidden` is set.
"" vim-ranger will throw the error "E37: No write since last change" if the same
"" file as the currently open modified buffer is opened. I was not able to catch
"" or silence the error. I think this is because vim-ranger runs asynchronously
"" and the code of the below function just continues without waiting for the user
"" to quit ranger.
"function RangerSmart()
"  if !&hidden && getbufinfo("%")[0].changed
"    split +Ranger
"  else
"    Ranger
"  end
"endfunction
"
"command RangerSmart call RangerSmart()
"
"nmap <c-p> :RangerSmart<cr>
"
"" {{{2 vim-asciidoc-folding configuration
"
"autocmd FileType asciidoc setlocal foldmethod=expr
"
"" {{{2 wolfram-vim configuration
"
"autocmd BufNewFile,BufRead *.wl set syntax=wl
"autocmd BufNewFile,BufRead *.wls set syntax=wl
"autocmd BufNewFile,BufRead *.m set syntax=wl
"autocmd BufNewFile,BufRead *.nb set syntax=wl
"
"" {{{2 vim-fish configuration
"
"" Set up :make to use fish for syntax checking.
"autocmd FileType fish compiler fish
"" Set this to have long lines wrap inside comments.
"autocmd FileType fish setlocal textwidth=80
"" Enable folding of block structures in fish.
"autocmd FileType fish setlocal foldmethod=expr
"
"" {{{2 vimtex configuration
"
"" Don't try to use bibtex
"let g:vimtex_parser_bib_backend = 'vim'
"
"" Don't run document viewer automatically
"let g:vimtex_view_enabled = 0
"
"" Set up latexmk compiler
"let g:vimtex_compiler_method = 'latexmk'
"let g:vimtex_compiler_latexmk = {
"  \ 'build_dir' : '',
"  \ 'callback' : 0,
"  \ 'continuous' : 0,
"  \ 'executable' : 'latexmk',
"  \ 'hooks' : [],
"  \ 'options' : [
"  \   '-verbose',
"  \   '-file-line-error',
"  \   '-synctex=1',
"  \   '-interaction=nonstopmode',
"  \ ],
"  \}
"
"" Automatically compile on write
"" Continuous compilation may be possible with a daemon container…
""autocmd BufWritePost *.tex execute "VimtexCompileSS"
"
"let g:vimtex_fold_enabled = 1
"let g:vimtex_format_enabled = 1
"
"" Don't use conceal features
"let g:vimtex_syntax_conceal_default = 0
"
