" (the following line is a modeline)
" vim: foldmethod=marker

if g:my_features["symbol_substitution"]
  call Include("/include/nvim_cmp/symbol_substitution_source", "lua")
endif

lua << EOF
  local cmp = require("cmp")

  local config = {
    -- It is recommended to manage the keymapping by oneself
    mapping = {},

    sources = {
      -- NOTE: At the moment, as far as I can tell, when running `:CmpStatus`,
      -- `nvim_lsp` is listed under `# unknown source names`, as long as there
      -- is no language server active, but this changes when a language server
      -- has been attached to, so it should be okay.
      {name = "nvim_lsp"},
      -- NOTE: There seems to be an issue with `cmp-omni` when `cmp-nvim-lsp` is
      -- present too. It seems it's not trivial to fix, but maybe there'll be
      -- some update in the future that helps.
      {name = "omni"},
      {name = "buffer"},
      {name = "path"}}
  }

  -- Setup my custom symbol substitution source if enabled
  if vim.g.my_features.symbol_substitution == 1 then
    table.insert(config.sources, {name = "symbol_substitution"})
  end

  -- Setup LuaSnip source when `luasnip` feature is enabled
  if vim.g.my_features.luasnip == 1 then
    config.snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end}

    table.insert(config.sources, {name = "luasnip"})
  end

  -- Setup Org Mode source if `orgmode` feature is enabled
  if vim.g.my_features.orgmode == 1 then
    table.insert(config.sources, {name = "orgmode"})
  end

  -- Disable autocompletion if `autocompletion` feature is disabled
  if vim.g.my_features.autocompletion ~= 1 then
    config.completion = {autocomplete = false}
  end

  -- I think several calls to `cmp.setup` would work just as well as
  -- conditionally adding parts to the `config`, but whatever…
  cmp.setup(config)

  -- The readme files for `nvim-cmp` and `cmp-nvim-lsp` advise to add these
  -- capabilities to the enabled language servers. The english in the
  -- documentation is rather broken, so I'm not exactly sure what this does.
  if vim.g.my_features.nvim_lspconfig == 1 then
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")

    for k, v in pairs(lspconfig.util.available_servers()) do
      lspconfig[v].setup{capabilities = capabilities}
    end
  end

  -- Helper functions for my custom tab key handler
  function my.is_cmp_completion_menu_visible()
    return cmp.visible()
  end
  function my.open_cmp_completion_menu(select)
    -- TODO: respect `select`
    return cmp.complete()
  end
  function my.close_cmp_completion_menu()
    return cmp.close()
  end
  function my.move_selection_in_cmp_completion_menu(offset)
    local options = {
      behavior = cmp.SelectBehavior.Insert,
      -- NOTE: I *think* the `count` option works as expected, but in the
      -- documentation it says something about `count > 1` doing a page up or
      -- down…
      count = math.abs(offset)}
    local func = offset <= 0 and cmp.select_prev_item or cmp.select_next_item
    return func(options)
  end

  -- TODO: Key mappings to scroll in documentation
  -- TODO: Key mapping to accept snippet
EOF

" Override default definitions of Vimscript helper functions and redirect to Lua
function! IsCmpCompletionMenuVisible()
  return v:lua.my.is_cmp_completion_menu_visible()
endfunction
function! OpenCmpCompletionMenu(...) abort
  return a:0 > 0 ? v:lua.my.open_cmp_completion_menu(a:1) :
  \ v:lua.my.open_cmp_completion_menu()
endfunction
function! CloseCmpCompletionMenu() abort
  return v:lua.my.close_cmp_completion_menu()
endfunction
function! MoveSelectionInCmpCompletionMenu(offset) abort
  return v:lua.my.move_selection_in_cmp_completion_menu(a:offset)
endfunction

" Override this function with a version that works with the `cmp` menu
function! MyInsertModeArrowKeyHandler(key)
  if IsCmpCompletionMenuVisible()
    call CloseCmpCompletionMenu()
  elseif IsNativeCompletionMenuVisible()
    call CloseNativeCompletionMenu()
  endif
  call feedkeys(a:key, "nt")
  return "" " For `<expr>` mappings
endfunction

