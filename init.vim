" `init.vim` or '`.vimrc`' file thrown together by me.

" (the following line is a modeline)
" vim: foldmethod=marker

" {{{1 General notes and todos

" TODO: This looks interesting: https://github.com/nathom/filetype.nvim
"
" TODO: Have individual files for specific file types? E.g. set conceallevel and
" shiftwidth for `filetype`s such as JSON, Python, TeX, …, instead of in here.
" This may come in handy:
" https://vi.stackexchange.com/questions/14371/why-files-in-config-nvim-after-ftplugin-are-not-taken-into-acount
"
" TODO: Add either a thesaurus file or a thesaurus function for the english
" language? (See `:h compl-thesaurus`)
"
" TODO: Make these `TODO` and `NOTE` admonitions be highlighted consistently
"
" NOTE: There are many claims that netrw is a bad and buggy piece of software
" and should probably be rewritten entirely. However, it does more than just
" being a file browser, which is why it's not a good idea to fully disable it.
" However, replacing the file browsing part with another plugin makes sense.
" The situation with netrw is unfortunate. On the one hand, it would be more
" unix-y to separate the text editor and the file browser into two loosely
" coupled standalone programs. On the other hand, given that this thing already
" exists, it would be nice to make use of it as a vanilla part of Vim. Still, I
" think the best solution for now is to just ignore it and hope that it gets
" deprecated in favor of a better solution or something.
"
" NOTE: User-defined Vimscript functions are usually named in CamelCase to avoid
" confusion with built-in functions.

" NOTE: There is an issue with syntax highlighting that I may encounter for a
" while when editing this file. Specifically, lua code blocks may show closing
" parentheses as erroneous when in fact they aren't and this may also break the
" syntax highlighting underneath…
" See https://github.com/neovim/neovim/issues/20456
" Treesitter does a better job, so I'll manually enable it here for now
if has("nvim-0.5")
  augroup MyVimscriptLuaHighlightWorkaround
    autocmd FileType vim lua vim.treesitter.start()
  augroup END
endif

" {{{1 Essential initializations

" Helper function to convert any value to `v:false`/`v:true`
function s:AsBool(value)
  if a:value | return v:true | else | return v:false | endif
endfunction

" This is always set in Neovim, but doesn't hurt to set it explicitly.
" It resets some other options in Vim, which is why it should be set early
set nocompatible

" POSIX compliance needed
set shell=/bin/sh

" In Vimscript, `.` gets deprecated in favor of `..`. See `:h expr-..`.
" And this also goes for assignment, i.e. `..=` instead of `.=`.
" However, really old versions only support the single dot. This is unfortunate
" as I want (or need) to retain compatibility. Thus, let's do it with this
" function.
if v:version > 800 " NOTE: Version is a guess
  function s:StrCat(x, ...)
    let str = a:x | for x in a:000 | let str ..= x | endfor | return str
  endfunction
else
  function s:StrCat(x, ...)
    let str = a:x | for x in a:000 | let str .= x | endfor | return str
  endfunction
endif

