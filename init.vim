" `init.vim` or '`.vimrc`' file thrown together by me.

" vim: foldmethod=marker

" {{{1 General notes and todos

" TODO: Add either a thesaurus file or a thesaurus function for the english
" language? (See `:h compl-thesaurus`)
"
" TODO: In several places here, I use mappings with the `<cmd>` argument, which
" aren't supported on older Vim versions.
" * Find out the exact versions where the functionality in question was added
" * See if I can find a way to abstract this, so that I don't need to write
"   version-sepcific branching in every instance of these mappings
" * Go over all those instances and improve them
" * Check out and utilize `<SID>`, which helps with keeping functions for
"   mappings script-local.
" * `<silent>` may come in handy too.
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
" NOTE: I have now found out that sourcing a VimScript file with a bunch of code
" that sits in non-executed branches can still be way slower than not sourcing
" those parts at all. I have also found a robust way to determine the location
" of this `init.vim` file. Taken together, I am now able and choosing to put the
" feature sections into individual files.
"
" NOTE: User-defined Vimscript functions are usually named in CamelCase to avoid
" confusion with built-in functions.

" NOTE: There is an issue with syntax highlighting that I may encounter for a
" while when editing this file. Specifically, lua code blocks may show closing
" parentheses as erroneous when in fact they aren't and this may also break the
" syntax highlighting underneath…
" See https://github.com/neovim/neovim/issues/20456
" Treesitter does a better job, so I'll manually enable it here for now
" Update: It was fixed in Neovim 0.10.5
if has("nvim-0.5") && !has("nvim-0.10.5")
  augroup MyVimscriptLuaHighlightWorkaround
    autocmd FileType vim lua vim.treesitter.start()
  augroup END
endif

" {{{1 Essential initializations

" This is always set in Neovim, but doesn't hurt to set it explicitly.
" It resets some other options in Vim, which is why it should be set early
set nocompatible

" POSIX compliance needed
set shell=/bin/sh

" Helper function to convert any value to `v:false`/`v:true`
function s:AsBool(value)
  if a:value | return v:true | else | return v:false | endif
endfunction

" In Vimscript, `.` gets deprecated in favor of `..`. See `:h expr-..`.
" And this also goes for assignment, i.e. `..=` instead of `.=`.
" However, really old versions only support the single dot. This is unfortunate
" as I want (or need) to retain compatibility. Thus, let's do it with this
" function.
" if v:version > 800 " NOTE: Version is a guess
"   function StrCat(x, ...)
"     let str = a:x | for x in a:000 | let str ..= x | endfor | return str
"   endfunction
" else
"   function StrCat(x, ...)
"     let str = a:x | for x in a:000 | let str .= x | endfor | return str
"   endfunction
" endif
"
" NOTE: It's simpler and more efficient to define the above function in terms of
" `join`. I even measured, and at least for big `a:000` (though this is probably
" seldom the case) it definitely makes a difference.
function StrCat(x, ...)
  " NOTE: We could use `insert` instead of `+` here, but it looks like `a:000`
  " is immutable, so a copy has to be made anyway.
  return join([a:x] + a:000, "")
endfunction

