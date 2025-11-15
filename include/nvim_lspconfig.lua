-- (the following line is a modeline)
-- vim: foldmethod=marker

-- The `lspconfig` plugin is only a provision of default configs by now.
-- The `lsp/` directories in the runtime paths hold LSP configs, and this plugin
-- adds its `lsp/` directory filled with communit-written default configs.
-- local lspconfig = require("lspconfig")

-- Show diagostics in floating window by pressing return.
vim.keymap.set('n', '<cr>', vim.diagnostic.open_float)

-- Jump between diagnostics positions
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- Don't show the diagnostic messages as virtual text
vim.diagnostic.config({ virtual_text = false })

-- The `vim.lsp.enable` way of doing this requires Neovim 0.11 or higher
if vim.fn.has("nvim-0.11") then

  -- `scheme-lsp-server` for Guile Scheme
  vim.lsp.enable("guile_ls")

  -- Julia `LanguageServer.jl`
  --
  -- For convenience, the `nvim-lspconfig` config can be found here in my setup:
  -- `.local/share/nvim/lazy/nvim-lspconfig/lsp/julials.lua`
  --
  -- As of 2025-11-15, that file suggests maintaining a central Julia
  -- environment with the `LanguageServer`-related packages:
  -- `julia --project=~/.julia/environments/nvim-lspconfig -e \
  --   'using Pkg; Pkg.add(["LanguageServer", "SymbolServer", "StaticLint"])'`
  -- And yes, for some reason, at the moment, all three packages need to be
  -- available for import even though the other two are dependencies of
  -- `LanguageServer`.
  --
  -- The `LanguageServer` only "speaks" the Julia version it is running with. As
  -- of 2025-11-15, the config provided by `nvim-lspconfig` simply runs `julia`,
  -- i.e. not `juliaup` or `julia +$(previously_inferred_project_version)` or
  -- something like that. So I guess in the case of simulatenously working on
  -- projects for different Julia versions, the ways to deal with this from
  -- least painful to most likely to work are:
  -- - Using the newest Julia version for `LanguageServer`.
  -- - Setting `juliaup default` before working on a different project.
  -- - Extending the config to detect the project's Julia version (range) and
  --   running the correct Julia version with a dedicated environment.
  --
  -- As of 2025-11-14, the document formatting capabilities (and also things
  -- like go-to-definition) don't seem to work. Neovim automatically sets
  -- `formatexpr` et al. to the LSP-based functions when the language server
  -- reports the capability (see 'lsp-defaults' help tag). That makes sense, but
  -- it's also the reason why `gq` hasn't been working for me in `.jl` files for
  -- years now. One of the workarounds proposed in the LSP help file is to use
  -- `gw` instead and I guess I'll try that for now, because there doesn't seem
  -- to be a really clean-feeling way to just disable the capability or the `gq`
  -- remapping in this case.
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
end