" Neovim providers
if has("nvim")
  " Set the location of the Python 3 binary. `provider.txt` says setting this
  " makes startup faster, but I haven't tested it.
  " NOTE: Python 3 needs the `pynvim` package installed.
  let s:python3_host_prog_dict = {
  \   "lasse-mbp-0": "/usr/local/bin/python3",
  \   "lasse-mba-0": "/usr/local/bin/python3",
  \   "lasse-alpine-env-0": "/usr/bin/python3"
  \ }
  if has_key(s:python3_host_prog_dict, hostname())
    let g:python3_host_prog = s:python3_host_prog_dict[hostname()]
  endif

  " Explicitly disable some (unneeded?) providers.
  let g:loaded_python_provider = 0
  "let g:loaded_python3_provider = 0
  let g:loaded_ruby_provider = 0
  let g:loaded_node_provider = 0
  let g:loaded_perl_provider = 0

  " Use CPCP for clipboard handling if available
  for cmd in
  \   [expand("$HOME/.config/cross-platform-copy-paste/cpcp.sh"),
  \     "cpcp",
  \     "cpcp.sh"]
    if executable(cmd)
      let s:cpcp_command = cmd
      break
    end
  endfor

  " The commands in the dictionary below can be written as lists of individual
  " arguments in newer versions of Neovim, but I'll keep it this way for
  " legacy compatibility reasons.
  if exists("s:cpcp_command")
    let s:cpcp_clipboard = {
    \   "name": "CPCPClipboard",
    \   "copy": {
    \      "+": s:StrCat(s:cpcp_command, " --base64=auto"),
    \      "*": s:StrCat(s:cpcp_command, " --base64=auto"),
    \    },
    \   "paste": {
    \      "+": s:StrCat(s:cpcp_command, " --base64=auto paste"),
    \      "*": s:StrCat(s:cpcp_command, " --base64=auto paste"),
    \   },
    \   "cache_enabled": 1,
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

" This will usually be turned on by default and may lead to problems if not.
" I don't see why I would disable this except maybe on a very resource-limited
" system, at which point the choice of using (Neo-)Vim may be questionable
" anyway.
filetype plugin indent on
syntax enable

" Set up a namespace for my user-defined functions in Lua
if has("nvim")
  lua my = {}
endif

" {{{1 Features and plugins

" * To check for platforms or features, use `has`
"   * e.g. to find out if it's Neovim, run `has('nvim')`
" * Vim version resides in variable `v:version`
"   * Neovim version lower bound can be checked with e.g. `has("nvim-0.8")`
" * `hostname()` returns the hostname.
" * `exists("+foo")` to check if an option exists (see `:h hidden-options`)
" * `exists("x:foo")` to check if a variable exists
" * `executable("foo")` to check if a shell command exists

" Here's a helper function to check from Vimscript if Lua has JIT compilation
if has("nvim")
lua << EOF
  function my.has_jit()
    return jit ~= nil
  end
EOF
endif

" NOTE: The two dictionaries below can't be accessed from Lua if they are
" script-local. Having them be global also allows to check their status after
" startup, so maybe it's the better choice anyway.

" Feature list: used to enable/disable sections of this file
" Values should be numbers, not `v:true`/`v:false`
let g:my_features = {
\ "plugin_management": has("nvim-0.8") && v:lua.my.has_jit(),
\ "automatic_background_handling": has("nvim"),
\ "my_dim_colorscheme": 1,
\ "basic_editor_setup": 1,
\ "native_filetype_plugins_config": 1,
\ "nerdcommenter": 1,
\ "vim_commentary": 0,
\ "vim_surround": 1,
\ "vim_repeat": 1,
\ "vimtex": 1,
\ "julia_vim": executable("julia"),
\ "vim_asciidoc_folding": 1,
\ "nvim_treesitter": has("nvim-0.9"),
\ "nvim_lspconfig": has("nvim-0.8"),
\ "nvim_cmp": has("nvim-0.7"),
\ "autocompletion": 1,
\ "telescope": has("nvim-0.9"),
\ "luasnip": has("nvim-0.5")}

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
\ "vim_surround": {
\   "name": "vim-surround",
\   "author": "tpope",
\   "options": {}},
\ "vim_repeat": {
\   "name": "vim-repeat",
\   "author": "tpope",
\   "options": {}},
\ "vimtex": {
\   "name": "vimtex",
\   "author": "lervag",
\   "options": {}},
\ "julia_vim": {
\   "name": "julia-vim",
\   "author": "JuliaEditorSupport",
\   "options": {"lazy": v:true, "event": "FileType julia"}},
\ "vim_asciidoc_folding": {
\   "name": "vim-asciidoc-folding",
\   "author": "matcatc",
\   "options": {}},
\ "nvim_treesitter": {
\   "name": "nvim-treesitter",
\   "author": "nvim-treesitter",
\   "options": {"build": ":TSUpdate"}},
\ "nvim_lspconfig": {
\   "name": "nvim-lspconfig",
\   "author": "neovim",
\   "options": {"event": ["BufReadPre", "BufNewFile"]}},
\ "nvim_cmp": {
\   "name": "nvim-cmp",
\   "author": "hrsh7th",
\   "options": {
\     "dependencies": [
\       {"name": "cmp-buffer", "author": "hrsh7th"},
\       {"name": "cmp-nvim-lsp", "author": "hrsh7th", "options": {
\         "enabled": s:AsBool(g:my_features["nvim_lspconfig"])}},
\       {"name": "cmp_luasnip", "author": "saadparwaiz1", "options": {
\         "enabled": s:AsBool(g:my_features["luasnip"])}}]}},
\ "telescope": {
\   "name": "telescope.nvim",
\   "author": "nvim-telescope",
\   "options": {
\     "branch": "0.1.x",
\     "dependencies": [
\       {"name": "plenary.nvim", "author": "nvim-lua"},
\       {"name": "telescope-luasnip.nvim", "author": "benfowler", "options": {
\         "enabled": s:AsBool(g:my_features["luasnip"])}}]}},
\ "luasnip": {
\   "name": "LuaSnip",
\   "author": "L3MON4D3",
\   "options": {
\     "version": "1.*",
\     "dependencies": [
\       {"name": "friendly-snippets", "author": "rafamadriz"}]}}
\ } " Separated this `}` to not unintentionally create a fold marker

