" (the following line is a modeline)
" vim: foldmethod=marker

" {{{1 Miscellaneous

" Use quoteplus register for clipboard
set clipboard+=unnamedplus

" Long lines continue left and right instead of wrapping
set nowrap

" Make some left/right-movements wrap to the previous/next line
set whichwrap+=<,>,h,l,[,],~

" Lazy redrawing can help with slow scrolling and I have observed this myself. I
" bet it also reduces resource consumption. I have been wondering whether some
" glitches I got at some point came from this, but there's also
" something about syntax highlighting only looking back a set amount of lines
" before the current line which could have been the glitches I saw. By the way,
" if that happens, `redraw` or Ctrl+L don't help, making clear that it's not a
" redrawing problem.
set lazyredraw

" Highlight the line the cursor is on
set cursorline

" Bracket pairs matched by `%`
set matchpairs=(:),{:},[:],<:>

" Reduce key code delays
set ttimeoutlen=20

" By default, don't conceal
set conceallevel=0

" {{{1 Text format defaults (indenting, maximum width)

" I want this in most cases, therefore let's set it globally. Filetype scripts,
" modelines, etc. can be used to change it when needed.
" For reformatting, use `gq` or `gw`. `:help gq` and `:help gw` might help.
set textwidth=80

" Use spaces as tabs and indent with a width of 2 by default
set expandtab
set shiftwidth=2
set tabstop=2

" {{{1 File and buffer switching

" This allows basic fuzzy finding with vanilla Vim
set path+=**

" Opens the native fuzzy finder `:find` and shows suggestions
function MyNativeFuzzyFindOpen()
  call feedkeys(":find\<space>\<c-i>\<c-p>", "nt")
  return ""
endfunction

" Fuzzy find with meta-/
" The idea being that this mapping can be overriden by a fuzzy finding plugin,
" if any such plugin is enabled
if v:version > 800 " NOTE: Version is a guess
  nnoremap <m-/> <cmd>call MyNativeFuzzyFindOpen()<cr>
else
  nnoremap <expr> <m-/> MyNativeFuzzyFindOpen()
endif

" " Switch to alternate file with backspace
" nnoremap <bs> <c-^>

" Use Tab and Shift+Tab in normal mode to cycle through buffers
if v:version > 800 " NOTE: Version is a guess
  nnoremap <tab> <cmd>bnext<cr>
  nnoremap <s-tab> <cmd>bprevious<cr>
else
  nnoremap <silent> <tab> :bnext<cr>
  nnoremap <silent> <s-tab> :bprevious<cr>
endif

" {{{1 Netrw

" Show a tree-style listing in netrw browser by default
let g:netrw_liststyle=3

" {{{1 Command line

" Command mode completion behavior
set wildchar=<tab>
set wildignorecase
set wildmode=full
if v:version >= 900 || has("nvim-0.5") " NOTE: Versions are a guess
  set wildoptions=fuzzy,pum,tagfile
elseif v:version > 800 " NOTE: Versions are a guess
  set wildoptions=pum,tagfile
else
  set wildoptions=tagfile
endif

" If the completion menu is open in command mode, `<left>` and `<right>` select
" entries by default. This is a hack to disable that behavior. I hope it does
" not break other things.
cnoremap <left> <space><bs><left>
cnoremap <right> <space><bs><right>

" Don't show mode in command line
set noshowmode

" When writing, show "[w]" instead of "written"
set shortmess+=w

" {{{1 Status line

" I chose to not use any plugins and try to do what I want by myself.

" Function to get the correct highlight
function MyStatuslineHighlightLookup(is_focused, is_weak) abort
  let highlight = a:is_focused ? "StatusLine" : "StatusLineNC"
  if a:is_weak
    let highlight_weak = StrCat(highlight, "Weak")
    if hlexists(highlight_weak)
      let highlight = highlight_weak
    endif
  endif
  return StrCat("%#", highlight, "#")
endfunction

