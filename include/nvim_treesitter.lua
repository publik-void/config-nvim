local ts = require("nvim-treesitter")

local languages = {
  -- Included with Neovim by default, but included here so that
  -- `nvim-treesitter` recognizes them.
  "c",
  "lua",
  "markdown",
  "query",
  "vim",
  "vimdoc",

  "awk",
  "bash",
  "bibtex",
  "cmake",
  "cpp",
  "css",
  "csv",
  "desktop",
  "dockerfile",
  "fish",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "gpg",
  "html",
  -- "html_tags" -- not sure what this is
  "http",
  "javascript",
  "json",
  "julia",
  "latex",
  "make",
  "markdown_inline",
  "ninja",
  "passwd",
  "printf",
  "psv",
  "python",
  "r",
  "readline",
  "requirements",
  "scheme",
  "ssh_config",
  "tmux",
  "toml",
  "tsv",
  "typescript",
  "xml",
  "xresources",
  "xcompose",
  "yaml",
  "zsh"}

ts.install(languages):wait(10 * 60 * 1000)

local ts_augroup = vim.api.nvim_create_augroup("TreesitterAutoEnable",
  { clear = true })

-- My approach here is to simply enable treesitter for any language for which an
-- installed parser is registered. So effectively, the toggle for whether a
-- language uses treesitter is the installation. I think this is simplest as
-- long as I don't need language-specific configuration. It's implemented as an
-- autocommand that simply tries to start treesitter.
vim.api.nvim_create_autocmd("FileType", {
  group = ts_augroup,
  pattern = { "*" },
  callback = function(args)
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end

    -- Since I define `foldmethod = syntax` by default and treesitter replaces
    -- the syntax highlighting machinery, it only makes sense to also let it
    -- take charge of folding – iff the `foldmethod` is not set to something
    -- else for the filetype.
    -- If I wanted to continue relying on `syntax`, I would have to enable the
    -- regexp-based syntax highlighting too, which seems wrong to me.
    -- But this would be how to do it in case I need it at some point:
    -- vim.bo[args.buf].syntax = "on"
    if vim.wo.foldmethod == "syntax" then
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo.foldmethod = "expr"
    end

    -- It would be cool to use a treesitter-based indentexpr, but it seems like
    -- the indenting that has been implemented at least as of 2025-11-14 does
    -- not behave the way I would like it to and is not configurable. Maybe it's
    -- worth checking if this has changed in the future.
    -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end})