" Notes about features/plugins:
"
" Regarding `tpope/vim-commentary` vs. `preservim/nerdcommenter`:
" `vim-commentary` is a nice plugin insofar as it's very small and leverages a
" bunch of vanilla Vim functionality, including operators/motions. Seems to me
" like it does exactly what needs to be done, exactly how it needs to be done,
" without a lot of bells and whistles. `nerdcommenter` has more configurable
" behavior, e.g. how to handle empty lines, whether to comment small pieces
" instead of whole lines out if possible, etc. Seems like both plugins are very
" stable and here to stay, as of 2023-06.
"
" `lervag/vimtex`: Should not be lazily loaded because the plugin basically
" handles that by itself already through filetype/autoload.
" There is a language server for TeX called TexLab, but it seems to me like
" `vimtex` is very mature, Vim-tailored, and full-fledged, providing a bunch of
" stuff that the language server does not or can not, while the latter does not
" add a whole lot more.
"
" `JuliaEditorSupport/julia-vim`: This plugin, as of 2023-06, does two things:
" LaTeX-to-unicode substitutions and block-wise movements with `matchit`. It is
" not a syntax or indentation plugin, as these are already included with Vim.
" It seems to me that the block-wise movements work without the plugin too, not
" sure why, but if I explicitly disable them for the plugin they don't work
" anymore. Since this plugin adds like 30ms startup time, I lazy load it if
" possible. For some reason it doesn't work with `lazy.nvim`s `ft` option, but
" with `event = "FileType julia"` it's fine. Maybe I should see if there's some
" other LaTeX-to-unicode plugin that's better than this one and always
" available, as that's really the only functionality I seem to need from this.
"
" `matcatc/vim-asciidoc-folding`: As of 2023-06, it seems that Neovim (though
" not Vim) comes with an AsciiDoc syntax file, but there's no support for folds.
" This plugin provides an `ftplugin`-based script with a fold expression. Seems
" like LSP support for AsciiDoc is something that's been planned but not made a
" reality yet. Treesitter support is also something that can be found as a
" non-checked todo in GitHub issues.
"
" `neovim/nvim-lspconfig`: I think, at least for now, that it makes sense to tie
" the list of configured LSP servers together with the plugin and not to create
" separation of the LSP server list and LSP plugins. So right now, the feature
" `nvim_lspconfig` basically means "the plugin together with its list of
" configured LSP servers".
" The lazy loading events were inspired from here: https://github.com/LazyVim/
" LazyVim/blob/86ac9989ea15b7a69bb2bdf719a9a809db5ce526/lua/lazyvim/plugins/lsp/
" init.lua#L5 Does lazy loading it this way really improve anything, though?
"
" `L3MON4D3/LuaSnip`: There is this optional post-install/-update step `make
" install_jsregexp` which I have omitted for now, but may want to look into at
" some point.

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

  -- Function to transform vim.g.my_plugins into a Lazy plugin spec
  local function to_spec(plugin, feature)
    local spec = {string.format("%s/%s", plugin.author, plugin.name)}
    if feature ~= nil then
      spec["enabled"] = vim.g.my_features[feature] ~= 0
    end
    if plugin.options ~= nil then
      for key, value in pairs(plugin.options) do
        spec[key] = value
      end
      if plugin.options.dependencies ~= nil then
        spec.dependencies = {}
        for i, dependency in ipairs(plugin.options.dependencies) do
          table.insert(spec.dependencies, to_spec(dependency))
        end
      end
    end
    return spec
  end

  -- Construct plugin spec, disable based on feature switches
  -- NOTE: I had a hard time finding a neater way of constructing tables than
  -- consecutive assignments or `insert` calls.
  local plugins = {}
  for feature, plugin in pairs(vim.g.my_plugins) do
    table.insert(plugins, to_spec(plugin, feature))
  end

  -- Options
  local opts = nil -- nothing for now

  -- Run `lazy.nvim`
  require("lazy").setup(plugins, opts)
EOF
else " has("nvim")
  echo "Plugin management requested for non-neovim: \
    I don't have one set up in init.vim"
endif

else " g:my_features["plugin_management"] {{{1

  " Let's add putative plugin locations, as these can still be used without
  " plugin management.

  let s:config_dir = has("nvim-0.3") ? stdpath("config") :
  \ has("nvim") ? (
  \   has("win32") || has("win64") ? expand("$HOME/AppData/Local/nvim") :
  \   expand("$HOME/.config/nvim")) : (
  \   has("win32") || has("win64") ? expand("$HOME/vimfiles") :
  \   expand("$HOME/.vim"))

  let s:my_plugins_dir_basename = "plugins"
  let s:my_plugins_dir =
  \ s:StrCat(s:config_dir, "/", s:my_plugins_dir_basename, "/")

  let s:plugin_root_dirs = [
  \ s:my_plugins_dir,
  \ expand("$HOME/.local/share/nvim/lazy/")]

  let s:plugin_root_dirs = filter(s:plugin_root_dirs, "isdirectory(v:val)")

  function s:AddPluginDirIfExists(plugin)
    if has_key(a:plugin, "options") &&
\       has_key(a:plugin["options"], "dependencies")
      for dependency in a:plugin["options"]["dependencies"]
        call s:AddPluginDirIfExists(dependency)
      endfor
    endif

    for plugin_root_dir in s:plugin_root_dirs
      let plugin_dir = s:StrCat(plugin_root_dir, a:plugin["name"])
      if isdirectory(plugin_dir)
        let &runtimepath = s:StrCat(&runtimepath, ",", plugin_dir)
        break
      endif
    endfor
  endfunction

  for [feature, plugin] in items(g:my_plugins)
    if g:my_features[feature] &&
      \ (!has_key(plugin, "options") ||
        \ !has_key(plugin["options"], "enabled") ||
        \ plugin["options"]["enabled"])
      call s:AddPluginDirIfExists(plugin)
    endif
  endfor

  " And let's furthermore write functions to do basic plugin pulls and removals
  " NOTE: We could leverage `packadd` here, but since this section is kind of
  " about legacy support, I think it makes more sense to avoid the native
  " package support and rely on the above `runtimepath`-modifying code here.

  function MyNativeSinglePluginInstall(plugin)
    let name = s:StrCat(a:plugin["author"], "/", a:plugin["name"])
    if (has_key(a:plugin, "options") &&
      \ has_key(a:plugin["options"], "enabled") &&
      \ !a:plugin["options"]["enabled"])
      echo s:StrCat("Plugin `", name, "` is disabled.")
      return
    endif

    if (has_key(a:plugin, "options") &&
      \ has_key(a:plugin["options"], "dependencies"))
      for dependency in a:plugin["options"]["dependencies"]
        call MyNativeSinglePluginInstall(dependency)
      endfor
    endif

    let path = s:StrCat(s:my_plugins_dir, a:plugin["name"])
    if isdirectory(path)
      echo s:StrCat("Plugin `", name, "` already exists.")
      return
    endif

    let command = "git clone"
    if (has_key(a:plugin, "options") && has_key(a:plugin["options"], "branch"))
      let command =
      \ s:StrCat(command, " --branch ", a:plugin["options"]["branch"])
    endif
    let command = s:StrCat(command, " https://github.com/", name, ".git")
    let command = s:StrCat(command, " ", path)
    echo system(command)
    "echo s:StrCat("Plugin `", name, "` git-cloned.")
    if (has_key(a:plugin, "options") && has_key(a:plugin["options"], "build"))
      echo s:StrCat("  NOTE: Build command has to be run manually: `",
      \ a:plugin["options"]["build"], "`")
    endif
  endfunction

  function MyNativePluginInstall()
    if !isdirectory(s:my_plugins_dir)
      call mkdir(s:my_plugins_dir, "p")
    endif
    for [feature, plugin] in items(g:my_plugins)
      if g:my_features[feature]
        call MyNativeSinglePluginInstall(plugin)
      endif
    endfor
    echo s:StrCat("`", s:my_plugins_dir, "` populated.")
  endfunction

  function MyNativePluginRemove()
    if isdirectory(s:my_plugins_dir)
      call delete(s:my_plugins_dir, "rf")
    endif
    echo s:StrCat("`", s:my_plugins_dir, "` deleted.")
  endfunction

  function MyNativePluginUpdate()
    call MyNativePluginRemove()
    call MyNativePluginInstall()
  endfunction

