-- (the following line is a modeline)
-- vim: foldmethod=marker

-- Load VS Code style snippets from plugins
-- Lazy loading is recommended
require("luasnip.loaders.from_vscode").lazy_load()

-- Loading SnipMate style disabled for now
-- require("luasnip.loaders.from_snipmate").lazy_load()

local luasnip = require("luasnip")

local choose_expand_telescope_closure = function(i)
  return function()
    if luasnip.choice_active() then
      luasnip.change_choice(i)
    elseif (i >= 0) and luasnip.expandable() then
      luasnip.expand()
    elseif (i < 0) and (vim.g.my_features["telescope"] ~= 0) then
      vim.cmd [[ Telescope luasnip ]]
    end
  end
end

local jump_closure = function(i)
  return function()
    if luasnip.jumpable() then
      luasnip.jump(i)
    end
  end
end

vim.keymap.set({"i", "s"}, "<c-k>", choose_expand_telescope_closure(-1))
vim.keymap.set({"i", "s"}, "<c-j>", choose_expand_telescope_closure(1))
vim.keymap.set({"i", "s"}, "<c-h>", jump_closure(-1))
vim.keymap.set({"i", "s"}, "<c-l>", jump_closure(1))

