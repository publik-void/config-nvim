" (the following line is a modeline)
" vim: foldmethod=marker

call Include("/include/symbol_substitution/define-symbol-dict", "vim")

function! MySymbolSubstitution(use_feedkeys) abort
  if !exists("g:my_symbol_dict") | return v:false | endif
  " TODO: Similar precautions apply here like in the TODO in
  " `MyCompletionMenuOpeningCriterion`. In particular, I am not sure if this all
  " works when `virtualedit` is set to something or `conceallevel` is > 0.
  let current_line = getline(".")
  let current_index = col(".") - 2
  let backslash_index = strridx(current_line, "\\", current_index)
  if backslash_index >= 0 && backslash_index != current_index
    let whitespace_index = strridx(current_line, " ", current_index)
    if backslash_index > whitespace_index
      let symbol_key = strpart(current_line, backslash_index + 1,
      \ current_index - backslash_index)
      if has_key(g:my_symbol_dict, symbol_key)
        let symbol_value = g:my_symbol_dict[symbol_key]
        if a:use_feedkeys
          call feedkeys(StrCat(repeat("\<bs>", strchars(symbol_key) + 1),
          \ symbol_value), "n")
        else
          let new_current_line = StrCat(
          \ strpart(current_line, 0, backslash_index),
          \ symbol_value,
          \ strpart(current_line, current_index + 1))
          if setline(".", new_current_line)
            echoerr "setline() failed during symbol substitution"
          endif
          let new_current_index = current_index - strlen(symbol_key) +
          \ strlen(symbol_value) + 1
          if setpos(".", [0, line("."), new_current_index, 0])
            echoerr "setpos() failed during symbol substitution"
          endif
        end
        return v:true
      endif
    endif
  endif
  return v:false
endfunction