endif " g:my_features["plugin_management"]

if g:my_features["automatic_background_handling"] " {{{1

" NOTE: As a summary for the below notes: Getting iTerm2, tmux and Neovim (and
" possibly also other terminals and SSH/Mosh) to play nicely together so that
" the `background` option is always synchronized automatically is something
" people are definitely working on here and there, but it seems like the state
" of things is not quite ideal at the moment. I'll try to cover some reasonable
" cases but may have to set `background` manually in some instances.
" NOTE: Setting `background` should be done automatically by Neovim. This seems
" to depend on some `autocmd`, so deleting all autocommands in the beginning of
" the `.vimrc` file (like some do) breaks it. The detection uses an OSC11 escape
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
  if has("nvim-0.7")
    " NOTE: the `++nested` is needed to re-apply the color scheme in response
    " to the `background` option's value changing
    autocmd Signal SIGWINCH ++nested call AttemptBackgroundDetect()
  endif

  "" These are a sad workaround because SIGWINCH doesn't seem to work for me
  "autocmd CursorHold * ++nested call AttemptBackgroundDetect()
  "autocmd CursorHoldI * ++nested call AttemptBackgroundDetect()
augroup END

endif " g:my_features["automatic_background_handling"]

if g:my_features["my_dim_colorscheme"] " {{{1

" Use colorscheme `dim` to inherit terminal colors and extend/modify it a bit
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
function! MyDimModifications() abort
  " Use `cterm` and not `gui` highlights (default, but set explicitly anyway)
  set notermguicolors

  highlight Folded                       ctermfg=NONE ctermbg=NONE cterm=bold
  highlight StatusLine                   ctermfg=NONE ctermbg=NONE cterm=inverse
  highlight Error                        ctermfg=9    ctermbg=NONE
  highlight Todo                         ctermfg=11   ctermbg=NONE
  highlight PmenuThumb                                ctermbg=NONE cterm=inverse

  " For my color scheme family, shades of "grayed-out-ness" work as follows:
  " Color                bg=dark bg=light
  " Grayed out           0       7
  " More grayed out      8       15
  " Foreground, deepened 15      8
  " Foreground, extreme  7       0

  if &background == "light"
    highlight Comment                    ctermfg=7
    highlight LineNr                     ctermfg=15
    highlight CursorLineNr               ctermfg=7
    highlight SignColumn                 ctermfg=15   ctermbg=NONE
    highlight Whitespace                 ctermfg=15
    highlight NonText                    ctermfg=15
    highlight ColorColumn                ctermfg=8    ctermbg=15
    highlight StatusLineNC               ctermfg=7    ctermbg=NONE cterm=inverse
    highlight StatusLineWeak             ctermfg=NONE ctermbg=7    cterm=inverse
    highlight StatusLineNCWeak           ctermfg=7    ctermbg=15   cterm=inverse
    highlight Pmenu                      ctermfg=NONE ctermbg=15
    highlight PmenuSel                   ctermfg=NONE ctermbg=15   cterm=inverse
    highlight PmenuSbar                               ctermbg=7
  else
    highlight Comment                    ctermfg=0
    highlight LineNr                     ctermfg=8
    highlight CursorLineNr               ctermfg=0
    highlight SignColumn                 ctermfg=8    ctermbg=NONE
    highlight Whitespace                 ctermfg=8
    highlight NonText                    ctermfg=8
    highlight ColorColumn                ctermfg=15   ctermbg=8
    highlight StatusLineNC               ctermfg=0    ctermbg=NONE cterm=inverse
    highlight StatusLineWeak             ctermfg=NONE ctermbg=0    cterm=inverse
    highlight StatusLineNCWeak           ctermfg=0    ctermbg=8    cterm=inverse
    highlight Pmenu                      ctermfg=NONE ctermbg=8
    highlight PmenuSel                   ctermfg=NONE ctermbg=8    cterm=inverse
    highlight PmenuSbar                               ctermbg=0
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

endif " g:my_features["my_dim_colorscheme"]

if g:my_features["basic_editor_setup"] " {{{1
" {{{2 Miscellaneous

