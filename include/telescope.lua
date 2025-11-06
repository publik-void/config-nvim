-- (the following line is a modeline)
-- vim: foldmethod=marker

local telescope = require("telescope")
local builtin = require("telescope.builtin")

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

-- Like the picker of builtin pickers, but also showing extensions
local builtin_and_extensions = function()
  return builtin.builtin({include_extensions = true})
end

-- Key mappings
vim.keymap.set("n", "<c-space>", builtin.find_files, {})
vim.keymap.set("n", "<m-space>", builtin.buffers, {})
-- NOTE: c-_ means Ctrl + /, but also/instead sets Ctrl + - on some platforms.
-- This is confusing. Seems I need both mappings.
vim.keymap.set("n", "<c-_>", builtin.live_grep,  {})
vim.keymap.set("n", "<c-/>", builtin.live_grep,  {})
vim.keymap.set("n", "<m-/>", builtin_and_extensions,  {})

