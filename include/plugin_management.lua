-- (the following line is a modeline)
-- vim: foldmethod=marker

-- Use `lazy.nvim` as plugin manager
-- This is the installation code recommended in their readme file:
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print(vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }))
end
vim.opt.rtp:prepend(lazypath)

-- Function to transform vim.g.my_plugins into a Lazy plugin spec
local function to_spec(plugin, feature)
  local spec = {string.format("%s/%s", plugin.author, plugin.name)}
  if feature ~= nil then
    spec["enabled"] = vim.g.my_features[feature] ~= 0
  end
  if plugin.options ~= nil then
    for key, value in pairs(plugin.options) do
      spec[key] = value
    end
    if plugin.options.dependencies ~= nil then
      spec.dependencies = {}
      for i, dependency in ipairs(plugin.options.dependencies) do
        table.insert(spec.dependencies, to_spec(dependency))
      end
    end
  end
  return spec
end

-- Construct plugin spec, disable based on feature switches
-- NOTE: I had a hard time finding a neater way of constructing tables than
-- consecutive assignments or `insert` calls.
local plugins = {}
for feature, plugin in pairs(vim.g.my_plugins) do
  table.insert(plugins, to_spec(plugin, feature))
end

-- Options
local opts = nil -- nothing for now

-- Run `lazy.nvim`
require("lazy").setup(plugins, opts)