" A helper variable that contains the absolute path to the directory where this
" `init.vim` resides, even if the running vim used an initialization file that
" was a symlink to this one.
let g:my_init_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" Add Neovim standard config path if running in Vim
if !has("nvim")
  let &runtimepath = StrCat(g:my_init_path, ",", &runtimepath)
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
    \      "+": StrCat(s:cpcp_command, " --base64=auto"),
    \      "*": StrCat(s:cpcp_command, " --base64=auto"),
    \    },
    \   "paste": {
    \      "+": StrCat(s:cpcp_command, " --base64=auto paste"),
    \      "*": StrCat(s:cpcp_command, " --base64=auto paste"),
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

" Detect TMUX
if has_key(environ(), "TMUX")
  let [socket, pid, session] = split(environ()["TMUX"], ",")
  let g:tmux = {"socket": socket, "pid": pid,  "session": session}
endif

" {{{1 Features and plugins
" {{{2 Notes

" * To check for platforms or features, use `has`
"   * e.g. to find out if it's Neovim, run `has('nvim')`
" * Vim version resides in variable `v:version`
"   * Neovim version lower bound can be checked with e.g. `has("nvim-0.8")`
" * `hostname()` returns the hostname.
" * `exists("+foo")` to check if an option exists (see `:h hidden-options`)
" * `exists("*foo")` to check if a function exists
" * `exists(":foo")` to check if a command exists
" * `exists("x:foo")` to check if a variable exists
" * `executable("foo")` to check if a shell command exists
" * There's also some good info at `:h nvim`.

" {{{2 Helper definitions

" To be used by the config as an indication that certain behavior should be
" optimized for slow machines to allow for a more fluid experience.
let g:my_is_slow_host = hostname() == "lasse-raspberrypi-1"

" A helper function to check from Vimscript if Lua has JIT compilation
if has("nvim")
lua << EOF
  function my.has_jit()
    return jit ~= nil
  end
EOF
endif

" A dict that contains sourceable file types and whether the running Vim version
" supports them
" NOTE: I think Lua support started to become really useable at Neovim 0.5,
" so I'll use that here, though I'm not completely sure.
let g:my_source_type_support = {"vim": 1, "lua": has("nvim-0.5")}

" Could add `gcc`, `clang`, `zig`, and others here.
let g:my_has_c_compiler = (executable("cc") || executable("cl"))

" A helper function to source a script file from `g:my_init_path`.
" NOTE: I don't see myself using Vim9 script any time soon, so I don't support
" it here.
" NOTE: I thought about the performance of auto-detecting files vs. not and I
" think the former is just fine (and if not, it will show up in measurements
" with the `--startuptime` command line option.
function Include(...)
  " `a:1`: File name, without extension, relative to `g:my_init_path`
  let name = a:1
  " `a:2`: File extension(s in order of priority)
  let exts = !exists("a:2") ? ["lua", "vim"] :
  \ type(a:2) == type([]) ? a:2 : [a:2]
  " `a:3`: Output error message if no file was sourced?
  let vocal = (exists("a:3") ? a:3 : exists("a:2")) ? exts : []

  let file = ""
  for ext in exts
    if g:my_source_type_support[ext]
      let putative_file = StrCat(g:my_init_path, name, ".", ext)
      if filereadable(putative_file)
        let file = putative_file
        break
      endif
    endif
  endfor

  if empty(file)
    if !empty(vocal)
      let msg = StrCat("No readable and supported file found with prefix `",
      \ g:my_init_path, name, "` for extensions ")
      let is_first_entry = v:true
      for ext in vocal
        if is_first_entry
          let is_first_entry = v:false
        else
          let msg = StrCat(msg, ", ")
        endif
        let msg = StrCat(msg, "`", ext, "`")
      endfor
      let msg = StrCat(msg, ".")
      echoerr msg
    endif
  else
    execute "source" file
  endif
endfunction

" {{{2 `g:my_features`

" NOTE: `g:my_features` and `g:my_plugins` below can't be accessed from Lua if
" they are script-local. Having them be global also allows to check their status
" after startup, so maybe it's the better choice anyway.

" Feature list: used to enable/disable sections of this file
" Values should be numbers, not `v:true`/`v:false`
let g:my_features_list = [
\ ["plugin_management", has("nvim-0.8") && v:lua.my.has_jit()],
\ ["automatic_background_handling", has("nvim")],
\ ["my_dim_colorscheme", 1],
\ ["treesitter_highlight_relinks", has("nvim-0.8")],
\ ["lsp_highlight_relinks", has("nvim-0.8")],
\ ["basic_editor_setup", 1],
\ ["symbol_substitution", 1],
\ ["project_grep", 1],
\ ["custom_html_slides_folding", 1],
\ ["ftplugin_before", 1],
\ ["ftplugin_after", 1],
\ ["syntax_before", 1],
\ ["syntax_after", 1],
\ ["indent_before", 1],
\ ["indent_after", 1],
\ ["custom_filetype_detection", 1],
\ ["nvim_lspconfig", has("nvim-0.11.3")],
\ ["nerdcommenter", 0],
\ ["vim_commentary", 1],
\ ["vim_surround", 1],
\ ["vim_repeat", 1],
\ ["vim_slime", exists("g:tmux")],
\ ["vim_fugitive", 1],
\ ["vimtex", 1],
\ ["julia_vim", executable("julia")],
\ ["vim_asciidoc_folding", 1],
\ ["stan_vim", 1],
\ ["nvim_treesitter", has("nvim-0.11") &&
\   executable("tree-sitter") &&
\   executable("tar") &&
\   executable("curl") &&
\   g:my_has_c_compiler],
\ ["nvim_cmp", has("nvim-0.7")],
\ ["autocompletion", !g:my_is_slow_host],
\ ["telescope", has("nvim-0.10.4") && v:lua.my.has_jit()],
\ ["luasnip", has("nvim-0.7")],
\ ["orgmode", 0],
\ ["guile", 1]]

let g:my_features = {}
for [feature, is_enabled] in g:my_features_list
  let g:my_features[feature] = is_enabled
endfor

" {{{2 `g:my_plugins`

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
\ "nvim_lspconfig": {
\   "name": "nvim-lspconfig",
\   "author": "neovim",
\   "options": {}},
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
\ "vim_slime": {
\   "name": "vim-slime",
\   "author": "jpalardy",
\   "options": {}},
\ "vim_fugitive": {
\   "name": "vim-fugitive",
\   "author": "tpope",
\   "options": {}},
\ "vimtex": {
\   "name": "vimtex",
\   "author": "lervag",
\   "options": {}},
\ "julia_vim": {
\   "name": "julia-vim",
\   "author": "JuliaEditorSupport",
\   "options": {}},
\ "vim_asciidoc_folding": {
\   "name": "vim-asciidoc-folding",
\   "author": "matcatc",
\   "options": {}},
\ "stan_vim": {
\   "name": "stan-vim",
\   "author": "eigenfoo",
\   "options": {}},
\ "nvim_treesitter": {
\   "name": "nvim-treesitter",
\   "author": "nvim-treesitter",
\   "options": {"build": ":TSUpdate", "branch": "main"}},
\ "nvim_cmp": {
\   "name": "nvim-cmp",
\   "author": "hrsh7th",
\   "options": {
\     "dependencies": [
\       {"name": "cmp-buffer", "author": "hrsh7th"},
\       {"name": "cmp-path", "author": "hrsh7th"},
\       {"name": "cmp-omni", "author": "hrsh7th"},
\       {"name": "cmp-nvim-lsp", "author": "hrsh7th", "options": {
\         "enabled": s:AsBool(g:my_features["nvim_lspconfig"])}},
\       {"name": "cmp_luasnip", "author": "saadparwaiz1", "options": {
\         "enabled": s:AsBool(g:my_features["luasnip"])}}]}},
\ "telescope": {
\   "name": "telescope.nvim",
\   "author": "nvim-telescope",
\   "options": {
\     "dependencies": [
\       {"name": "telescope-fzf-native.nvim", "author": "nvim-telescope",
\         "options": {"build": "make",
\           "enabled": g:my_has_c_compiler && executable("make")}},
\       {"name": "plenary.nvim", "author": "nvim-lua"},
\       {"name": "telescope-luasnip.nvim", "author": "benfowler",
\         "options": {"enabled": s:AsBool(g:my_features["luasnip"])}}]}},
\ "luasnip": {
\   "name": "LuaSnip",
\   "author": "L3MON4D3",
\   "options": {
\     "version": "v2.*",
\     "build": g:my_has_c_compiler && executable("make") ?
\       "make install_jsregexp" : v:null,
\     "dependencies": [
\       {"name": "friendly-snippets", "author": "rafamadriz"}]}},
\ "orgmode": {
\   "name": "orgmode",
\   "author": "nvim-orgmode",
\   "options": {}},
\ "guile": {
\   "name": "guile.vim",
\   "author": "HiPhish",
\   "options": {
\     "url": "https://gitlab.com/HiPhish/guile.vim.git"}},
\ } " Separated this `}` to not unintentionally create a fold marker