" Creating the status line from a function gives flexibility, e.g. higlighting
" based on focus is easier/more functional.
function MyStatusline() abort
  if exists("g:statusline_winid")
    let is_focused = g:statusline_winid == win_getid(winnr())
  else
    let is_focused = v:true
  endif

  " Truncate from the beginning
  let statusline = '%<'

  " "Weak" text
  let statusline = StrCat(statusline,
  \ MyStatuslineHighlightLookup(is_focused, v:true))

  " Current working directory
  let statusline = StrCat(statusline, '%{pathshorten(getcwd())}/%=')

  " "Strong" text
  let statusline = StrCat(statusline,
  \ MyStatuslineHighlightLookup(is_focused, v:false))

  " Current file
  let statusline = StrCat(statusline, '%f%=')

  " Mode, flags, and filetype
  let statusline = StrCat(statusline, ' [%{mode()}]%m%r%h%w%y ')

  " Cursor position
  let statusline = StrCat(statusline, '%l:%c%V %P')

  return statusline
endfunction

" Use custom status line defined above
set statusline=%!MyStatusline()

" Always put a status line on every window.
set laststatus=2

" {{{1 Numbers and signs columns

" Line Numbering
set number
set relativenumber
set numberwidth=1

" Don't use an additional sign column ("gutter"), place signs on number columns
if v:version >= 900 || has("nvim-0.5") " NOTE: Versions are a guess
  set signcolumn=number
else
  set signcolumn=auto
endif

" {{{1 Colorcolumn

" Have a `colorcolumn` visualization track `textwidth` automatically
"function UpdateColorcolumn()
  "let &colorcolumn = &textwidth + 1
"endfunction
"
"augroup MyOptionUpdaters
  "autocmd OptionSet textwidth call UpdateColorcolumn()
  "autocmd BufWinEnter * call UpdateColorcolumn()
"augroup END

" Turns out that I don't need all this and can just do the following:
set colorcolumn=+1

" {{{1 General keyword highlighting

let s:my_general_keywords = ["TODO", "NOTE", "FIXME", "HACK", "PERF", "WARNING"]

" The out-of-the-box highlighting definitions for these are spread out among
" many language-specific syntax files and thus differ a bit depending on the
" filetype. While it is not trivial to disable them all cleanly to get something
" more unified, I can at least override both the Vim syntax highlighting as well
" as Treesitter-based highlighting with `matchadd`. There are also plugins for
" these sorts of keywords, making them searchable and with signs and all, but I
" think this is a case where native Vim functionality provides enough to
" implement the behavior I want, and hence I would rather just stick with that.

let s:my_general_keywords =
\ map(copy(s:my_general_keywords), 'StrCat(v:val, ":")') + s:my_general_keywords
let s:my_general_keywords_pattern = join(s:my_general_keywords, "\\|")

highlight link MyGeneralKeyword Todo

augroup MyGeneralKeywords
  " NOTE: These autocmd events are suggested on the web for doing this, e.g.
  " here: https://stackoverflow.com/a/11710333
  " I guess they make sense because `matchadd` patterns are bound to windows.
  autocmd WinEnter,VimEnter * :silent! call
  \ matchadd('MyGeneralKeyword', s:my_general_keywords_pattern, -1)
augroup END

" {{{1 Moving lines around

" NOTE: I disabled these for now to see if I can get along with the native Vim
" functionality instead like `<<` etc.

"" TODO: It'd be really nice if these next two blocks of code worked with counts
"" too.
"
"" Moving lines up and down – can of course be done with `dd` and `p` as well,
"" but does not auto-indent that way, with my configuration.
"" TODO: Change all of these to use `<cmd>` so they're silent … however, <cmd> is
"" not supported on old Vim versions, so I may want to maximize compatibilty too.
"nnoremap <c-j> <cmd>move .+1<cr>==
"nnoremap <c-k> <cmd>move .-2<cr>==
"inoremap <c-j> <esc>:move .+1<cr>==gi
"inoremap <c-k> <esc>:move .-2<cr>==gi
"vnoremap <c-j> :move '>+1<cr>gv=gv
"vnoremap <c-k> :move '<-2<cr>gv=gv
"
"" Moving lines left and right, i.e. indent or unindent
"" NOTE: I like the behavior of this more than `<` and `>` in normal mode.
"nnoremap <c-h> a<c-d><esc>
"nnoremap <c-l> a<c-t><esc>
"inoremap <c-h> <c-d>
"inoremap <c-l> <c-t>
"" NOTE: `gv` keeps the lines selected. However, it does not select the exact
"" same content when done like this. I guess that's okay for now.
"vnoremap <c-h> <lt>gv
"" NOTE: I'm using `<char-62>` to target the key `>` because there is no `<gt>`.
"vnoremap <c-l> <char-62>gv

