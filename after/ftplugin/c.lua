-- (Note that both `c.vim` and `c.lua` will be loaded on Neovim with Lua)
if vim.g.my_features == nil or
  vim.g.my_features.native_filetype_plugins_overrides == 1 then

-- See notes in `c.vim` about this.
vim.bo.commentstring = '//%s'

end

