-- (the following line is a modeline)
-- vim: foldmethod=marker

-- If the language server is not available/runnable, the plugin should output
-- a message and otherwise essentially disable itself, I believe.

local lspconfig = require("lspconfig")

-- Show diagostics in floating window by pressing return.
vim.keymap.set('n', '<cr>', vim.diagnostic.open_float)

-- Jump between diagnostics positions
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- Don't show the diagnostic messages as virtual text
vim.diagnostic.config({ virtual_text = false })

-- `scheme-lsp-server` for Guile Scheme
vim.lsp.enable("guile_ls")

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
vim.lsp.enable("julials")

-- For C++ et al.
vim.lsp.enable("clangd")

-- For Javascript/Typescript
vim.lsp.enable("ts_ls")

-- For R
vim.lsp.enable("r_language_server")

-- For Python
vim.lsp.enable("jedi_language_server")

-- `efm-langserver` translates linter (or formatter, etc.) output into LSP
-- First, the configured linters to use

-- Some of these tools need a saved file. It is possible to work around this
-- with a wrapper script that saves the unsaved buffer to a temporary file, but
-- I think I'm fine with only the disk-saved file being linted.

-- `efm-langserver` tool: `flake8` with inline configuration
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
  lintFormats = {"%f:%l:%c: %m"},
  lintSource = "flake8"}

-- `efm-langserver` tool: `shellcheck`
local shellcheck = {
  lintCommand = "shellcheck --color=never --format=gcc --external-sources",
  lintFormats = {
    "%f:%l:%c: %trror: %m",
    "%f:%l:%c: %tarning: %m",
    "%f:%l:%c: %tote: %m"},
  lintSource = "shellcheck"}

-- `efm-langserver` tool: `fish`
local fish = {
  lintCommand = [[fish --no-config --no-execute ${INPUT} 2>&1]],
  lintIgnoreExitCode = true,
  lintFormats = { "%f (line %l): %m" },
  lintSource = "fish"}

-- `efm-langserver` tool: `stanc`
local stanc = {
  lintCommand =
    "stanc --warn-pedantic --warn-uninitialized --o /dev/null ${INPUT}",
  lintIgnoreExitCode = true,
  -- The message format is not systematic, hence trying to parse the
  -- messages is a nontrivial task. I'm sticking with simply displaying
  -- the full STDERR output in the first buffer line as a warning.
  lintFormats = {"%m"},
  lintSeverity = 2,
  lintSource = "stanc"}

-- I tried to set up `fish --no-execute --debug=…` as a linter here but failed.
-- This is by the way what the fish plugins for Vim like `dag/vim-fish` are
-- doing, among other things, like e.g. leveraging `fish_indent`.

-- NOTE: I had this `if`-condition here to suppress errors when `efm-langserver`
-- is missing, but I think I don't need it anymore.
-- if vim.fn.executable("efm-langserver") ~= 0 then
vim.lsp.config("efm", {
  init_options = {documentFormatting = false},
  filetypes = {"python", "sh", "bash", "zsh", "fish", "stan"},
  settings = {
    -- rootMarkers = {".git/"},
    languages = {
      python = {flake8},
      sh = {shellcheck},
      bash = {shellcheck},
      zsh = {shellcheck},
      fish = {fish},
      stan = {stanc}}}})
vim.lsp.enable("efm")