" {{{1 Folding

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

" {{{1 Search, replace
set ignorecase
set smartcase
set incsearch
set hlsearch
" NOTE: `nohlsearch` is different from `set nohlsearch` and furthermore,
" `nohlsearch` has no effect when invoked from an autocommand or user function,
" due to implementation details.
if v:version > 800 " NOTE: Version is a guess
  nnoremap /<cr> <cmd>nohlsearch<cr>
else
  nnoremap <silent> /<cr> :nohlsearch<cr>
endif
nnoremap - :%s///g<left><left><left>
nnoremap _ :%s///g<left><left><left><c-r><c-w><right>

" Search wraps at top and bottom of file
set wrapscan

" {{{1 List mode

" `list` mode to visualize whitespaces, continuing lines, etc.
set list

" `listchars` handling

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
    let &listchars = StrCat(&listchars, name, ':', str, ',')
  endfor
  let &listchars =
  \ StrCat(&listchars, 'leadmultispace:▏', repeat('\x20', shiftwidth() - 1))
endfunction

" Trigger `UpdateListchars` at the appropriate times
augroup MyOptionUpdaters
  autocmd OptionSet shiftwidth call UpdateListchars()
  autocmd BufWinEnter * call UpdateListchars()
augroup END

" {{{1 Mouse and scrolling

" Use arrow keys for scrolling
noremap <up> <c-y>
noremap <down> <c-e>
noremap <left> z<left>
noremap <right> z<right>

" Don't scroll further horizontally than the cursor position (default anyway)
set sidescroll=1

" Use mouse in all modes
set mouse=ar

" Use right-clicking to open a context menu
set mousemodel=popup_setpos

" TODO: Set up the contents of the context menu

" Don't focus whatever window is under the mouse pointer. I chose to set it this
" way because it doesn't seem to work anyway and because the help file says that
" "pull down menus" become "a little goofy" to use when it's on.
set nomousefocus

" Scroll 1 line/column at a time with the mouse
" NOTE: This shouldn't have any effect if the scroll wheel mapping below is
" active
if exists("+mousescroll") | set mousescroll=ver:1,hor:1 | endif

" {{{2 Scroll wheel mapping

" This is a scroll wheel mapping to improve the inertia-based scrolling that is
" classically present on Apple devices. This was necessary on older Neovim
" versions (probably those without the mousescroll option). On newer Neovim
" versions, this whole mapping isn't necessary anymore. For Vim, I don't know
" about older versions right now, but for Vim 9, the standard mouse wheel
" scrolling still scrolls multiple lines at once and it is not obvious how to
" disable this except for doing a mapping. However, Vim 9 has no multi-scroll
" events and appears to trigger the single scroll events less often than
" necessary to produce smooth inertia-based scrolling. In fact, mapping them to
" skip multiple lines doesn't even help, pointing to Vim executing the scrolling
" events too slowly instead of acknowledging too few of them in the first place.
" Turns out that this is an issue of slow redrawing because it improves when I
" disable syntax highlighting. On Neovim, I have seen `lazyredraw` help to some
" extent when scrolling is slow, and for Vim, at least it helps execute a
" mapping faster that sends a single-scroll key combination multiple times.
"
" Here's a corresponding GitHub issue:
" https://github.com/neovim/neovim/issues/6211
"
" NOTE: A multi-scroll event like e.g. `<3-ScrollWheelUp>` doesn't mean "three
" scrolls", but it means "third scroll in a row". That's why it shouldn't be
" mapped to something that moves the buffer by three lines, but one.
"
" NOTE: Mapping the mouse wheel events has one limitation: Inactive windows can
" not be scrolled with the mouse. `mousefocus` might help, but doesn't work on
" my system. Without mouse wheel mapping, scrolling of inactive windows
" even works with `nomousefocus`.
"
" NOTE: I am also mapping left/right mouse wheel events here, though
" unfortunately it seems that iTerm2 does not send these.
"
" NOTE: The sending of arrow keys instead of mouse scrolling events by iTerm2 is
" another way of getting more or less smooth inertia-based scrolling, but
" requires `set mouse=` in (Neo)Vim, which I find unacceptable. This also means
" I can't use it for horizontal mouse scrolling, but as of 2023-07, iTerm2 does
" not send such left/right arrow keys anyway.
"
" NOTE: To get horizontal scrolling anyway, I use Shift as a modifier key to
" swap the scrolling axes. Who knows, maybe I should just map all mouse wheel
" events to `<nop>` and force myself to learn the keyboard way of scrolling…

