if has("nvim-0.5") " NOTE: Version is a guess
  call Include("/include/symbol_substitution/symbol-dict", "lua")
elseif exists("*json_decode")
  " NOTE: The `join` is needed because older Neovim and current Vim (2022-07)
  " don't support a list as input to `json_decode`. This makes it only slightly
  " slower but still a lot better than straight VimScript.
  let g:my_symbol_dict = json_decode(join(readfile(StrCat(g:my_init_path,
  \ "/include/symbol_substitution/symbol-dict.json")), "\n"))
else
  call Include("/include/symbol_substitution/symbol-dict", "vim")
endif
