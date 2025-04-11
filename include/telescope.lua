-- (the following line is a modeline)
-- vim: foldmethod=marker

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
vim.keymap.set("n", "<c-space>", builtin.buffers, {})
vim.keymap.set("n", "<m-space>", builtin.find_files, {})
-- NOTE: c-_ means Ctrl + /, but also/instead sets Ctrl + - on some platforms.
-- This is confusing. Seems I need both mappings.
vim.keymap.set("n", "<c-_>", builtin.live_grep,  {})
vim.keymap.set("n", "<c-/>", builtin.live_grep,  {})
vim.keymap.set("n", "<m-/>", builtin.help_tags,  {})