let s:needs_scroll_wheel_mapping_full =
\ has("nvim") && !has("nvim-0.5") " NOTE: Version is a guess
let s:needs_scroll_wheel_mapping_axis_swap = v:true
let s:scroll_wheel_multiplier_vertical = has("nvim") ? 1 : 3
let s:scroll_wheel_multiplier_horizontal = has("nvim") ? 1 : 3

if s:needs_scroll_wheel_mapping_full || s:needs_scroll_wheel_mapping_axis_swap
  let s:scroll_wheel_lhs_postfixes =
  \ {"u": "Up", "d": "Down", "l": "Left", "r": "Right"}
  let s:axis_swap = {"u": "l", "d": "r", "l": "u", "r": "d"}
  let s:scroll_rhss =
  \ {"u": "<c-y>", "d": "<c-e>", "l": "z<left>", "r": "z<right>"}
  let s:scroll_rhss_insert = {"u": "<c-x><c-y>", "d": "<c-x><c-e>",
  \ "l": "<c-o>z<left>", "r": "<c-o>z<right>"}

  for n in range(1, 4)
    let n_prefix = n == 1 ? "" : StrCat(n, "-")
    for modifier in s:needs_scroll_wheel_mapping_full ? ["", "s", "c"] : ["s"]
      let prefix =
      \ StrCat((modifier == "" ? "" : StrCat(modifier, "-")), n_prefix)
      for mode in ["", "i"]
        for [lhs_direction, postfix] in items(s:scroll_wheel_lhs_postfixes)
          let lhs = StrCat("<", prefix, "ScrollWheel", postfix, ">")
          let rhs_direction = modifier == "s" ? s:axis_swap[lhs_direction] :
          \ lhs_direction
          let rhs = mode == "i" ? s:scroll_rhss_insert[rhs_direction] :
          \ s:scroll_rhss[rhs_direction]
          let scroll_wheel_multiplier =
          \ (rhs_direction == "u" || rhs_direction == "d")
          \ ? s:scroll_wheel_multiplier_vertical
          \ : s:scroll_wheel_multiplier_horizontal
          let rhs = repeat(rhs, scroll_wheel_multiplier)
          "echo (mode == "i" ? "inoremap" : "noremap") lhs rhs
          execute (mode == "i" ? "inoremap" : "noremap") lhs rhs
        endfor
      endfor
    endfor
  endfor
endif

" }}}2

" {{{1 Completion and Tab and Arrow keys behavior

" Maximum height of the popup menu for insert mode completion
set pumheight=6

" Don't show command line messages when using the native completion menu
" NOTE: Some messages may still be output on older Vim versions, e.g.
" `Scanning included file <file>`
set shortmess+=c

" Use the popup menu for completion
set completeopt+=menu

" Show the completion menu even if there is only one match
" (I think this makes a lot of sense as the menu basically shows suggestions –
" why wouldn't I want to see the suggestion just because there is only one?)
set completeopt+=menuone

" When using the completion menu, open the preview window with extra information
" (such as e.g. docstrings)
set completeopt+=preview

" Close the preview window when the completion is considered finished
autocmd CompleteDone * pclose

" TODO: My below code basically depends on `completeopt` having `menu` and
" `menuone` set. Can I make it work even if these are not set?

