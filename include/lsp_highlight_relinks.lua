local relinks = {
  ["@lsp.type.property"] = "@variable",
  ["@lsp.type.macro"] = "PreProc"}

for name, link in pairs(relinks) do
  vim.api.nvim_set_hl(0, name, { link = link })
end
