local relinks = {
  -- ["@variable"] = "Normal",

  ["@tag"] = "Type",
  ["@tag.delimiter"] = "Type",
  ["@tag.attribute"] = "Identifier",

  ["@type.builtin"] = "Type",
  ["@function.builtin"] = "Function",
  ["@constant.builtin"] = "Constant",
  ["@variable.builtin"] = "@variable",

  ["@punctuation.special"] = "Delimiter",
  ["@function.macro"] = "PreProc",
  ["@keyword.conditional.ternary"] = "Operator",

  ["@type.css"] = "Special"}

for name, link in pairs(relinks) do
  vim.api.nvim_set_hl(0, name, { link = link })
end