" NOTE: Using Vimscript here for portability, even though it's slow and will
" end up hooking into Lua most of the time anyway.

" NOTE: There are some subtleties to consider with the code below. One issue is
" that `feedkeys` does not wait for the processing of the sent keys, and thus I
" can not be sure than e.g. `pumvisible()` returns the correct value immediately
" after sending keys to open the menu. Another issue is that opening the menu
" and trying to cycle back to the very last entry with `\<c-p>` through
" `feedkeys` does not seem to work. I suspect this has to do with some kind of
" delay or asynchronicity that happens after opening the menu but before fully
" populating it, but I am not sure.

" NOTE: I chose to let `<tab>` select the first completion menu entry and
" `<s-tab>` open a menu where nothing has been selected. Immediately selecting
" the very last entry is not only hard to implement due to the issues mentioned
" above, but probably not all that useful anyway. Another option may be to
" simply map `<s-tab>` to `<tab>` when `<tab` would open a completion menu
" instead of actually doing a `<tab>`, but I don't see much of a use case here
" either, since I can just press space once and use `<tab>` from there on.

" NOTE: I have thought about several design choices of what to do when `<s-tab>`
" is pressed without text under the cursor.
" * `feedkeys("\<s-tab>", "nt")` isn't very useful because it doesn't do
"   anything different then unmodified tab and cannot be remapped from here
"   anyway.
" * Deleting spaces before the cursor up to the preceding integer multiple of
"   `shiftwidth` or the preceding non-whitespace character would be a
"   possibility, but it's quiet close to what backspace does.
" * So I think I'll go with opening the completion menu, because otherwise there
"   is no way to invoke a completion menu from this function without text under
"   the cursor.

" Defined for consistent naming
function IsNativeCompletionMenuVisible()
  return pumvisible()
endfunction

" Opens the user, omni, or include completion menu, depending on availability
" The first argument can be set to `0`/`v:false` to not select the first item
function OpenNativeCompletionMenu(...) abort
  let keys = "\<c-x>"
  let keys = StrCat(keys, !empty(&completefunc) ? "\<c-u>" :
  \ !empty(&omnifunc) ? "\<c-o>" : "\<c-i>")
  let select_first = get(a:, 1, v:true)
  if &completeopt =~# "noselect"
    if select_first | let keys = StrCat(keys, "\<c-n>") | endif
  else
    if !select_first | let keys = StrCat(keys, "\<c-p>") | endif
  endif
  call feedkeys(keys, "n")
endfunction

function CloseNativeCompletionMenu() abort
  if has("nvim-0.6") || v:version >= 823
    " These should be the correct versions. Before, `<c-x><c-z>` wasn't a
    " feature and `<c-x>` was used to close the menu.
    call feedkeys("\<c-x>\<c-z>", "n")
  else
    call feedkeys("\<c-x>", "n")
  endif
endfunction

" Moves the selection in the completion menu by `offset` items
" Undefined behavior if no completion menu is open
function MoveSelectionInNativeCompletionMenu(offset) abort
  let key = a:offset >= 0 ? "\<c-n>" : "\<c-p>"
  call feedkeys(repeat(key, abs(a:offset)), "n")
endfunction

" Functions to be overridden if and after `cmp` is loaded
function IsCmpCompletionMenuVisible()
  return v:false
endfunction
function OpenCmpCompletionMenu(...) abort
  return
endfunction
function CloseCmpCompletionMenu() abort
  return
endfunction
function MoveSelectionInCmpCompletionMenu(offset) abort
  return
endfunction

function MySymbolSubstitution(...) abort
  return v:false
endfunction

function MyCompletionMenuOpeningCriterion()
  "let current_char = strpart(getline("."), col(".") - 2, 1)
  let current_char = getline(".")[col(".") - 2]
  " TODO: Delete this debugging command at some point in the future, when I'm
  " more certain that this doesn't need more debugging – e.g. although it
  " doesn't seem like it, I wonder whether I should really use something like
  " `getcursorcharpos()`. Maybe depending on `virtualedit`…
  "echo "line: \"" .. getline(".") ..
  "\ "\" col: \"" .. col(".") ..
  "\ "\" char: \"" .. current_char .. "\""
  return current_char != "" && current_char != " " && current_char != "	"