" Use quoteplus register for clipboard
set clipboard+=unnamedplus

" Long lines continue left and right instead of wrapping
set nowrap

" Make some left/right-movements wrap to the previous/next line
set whichwrap+=<,>,h,l,[,],~

"set lazyredraw " Disabled this on 2023-04-25 to try and see if some occasional
                " glitches would disapper

" Highlight the line the cursor is on
set cursorline

" Bracket pairs matched by `%`
set matchpairs=(:),{:},[:],<:>

" Reduce key code delays
set ttimeoutlen=20

" By default, don't conceal
set conceallevel=0

" {{{2 Text format defaults (indenting, maximum width)

" I want this in most cases, therefore let's set it globally. Filetype scripts,
" modelines, etc. can be used to change it when needed.
" For reformatting, use `gq` or `gw`. `:help gq` and `:help gw` might help.
set textwidth=80

" Use spaces as tabs and indent with a width of 2 by default
set expandtab
set shiftwidth=2
set tabstop=2

" {{{2 File and buffer switching

" This allows basic fuzzy finding with vanilla Vim
set path+=**

" Fuzzy find with meta-/
" The idea being that I map the native fuzzy finder `:find` here, but can
" override this mapping when a fuzzy finding plugin is enabled
nnoremap <m-/> :call feedkeys(":find \<c-i>\<c-p>", "t")

" Switch to alternate file with backspace
nnoremap <bs> <c-^>

" {{{2 Netrw

" Show a tree-style listing in netrw browser by default
let g:netrw_liststyle=3

" {{{2 Command line

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

" {{{2 Status line

" I chose to not use any plugins and try to do what I want by myself.

" Function to get the correct highlight
function MyStatuslineHighlightLookup(is_focused, type) abort
  let l:highlight = "%#"
  let l:highlight =
  \ s:StrCat(l:highlight, a:is_focused ? "StatusLine" : "StatusLineNC")
  if a:type == "weak"
    let l:highlight_weak = s:StrCat(l:highlight, "Weak")
    if hlexists(l:highlight_weak)
      let l:highlight = l:highlight_weak
    endif
  endif
  let l:highlight = s:StrCat(l:highlight, "#")
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

  let l:statusline = "" " Initialize
  let l:statusline = s:StrCat(l:statusline,
  \ '%<') " Truncate from the beginning
  let l:statusline = s:StrCat(l:statusline,
  \ MyStatuslineHighlightLookup(l:is_focused, 'weak'))
  let l:statusline = s:StrCat(l:statusline,
  \ '%{pathshorten(getcwd())}/%=') " Current working directory
  let l:statusline = s:StrCat(l:statusline,
  \ MyStatuslineHighlightLookup(l:is_focused, 'strong'))
  let l:statusline = s:StrCat(l:statusline,
  \ '%f%=') " Current file
  let l:statusline = s:StrCat(l:statusline,
  \ ' [%{mode()}]%m%r%h%w%y ') " Mode, flags, and filetype
  let l:statusline = s:StrCat(l:statusline,
  \ '%l:%c%V %P') " Cursor position

  return statusline
endfunction

" Use custom status line defined above
set statusline=%!MyStatusline()

" Always put a status line on every window.
set laststatus=2

" {{{2 Numbers and signs columns

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

" {{{2 Colorcolumn

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

" {{{2 Moving lines around

" TODO: It'd be really nice if these next two blocks of code worked with counts
" too.

" Moving lines up and down – can of course be done with `dd` and `p` as well,
" but does not auto-indent that way, with my configuration.
" TODO: Change all of these to use `<cmd>` so they're silent
nnoremap <c-j> <cmd>move .+1<cr>==
nnoremap <c-k> <cmd>move .-2<cr>==
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

" {{{2 Folding

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

" {{{2 Search, replace
set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap /<cr> <cmd>nohlsearch<cr>
nnoremap - :%s///g<left><left><left>
nnoremap _ :%s///g<left><left><left><c-r><c-w><right>

" Search wraps at top and bottom of file
set wrapscan

" {{{2 List mode

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
    let &listchars = s:StrCat(&listchars, name, ':', str, ',')
  endfor
  let &listchars =
  \ s:StrCat(&listchars, 'leadmultispace:▏', repeat('\x20', shiftwidth() - 1))
endfunction

" Trigger `UpdateListchars` at the appropriate times
augroup MyOptionUpdaters
  autocmd OptionSet shiftwidth call UpdateListchars()
  autocmd BufWinEnter * call UpdateListchars()
augroup END

" {{{2 Mouse and scrolling

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

" TODO: It seems like horizontal scrolling events don't make it into the
" terminal. Check if this is the case and if there is a way to get horizontal
" scrolling working. Alternatively, use shift key or something.

" {{{3 Scroll wheel mapping

" TODO: I think this isn't necessary anymore for Neovim, maybe for Vim. Think
" about disabling this or perhaps create a "handler" function here as well…

" Weird looking scroll wheel mapping.
" Here's a corresponding GitHub issue:
" https://github.com/neovim/neovim/issues/6211
" NOTE: This has one limitation: Inactive windows can not be scrolled with the
" mouse. `mousefocus` might help, but doesn't work on my system. Without this
" scroll wheel mapping, scrolling of inactive windows even works with
" `nomousefocus`.
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
" }}}3

