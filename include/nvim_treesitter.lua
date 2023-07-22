-- (the following line is a modeline)
-- vim: foldmethod=marker

require("nvim-treesitter.configs").setup{
  ensure_installed = {"c", "lua", "vim", "vimdoc", "query"},
  auto_install = vim.fn.executable("tree-sitter") ~= 0
}

