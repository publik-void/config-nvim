local has_cmp, cmp = pcall(require, 'cmp')
if has_cmp and vim.g.my_features.symbol_substitution ~= 0 then
  local source = {}

  function source:is_available()
    -- NOTE: The Julia LSP server provides unicode-to-LaTeX substitutions too.
    -- Even though I like my approach a little better, it seems nontrivial to
    -- disable only that part of the Julia LSP server, so instead, I'll disable
    -- this source whenever the former is active.
    local has_julials = false
    for _, source in pairs(cmp.core.sources) do
      if source:get_debug_name() == "nvim_lsp:julials" then
        has_julials = true
      end
    end
    return vim.g.my_symbol_dict ~= nil and not has_julials
  end

  function source:get_keyword_pattern()
    return [[\\\(\a\|_\|:\)*]]
  end

  function source:complete(params, callback)
    local input =
      string.sub(params.context.cursor_before_line, params.offset + 1)
    local items = {}
    for k, v in pairs(vim.g.my_symbol_dict) do
      if vim.startswith(k, input) then
        table.insert(items, {
          label = "\\" .. k,
          labelDetails = {description = v},
          insertText = v})
      end
    end

    callback(items)
  end

  cmp.register_source("symbol_substitution", source)
end