" {{{2 Completion and Tab and Arrow keys behavior

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
  let keys = s:StrCat(keys, !empty(&completefunc) ? "\<c-u>" :
  \ !empty(&omnifunc) ? "\<c-o>" : "\<c-i>")
  let select_first = get(a:, 1, v:true)
  if &completeopt =~# "noselect"
    if select_first | let keys = s:StrCat(keys, "\<c-n>") | endif
  else
    if !select_first | let keys = s:StrCat(keys, "\<c-p>") | endif
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

function MyCompletionMenuOpeningCriterion()
  let current_char = strpart(getline("."), col(".") - 2, 1)
  " TODO: Delete this debugging command at some point in the future, when I'm
  " more certain that this doesn't need more debugging – e.g. although it
  " doesn't seem like it, I wonder whether I should really use something like
  " `getcursorcharpos()`. Maybe depending on `virtualedit`…
  "echo "line: \"" .. getline(".") ..
  "\ "\" col: \"" .. col(".") ..
  "\ "\" char: \"" .. current_char .. "\""
  return current_char != "" && current_char != " " && current_char != "	"
endfunction

function MyInsertModeTabKeyHandler(shift_pressed) abort
  let has_cmp = get(g:, "loaded_cmp", 0)
  if has_cmp && IsCmpCompletionMenuVisible()
    call MoveSelectionInCmpCompletionMenu(a:shift_pressed ? -1 : 1)
  elseif IsNativeCompletionMenuVisible()
    call MoveSelectionInNativeCompletionMenu(a:shift_pressed ? -1 : 1)
  else
    if MyCompletionMenuOpeningCriterion() || a:shift_pressed
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
  inoremap   <tab> <cmd>call MyInsertModeTabKeyHandler(v:false)<cr>
  inoremap <s-tab> <cmd>call MyInsertModeTabKeyHandler( v:true)<cr>
else
  inoremap <expr>   <tab> MyInsertModeTabKeyHandler(v:false)
  inoremap <expr> <s-tab> MyInsertModeTabKeyHandler( v:true)
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

endif " g:my_features["basic_editor_setup"]

if g:my_features["native_filetype_plugins_config"] " {{{1

" The filetype plugins included with (Neo-)Vim have configuration options.
" This section configures some of them.

" TeX {{{2
" Default TeX flavor
let g:tex_flavor = "latex"

" Disable concealing
let g:tex_conceal = ""

" Python {{{2
" `shiftwidth` and others would otherwise be set to PEP8-conforming values
let g:python_recommended_style = 0

" Julia {{{2
" Don't have the shiftwidth be set to 4
let g:julia_set_indentation = 0

" Don't highlight operators
let g:julia_highlight_operators = 0

" }}}2

endif " g:my_features["native_filetype_plugins_config"]

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

if g:my_features["vim_asciidoc_folding"] " {{{1

" It "may" be necessary to do this, but it looks to me like `foldmethod` is
" `expr` already when opening an AsciiDoc file.
"autocmd FileType asciidoc setlocal foldmethod=expr

endif " g:my_features["vim_asciidoc_folding"]

if g:my_features["nvim_treesitter"] " {{{1

lua << EOF
require("nvim-treesitter.configs").setup{
  ensure_installed = {"c", "lua", "vim", "vimdoc", "query"},
  auto_install = vim.fn.executable("tree-sitter") ~= 0
}
EOF

endif " g:my_features["nvim_treesitter"]

if g:my_features["nvim_lspconfig"] " {{{1

lua << EOF
-- If the language server is not available/runnable, the plugin should output
-- a message and otherwise essentially disable itself, I believe.

-- Julia `LanguageServer.jl`
-- As of 2023-06, `nvim-lspconfig` uses a default server command that first
-- looks in `~/.julia/environments/nvim-lspconfig`, and if it doesn't exist or
-- `LanguageServer.jl` isn't installed there, it uses the default environment
-- instead.
-- It then searches in a couple ways of descending priority for a Julia
-- project to attach to.
-- I could implement automatic installation of the `LanguageServer.jl` package
-- here, but I feel like that's the kind of step I'd rather have control over,
-- even if it means some extra setup.
-- As is typical for Julia, it kind of takes a while to start up. I wonder if
-- something can be done about that.
-- I wonder whether this language server always just assumes that any Julia
-- code it gets to see has the same version as the Julia process running the
-- server or whether it actually respects a project's Julia version as
-- specified in `Manifest.toml`.
require("lspconfig").julials.setup{}

-- TODO: Add `clangd`

-- `efm-langserver` translates linter output into LSP
-- First, the configure linters to use

