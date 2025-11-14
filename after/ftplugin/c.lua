-- (Note that both `c.vim` and `c.lua` will be loaded on Neovim with Lua)
if vim.g.my_features ~= nil and vim.g.my_features.ftplugin_after == 0 then
  return
end

-- See notes in `c.vim` about this.
vim.bo.commentstring = '//%s'

