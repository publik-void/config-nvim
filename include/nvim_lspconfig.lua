-- (the following line is a modeline)
-- vim: foldmethod=marker

-- If the language server is not available/runnable, the plugin should output
-- a message and otherwise essentially disable itself, I believe.

local lspconfig = require("lspconfig")

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
lspconfig.julials.setup{}

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

-- NOTE: Enclosing this in this `if` here because otherwise an error message
-- will be printed on every attempt to load a nonexistant `efm-langserver`.
if vim.fn.executable("efm-langserver") ~= 0 then
  lspconfig.efm.setup{
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
end