-- efm-langserver` tool: `flake8` with inline configuration
local flake8 = {
  lintCommand = "flake8 " ..
    "--ignore=" ..
      "E114," ..
      "E121," ..
      "E128," ..
      "E201," ..
      "E203," ..
      "E221," ..
      "E222," ..
      "E226," ..
      "E241," ..
      "E251," ..
      "E261," ..
      "E262," ..
      "E302," ..
      "E303," ..
      "E305," ..
      "E702," ..
      "E731," ..
      "W391," ..
      "W504 " ..
    -- "--max-line-length=80" ..
    "--indent-size=2 ",
  lintFormats = {"%f:%l:%c: %m"}}

-- efm-langserver tool: `shellcheck`
local shellcheck = {
  lintCommand = "shellcheck --format=gcc --external-sources",
  lintSource = "shellcheck",
  lintFormats = {
    "%f:%l:%c: %trror: %m",
    "%f:%l:%c: %tarning: %m",
    "%f:%l:%c: %tote: %m"}}

-- I tried to set up `fish --no-execute --debug=…` as a linter here but failed.
-- This is by the way what the fish plugins for Vim like `dag/vim-fish` are
-- doing, among other things, like e.g. leveraging `fish_indent`.

require("lspconfig").efm.setup{
  settings = {
    rootMarkers = {".git/"},
    languages = {
      python = {flake8},
      sh = {shellcheck},
    }
  },
  filetypes = {"python", "sh"},
  single_file_support = true, -- Unless `efm-langserver -v` < v0.0.38
}
EOF

endif " g:my_features["nvim_lspconfig"]

if g:my_features["vimtex"] " {{{1

" Choose compiler based on availability
let g:vimtex_compiler_method = executable("latexmk") ? "latexmk" : "tectonic"

" NOTE: In the past, I had tried to set up a `latexmk` compiler in a Docker
" container. I believe that this should in theory be perfectly possible to the
" point of basically having a drop-in `latexmk` shell script that forwards all
" the environment variables, dotfiles, and arguments into the container. But
" since I'm not aware of such a thing existing, I'd have to write it myself, at
" which point I'm probably better off just taking the plunge and installing a
" LaTeX distribution on my system.

" Parsing bibliographies for e.g. cite completion: only use `bibtex` if it is
" available. The `"vim"` backend is apparently more robust but slower.
let g:vimtex_parser_bib_backend = executable("bibtex") ? "bibtex" : "vim"

" `:VimtexCompile`, also mapped to `<localleader>ll` by default, runs a one-shot
" compilation, unless the compiler supports continuous mode, in which case it
" toggles the continuous compiler process. Let's define a function here that
" calls `:VimtexCompile` unless a compiler is running, so that either a one-shot
" compilation is triggered unless the last one hasn't finished, or the function
" makes sure a continuous compilation is running and starts one if not.
function MyVimtexCompileUnlessRunning()
  if g:loaded_vimtex && !b:vimtex.compiler.is_running()
    VimtexCompile
  endif
endfunction

augroup MyVimtexConfig
  autocmd!

  " NOTE: Commented this out for now, as it may be too much.
  " Start a one-shot or continuous compilation process on in"itialization
  "autocmd User VimtexEventInitPost call MyVimtexCompileUnlessRunning()

  " For LaTeX filetypes, create an autocommand that compiles on write unless a
  " compiler is already running (possibly in continuous mode and thus taking
  " care of the compile-on-write already)
  autocmd FileType tex
  \ autocmd! MyVimtexConfig BufWritePost * call MyVimtexCompileUnlessRunning()

  " When the last buffer of a LaTeX project is closed, remove auxiliary files
  autocmd User VimtexEventQuit call vimtex#compiler#clean(0)
augroup END

" Disable viewer interface
" NOTE: I'd need to set up a bunch of stuff to be able to use this properly. I
" was fine using `Preview.app` and compile-on-write thus far, so let's keep it
" simple like that for now.
let g:vimtex_view_enabled = 0

" Disable conceal features
let g:vimtex_syntax_conceal_disable = 1

endif " g:my_features["vimtex"]

if g:my_features["nvim_cmp"] " {{{1

lua << EOF
  local cmp = require("cmp")

  local config = {
    -- It is recommended to manage the keymapping by oneself
    mapping = {},

    sources = {
      -- NOTE: At the moment, as far as I can tell, when running `:CmpStatus`,
      -- `nvim_lsp` is listed under `# unknown source names`, as long as there
      -- is no language server active, but this changes when a language server
      -- has been attached to, so it should be okay.
      {name = "nvim_lsp"},
      {name = "buffer"}}
  }

  -- Setup LuaSnip source when `luasnip` feature is enabled
  if vim.g.my_features.luasnip ~= 0 then
    config["snippet"] = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end}

    table.insert(config.sources, {name = "luasnip"})
  end

  -- Disable autocompletion if `autocompletion` feature is disabled
  if vim.g.my_features.autocompletion == 0 then
    config["completion"] = {autocomplete = false}
  end

  -- I think several calls to `cmp.setup` would work just as well as
  -- conditionally adding parts to the `config`, but whatever…
  cmp.setup(config)

  -- The readme files for `nvim-cmp` and `cmp-nvim-lsp` advise to add these
  -- capabilities to the enabled language servers. The english in the
  -- documentation is rather broken, so I'm not exactly sure what this does.
  if vim.g.my_features["nvim_lspconfig"] then
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")

    for k, v in pairs(lspconfig.util.available_servers()) do
      lspconfig[v].setup{capabilities = capabilities}
    end
  end

  -- Helper functions for my custom tab key handler
  function my.is_cmp_completion_menu_visible()
    return cmp.visible()
  end
  function my.open_cmp_completion_menu(select)
    -- TODO: respect `select`
    return cmp.complete()
  end
  function my.close_cmp_completion_menu()
    return cmp.close()
  end
  function my.move_selection_in_cmp_completion_menu(offset)
    local options = {
      behavior = cmp.SelectBehavior.Insert,
      -- NOTE: I *think* the `count` option works as expected, but in the
      -- documentation it says something about `count > 1` doing a page up or
      -- down…
      count = math.abs(offset)}
    local func = offset <= 0 and cmp.select_prev_item or cmp.select_next_item
    return func(options)
  end

  -- TODO: Key mappings to scroll in documentation
EOF

" Override default definitions of Vimscript helper functions and redirect to Lua
function! IsCmpCompletionMenuVisible()
  return v:lua.my.is_cmp_completion_menu_visible()