endfunction

function MyInsertModeTabKeyHandler(shift_pressed, is_expr) abort
  let has_cmp = get(g:, "loaded_cmp", 0)
  if has_cmp && IsCmpCompletionMenuVisible()
    call MoveSelectionInCmpCompletionMenu(a:shift_pressed ? -1 : 1)
  elseif IsNativeCompletionMenuVisible()
    call MoveSelectionInNativeCompletionMenu(a:shift_pressed ? -1 : 1)
  else
    if !a:shift_pressed && MySymbolSubstitution(a:is_expr)
      " Symbol was substituted, nothing else to do
    elseif MyCompletionMenuOpeningCriterion() || a:shift_pressed
      if has_cmp
        call OpenCmpCompletionMenu(!a:shift_pressed)
      else
        call OpenNativeCompletionMenu(!a:shift_pressed)
      endif
    else
      call feedkeys("\<tab>", "nt")
    endif
  end
  return "" " For `<expr>` mappings
endfunction

if v:version > 800 " NOTE: Version is a guess
  inoremap   <tab> <cmd>call MyInsertModeTabKeyHandler(v:false, v:false)<cr>
  inoremap <s-tab> <cmd>call MyInsertModeTabKeyHandler( v:true, v:false)<cr>
else
  inoremap <expr>   <tab> MyInsertModeTabKeyHandler(v:false, v:true)
  inoremap <expr> <s-tab> MyInsertModeTabKeyHandler( v:true, v:true)
end

" Close completion menu with arrow keys. This function is meant to be overridden
" depending on features.
function MyInsertModeArrowKeyHandler(key)
  if IsNativeCompletionMenuVisible()
    call CloseNativeCompletionMenu()
  endif
  call feedkeys(a:key, "nt")
  return "" " For `<expr>` mappings
endfunction

if has("nvim-0.8") " NOTE: Version is a guess
  inoremap    <up> <cmd>call MyInsertModeArrowKeyHandler(   "\<up>")<cr>
  inoremap  <down> <cmd>call MyInsertModeArrowKeyHandler( "\<down>")<cr>
  inoremap  <left> <cmd>call MyInsertModeArrowKeyHandler( "\<left>")<cr>
  inoremap <right> <cmd>call MyInsertModeArrowKeyHandler("\<right>")<cr>
elseif v:version > 800 " NOTE: Version is a guess
  " Escaping workaround, see
  " https://vi.stackexchange.com/questions/33144/inserting-strings-with-plug-
  " inside-cmd
  inoremap    <up> <cmd>call
  \ MyInsertModeArrowKeyHandler(   "<bslash><lt>up>")<cr>
  inoremap  <down> <cmd>call
  \ MyInsertModeArrowKeyHandler( "<bslash><lt>down>")<cr>
  inoremap  <left> <cmd>call
  \ MyInsertModeArrowKeyHandler( "<bslash><lt>left>")<cr>
  inoremap <right> <cmd>call
  \ MyInsertModeArrowKeyHandler("<bslash><lt>right>")<cr>
else
  inoremap <expr>    <up> MyInsertModeArrowKeyHandler(   "\<up>")
  inoremap <expr>  <down> MyInsertModeArrowKeyHandler( "\<down>")
  inoremap <expr>  <left> MyInsertModeArrowKeyHandler( "\<left>")
  inoremap <expr> <right> MyInsertModeArrowKeyHandler("\<right>")
endif

" {{{1 Startup working directory

" On startup, try to find a project root directory to change to. I think this is
" useful because some functionality like e.g. Telescope's Live Grep uses the
" current working directory as default reference point.

" Don't automatically change the working directory when opening/switching
" files/buffers/windows etc.
set noautochdir

" As there is some asynchronicity involved here, use this global variable to
" make sure the project root directory change happens only once for git (level
" 1) and once for LSP (level 2, taking precedence over the git root).
let g:my_cd_project_root_completion_level = 0

" Handling for asynchronous git root finding
let g:my_cd_project_root_git_stdout_buffer = ""

