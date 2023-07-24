" (the following line is a modeline)
" vim: foldmethod=marker

" In this script, I tried to implement a native autocompletion mechanism that
" turns on if `g:my_features["autocompletion"]` is on, but no completion plugin
" is loaded.

" NOTE: Should I ever wonder about this in the future: This autocompletion
" produces a lot of messages unless `shortmess` contains `c`.

" TODO: I am not experienced with the different kinds of cursor positions that
" can be queried by Vim's functions, like the byte position vs. the charater
" position etc. The code below may need revising to get this completely right. I
" wonder especially if `virtualedit` or `conceallevel` make a difference here
" and haven't tested that at the time of writing this comment.

" TODO: I have seen completion happening when pressing backspace in insert mode.
" Meaning not only opening the menu, but actually accepting some item. This was
" however on Neovim version 0.4.4, so who knows if this is a problem of my code
" generally or only the old version stuff.

let g:my_native_autocompletion_suppression_flag = v:false
let g:my_native_autocompletion_curpos_tracker = [0, -1, -1, 0, 0]

function! MyInsertModeArrowKeyHandler(key)
  " TODO: The idea with this function is to always close and not re-open the
  " menu when arrow keys are pressed. My native autocompletion code however uses
  " the `CursorMovedI` event to open the menu, iff the cursor position has
  " changed. Hence, we would need to update the cursor position tracker here to
  " the position the cursor gets to after feeding the arrow key, so that the
  " autocompletion doesn't detect a change. This is likely complicated, so
  " instead I use this flag to suppress the menu opening while the arrow key is
  " fed. The flag is automatically disabled in the end of the `CursorMovedI`
  " handling function. I can't just disable it in this function after calling
  " `feedkeys` because the processing of the keys may not happen immediately.
  " Meanwhile, I can't be sure that `CursorMovedI` gets triggered at all after
  " feeding an arrow key (the cursor may be in a position where it can't move
  " any further). This means there can be cases where the flag is still enabled
  " when autocompletion should happen. It'd be nice to not have it like this and
  " have a consistent behavior instead, but I think I won't use this native
  " autocompletion enough to justify spending more time on the code now. Also,
  " there are plugins that do pretty much this (opening the native Vim
  " completion menu automatically without tons of other bells and whistles), so
  " resorting to one of those may be an option as well, provided the allow for
  " the behavior I am trying to implement here.
  let g:my_native_autocompletion_suppression_flag = v:true
  if IsNativeCompletionMenuVisible()
    call CloseNativeCompletionMenu()
  endif
  call feedkeys(a:key, "nt")
  return "" " For `<expr>` mappings
endfunction

function MyNativeAutocompletionHandler() abort
  " No need to check whether the popup menu is already visible as `CursorMovedI`
  " is not triggered if that's the case.
  " TODO: I have not tested what happens if `completeopt` is configured to not
  " show the menu.
  if !g:my_native_autocompletion_suppression_flag
    let curpos = getcurpos()
    if (curpos[1] != g:my_native_autocompletion_curpos_tracker[1] ||
    \   curpos[2] != g:my_native_autocompletion_curpos_tracker[2]) &&
    \ MyCompletionMenuOpeningCriterion()
      let g:my_native_autocompletion_curpos_tracker = curpos
      call OpenNativeCompletionMenu(0)
    endif
  endif
  let g:my_native_autocompletion_suppression_flag = v:false
endfunction

augroup MyNativeAutocompletion
  autocmd InsertEnter *
  \ let g:my_native_autocompletion_curpos_tracker = getcurpos()
  autocmd CursorMovedI * call MyNativeAutocompletionHandler()
augroup END