endfunction
function! OpenCmpCompletionMenu(...) abort
  return a:0 > 0 ? v:lua.my.open_cmp_completion_menu(a:1) :
  \ v:lua.my.open_cmp_completion_menu()
endfunction
function! CloseCmpCompletionMenu() abort
  return v:lua.my.close_cmp_completion_menu()
endfunction
function! MoveSelectionInCmpCompletionMenu(offset) abort
  return v:lua.my.move_selection_in_cmp_completion_menu(a:offset)
endfunction

" Override this function with a version that works with the `cmp` menu
function! MyInsertModeArrowKeyHandler(key)
  if IsCmpCompletionMenuVisible()
    call CloseCmpCompletionMenu()
  elseif IsNativeCompletionMenuVisible()
    call CloseNativeCompletionMenu()
  endif
  call feedkeys(a:key, "nt")
  return "" " For `<expr>` mappings
endfunction

elseif g:my_features["autocompletion"] " {{{1

" In this section, I tried to implement a native autocompletion mechanism that
" turns on if `g:my_features["autocompletion"]` is on, but no completion plugin
" is loaded.

" NOTE: Should I ever wonder about this in the future: This autocompletion
" produces a lot of messages unless `shortmess` contains `c`.

" TODO: I am not experienced with the different kinds of cursor positions that
" can be queried by Vim's functions, like the byte position vs. the charater
" position etc. The code below may need revising to get this completely right. I
" wonder especially if `virtualedit` makes a difference here and haven't tested
" that at the time of writing this comment.

let g:my_native_autocompletion_suppression_flag = v:false
let g:my_native_autocompletion_curpos_tracker = [0, -1, -1, 0, 0]

function! MyInsertModeArrowKeyHandler(key)
  " TODO: The idea with this function is to always close and not re-open the
  " menu when arrow keys are pressed. My native autocompletion code however uses
  " the `CursorMovedI` event to open the menu, iff the cursor position has
  " changed. Hence, we would need to update the cursor position tracker here to
  " the position the cursor gets to after feeding the arrow key, so that the
  " autocompletion doesn't detect a change. This is likely complicated, so
  " instead I use this flag to suppress the menu opening while the arrow key is
  " fed. The flag is automatically disabled in the end of the `CursorMovedI`
  " handling function. I can't just disable it in this function after calling
  " `feedkeys` because the processing of the keys may not happen immediately.
  " Meanwhile, I can't be sure that `CursorMovedI` gets triggered at all after
  " feeding an arrow key (the cursor may be in a position where it can't move
  " any further). This means there can be cases where the flag is still enabled
  " when autocompletion should happen. It'd be nice to not have it like this and
  " have a consistent behavior instead, but I think I won't use this native
  " autocompletion enough to justify spending more time on the code now. Also,
  " there are plugins that do pretty much this (opening the native Vim
  " completion menu automatically without tons of other bells and whistles), so
  " resorting to one of those may be an option as well, provided the allow for
  " the behavior I am trying to implement here.
  let g:my_native_autocompletion_suppression_flag = v:true
  if IsNativeCompletionMenuVisible()
    call CloseNativeCompletionMenu()
  endif
  call feedkeys(a:key, "nt")
  return "" " For `<expr>` mappings
endfunction

function MyNativeAutocompletionHandler() abort
  " No need to check whether the popup menu is already visible as `CursorMovedI`
  " is not triggered if that's the case.
  " TODO: I have not tested what happens if `completeopt` is configured to not
  " show the menu.
  if !g:my_native_autocompletion_suppression_flag
    let curpos = getcurpos()
    if (curpos[1] != g:my_native_autocompletion_curpos_tracker[1] ||
    \   curpos[2] != g:my_native_autocompletion_curpos_tracker[2]) &&
    \ MyCompletionMenuOpeningCriterion()
      let g:my_native_autocompletion_curpos_tracker = curpos
      call OpenNativeCompletionMenu(0)
    endif
  endif
  let g:my_native_autocompletion_suppression_flag = v:false
endfunction

augroup MyNativeAutocompletion
  autocmd InsertEnter *
  \ let g:my_native_autocompletion_curpos_tracker = getcurpos()
  autocmd CursorMovedI * call MyNativeAutocompletionHandler()
augroup END

endif " g:my_features["autocompletion"]

if g:my_features["telescope"] " {{{1

lua << EOF
  local telescope = require("telescope")

  telescope.setup{
    defaults = {
      -- Use horizontal or vertical layout based on window size
      layout_strategy = "flex"
    }
  }

  -- Setup LuaSnip picker when `luasnip` feature is enabled
  if vim.g.my_features["luasnip"] ~= 0 then
    telescope.load_extension("luasnip")
  end

  -- Key mappings
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<m-/>", builtin.find_files, {})
  vim.keymap.set("n", "<c-_>", builtin.live_grep,  {}) -- `<c-_>` is ctrl+/
  vim.keymap.set("n",     "?", builtin.help_tags,  {})
EOF

endif " g:my_features["telescope"]

if g:my_features["luasnip"] " {{{1

lua << EOF
  -- Load VS Code style snippets from plugins
  -- Lazy loading is recommended
  require("luasnip.loaders.from_vscode").lazy_load()

  -- Loading SnipMate style disabled for now
  -- require("luasnip.loaders.from_snipmate").lazy_load()
EOF

endif " g:my_features["telescope"]