function TryCdProjectRootNeovimGitHandler(job_id, data, event)
  let level = 1
  if a:event == "stdout"
    let g:my_cd_project_root_git_stdout_buffer = join(
    \ [g:my_cd_project_root_git_stdout_buffer] + a:data, "")
  elseif a:event == "exit"
    if g:my_cd_project_root_completion_level < level &&
      \ !a:data && isdirectory(g:my_cd_project_root_git_stdout_buffer)
      execute "cd" g:my_cd_project_root_git_stdout_buffer
      let g:my_cd_project_root_completion_level = level
    endif
  endif
endfunction

function TryCdProjectRootVimGitHandler(channel)
  let level = 1
  while ch_status(a:channel, {'part': 'out'}) == 'buffered'
    let g:my_cd_project_root_git_stdout_buffer = StrCat(
    \ g:my_cd_project_root_git_stdout_buffer, ch_read(a:channel))
  endwhile
  if g:my_cd_project_root_completion_level < level &&
    \ isdirectory(g:my_cd_project_root_git_stdout_buffer)
    execute "cd" g:my_cd_project_root_git_stdout_buffer
    let g:my_cd_project_root_completion_level = level
  endif
endfunction

" Called with a `level` argument, attempt to complete the project root directory
" change level if it has not happened already. Called without arguments, reset
" the level and re-try all levels. (A "level" basically being one method of
" finding a project root directory with a certain precedence). If there still
" are LSP workspace folders (`echo v:lua.vim.lsp.buf.list_workspace_folders()`)
" from previous buffers, they will dictate the result.
function TryCdProjectRoot(...) abort
  if !exists("a:1")
    let g:my_cd_project_root_completion_level = 0
    for level in range(2, 1, -1)
      call TryCdProjectRoot(level)
    endfor
    return
  endif

  if g:my_cd_project_root_completion_level >= a:1 | return | endif
  let project_root = ""

  if a:1 == 1 && executable("git")
    " Use directory of current file as starting point, if available
    let working_dir = getcwd()
    let working_buf = bufname()
    if !empty(working_buf)
      let buf_dir = fnamemodify(resolve(working_buf), ":h")
      if isdirectory(buf_dir)
        let working_dir = buf_dir
      endif
    endif

    " Empty the buffer before a new Git job is started
    let g:my_cd_project_root_git_stdout_buffer = ""

    " Call git via jobs if possible
    if exists("*jobstart")
      call jobstart(["git", "rev-parse", "--show-toplevel"],
      \ {"on_stdout": function("TryCdProjectRootNeovimGitHandler"),
      \  "on_exit":   function("TryCdProjectRootNeovimGitHandler"),
      \  "cwd": working_dir})
    elseif has("job") && has("channel") && exists("*job_start") &&
      \ exists("*ch_status") && exists("*ch_read")
      let job = job_start(["git", "rev-parse", "--show-toplevel"],
      \ {"in_io": "null", "close_cb": "TryCdProjectRootVimGitHandler",
      \  "cwd": working_dir})
    else
      " NOTE: Using a list instead of a string avoids invocation through the
      " shell, but is not supported on older Vim versions.
      let git_roots = systemlist(
      \ StrCat("cd \"", working_dir, "\" && git rev-parse --show-toplevel"))
      if !v:shell_error
        for git_root in git_roots
          if isdirectory(git_root)
            let project_root = git_root
          endif
        endfor
      endif
    endif
  endif

  if a:1 == 2 && has("nvim-0.5.0")
    " The last folder in this list tends to correspond to whetever file was
    " opened last.
    let workspace_folders = v:lua.vim.lsp.buf.list_workspace_folders()
    if !empty(workspace_folders)
      let project_root = workspace_folders[-1]
    endif
  endif

  if !empty(project_root) && g:my_cd_project_root_completion_level < a:1
    execute "cd" project_root
    let g:my_cd_project_root_completion_level = a:1
  endif
endfunction

augroup MyCdProjectRoot
  autocmd VimEnter * call TryCdProjectRoot(1)
  if exists("##LspAttach")
    autocmd LspAttach * call TryCdProjectRoot(2)
  endif
augroup END

