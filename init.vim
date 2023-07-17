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
  function StrCat(x, ...)
    let str = a:x | for x in a:000 | let str ..= x | endfor | return str
  endfunction
else
  function StrCat(x, ...)
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

" A helper variable that contains the absolute path to the directory where this
" `init.vim` resides, even if the running vim used an initialization file that
" was a symlink to this one.
let g:my_init_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" A helper function to source a script file from the `init.vim`-containing
" directory. First argument is the file name without extension, the second
" argument is the file extension. If the second argument is omitted, this
" indicates that both a `.vim` and a `.lua` version exist and the most
" appropriate one for the running Vim version should be selected.
" NOTE: I think it's better not to automate detection of what files are present,
" simply for performance reasons.
" NOTE: I don't see myself using Vim9 script any time soon, so I don't support
" it here.
function Include(...)
  " NOTE: Version is a guess in the line below
  let ext = get(a:, 2, has("nvim-0.5") ? "lua" : "vim")
  execute "source" StrCat(g:my_init_path, a:1, ".", ext)
endfunction

" A helper function to check from Vimscript if Lua has JIT compilation
if has("nvim")
lua << EOF
  function my.has_jit()
    return jit ~= nil
  end
EOF
endif

" {{{2 `g:my_features`

" NOTE: `g:my_features` and `g:my_plugins` below can't be accessed from Lua if
" they are script-local. Having them be global also allows to check their status
" after startup, so maybe it's the better choice anyway.

" Feature list: used to enable/disable sections of this file
" Values should be numbers, not `v:true`/`v:false`
let g:my_features = {
\ "plugin_management": has("nvim-0.8") && v:lua.my.has_jit(),
\ "automatic_background_handling": has("nvim"),
\ "my_dim_colorscheme": 1,
\ "basic_editor_setup": 1,
\ "symbol_substitution": 1,
\ "native_filetype_plugins_config": 1,
\ "nerdcommenter": 1,
\ "vim_commentary": 0,
\ "vim_surround": 1,
\ "vim_repeat": 1,
\ "vimtex": 1,
\ "julia_vim": 0 && executable("julia"),
\ "vim_asciidoc_folding": 1,
\ "nvim_treesitter": has("nvim-0.9"),
\ "nvim_lspconfig": has("nvim-0.8"),
\ "nvim_cmp": has("nvim-0.7"),
\ "autocompletion": 1,
\ "telescope": has("nvim-0.9"),
\ "luasnip": has("nvim-0.5")}

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
\       {"name": "cmp-path", "author": "hrsh7th"},
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

" {{{2 Sourcing feature files

" TODO: Complete this (putting feature sections into individual files)
let s:my_feature_filespecs = [
\ ["plugin_management", ["auto", "vim"]],
\ ["automatic_background_handling", ["vim", "none"]],
\ ["my_dim_colorscheme", ["vim", "none"]],
\ ["basic_editor_setup", ["vim", "none"]]]
"\ "symbol_substitution": 1,
"\ "native_filetype_plugins_config": 1,
"\ "nerdcommenter": 1,
"\ "vim_commentary": 0,
"\ "vim_surround": 1,
"\ "vim_repeat": 1,
"\ "vimtex": 1,
"\ "julia_vim": 0 && executable("julia"),
"\ "vim_asciidoc_folding": 1,
"\ "nvim_treesitter": has("nvim-0.9"),
"\ "nvim_lspconfig": has("nvim-0.8"),
"\ "nvim_cmp": has("nvim-0.7"),
"\ "autocompletion": 1,
"\ "telescope": has("nvim-0.9"),
"\ "luasnip": has("nvim-0.5")}

for [feature, specs] in s:my_feature_filespecs
  if g:my_features[feature]
    let file = feature
    let spec = specs[0]
  else
    let file = StrCat("no_", feature)
    let spec = specs[1]
  endif
  if spec == "auto"
    call Include(StrCat("/include/", file))
  elseif spec != "none"
    call Include(StrCat("/include/", file), spec)
  endif
endfor

if g:my_features["symbol_substitution"] " {{{1

" TODO: Add completion for the symbol keys. As the native Vim features such as
" dictionary, spell, thesaurus, etc. all come with their own caveats that make
" it hard to do properly for this particular case, maybe do it as a custom
" source for `nvim-cmp` like this one:
" https://github.com/wincent/wincent/blob/2d926177773f72f4bf3d87b87ac8535ad45341ad/aspects/nvim/files/.config/nvim/lua/wincent/cmp/handles.lua

call Include("/include/symbol_substitution/define-symbol-dict", "vim")

function! MySymbolSubstitution(use_feedkeys) abort
  if !exists("g:my_symbol_dict") | return v:false | endif
  " TODO: Similar precautions apply here like in the TODO in
  " `MyCompletionMenuOpeningCriterion`. In particular, I am not sure if this all
  " works when `virtualedit` is set to something.
  let current_line = getline(".")
  let current_index = col(".") - 2
  let backslash_index = strridx(current_line, "\\", current_index)
  if backslash_index >= 0 && backslash_index != current_index
    let whitespace_index = strridx(current_line, " ", current_index)
    if backslash_index > whitespace_index
      let symbol_key = strpart(current_line, backslash_index + 1,
      \ current_index - backslash_index)
      if has_key(g:my_symbol_dict, symbol_key)
        let symbol_value = g:my_symbol_dict[symbol_key]
        if a:use_feedkeys
          call feedkeys(StrCat(repeat("\<bs>", strchars(symbol_key) + 1),
          \ symbol_value), "n")
        else
          let new_current_line = StrCat(
          \ strpart(current_line, 0, backslash_index),
          \ symbol_value,
          \ strpart(current_line, current_index + 1))
          if setline(".", new_current_line)
            echoerr "setline() failed during symbol substitution"
          endif
          let new_current_index = current_index - strlen(symbol_key) +
          \ strlen(symbol_value) + 1
          if setpos(".", [0, line("."), new_current_index, 0])
            echoerr "setpos() failed during symbol substitution"
          endif
        end
        return v:true
      endif
    endif
  endif
  return v:false
endfunction

endif

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
      {name = "buffer"},
      {name = "path"}}
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