" {{{2 Notes about features/plugins

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
" `JuliaEditorSupport/julia-vim`: This plugin adds like 30ms startup time.
" However, turns out that lazy-loading it results in the natively shipped Julia
" syntax/indent/ftplugin files to be run first, so that the plugin's versions
" will likely quit early. So I guess I'll have to accept that extra startup
" time.
" I lazy load it if possible. For some reason it doesn't work with `lazy.nvim`s
" `ft` option, but with `event = "FileType julia"` it's fine (this was as of
" 2023-06).
" There is overlap between the `indent`, `syntax`, etc. files shipped with
" (Neo-)Vim and those provided by the plugin `julia-vim`. In particular, the
" files shipped with (Neo-)Vim are based on those of the plugin, but don't
" perfectly track it – the plugin versions seem to be more up to date usually,
" while the non-plugin versions may have some other additional changes for
" whatever reason.
" In any case, I've decided to do the configuration through that system instead
" of a plugin-specific config file, so it applies both to the plugin, if loaded,
" and the natively shipped files otherwise.
"
" `matcatc/vim-asciidoc-folding`: As of 2023-06, it seems that Neovim (though
" not Vim) comes with an AsciiDoc syntax file, but there's no support for folds.
" This plugin provides an `ftplugin`-based script with a fold expression. Seems
" like LSP support for AsciiDoc is something that's been planned but not made a
" reality yet. Treesitter support is also something that can be found as a
" non-checked todo in GitHub issues.
"
" `nvim-treesitter/nvim-treesitter`: As of 2025-11-14, there is a rewrite on the
" `main` branch of the repository. This only supports Neovim 0.11 and higher at
" the moment, so I'll the plugin for those versions. In addition, their policy
" is to always only support the latest stable release, which means in case I
" don't immediately update all the Neovims where I want to use treesitter, I
" should probably add fixed commits based on the stable release version in the
" plugin's `options` dict.
"
" {{{2 Sourcing feature files

" For configurations that need to be done before the plugin is loaded.
" `lazy.nvim` supports an `init` field to perform these, but for compatibility
" with non-`lazy.nvim` setups I do it like this instead.
for plugin in keys(g:my_plugins)
  let is_enabled = g:my_features[plugin]
  let name = StrCat("/include/", "before_", is_enabled ? "" : "no_", plugin)
  call Include(name)
endfor

for [feature, is_enabled] in g:my_features_list
  let name = StrCat("/include/", is_enabled ? "" : "no_", feature)
  call Include(name)
endfor


