" (the following line is a modeline)
" vim: foldmethod=marker

function MyNativeProjectGrep(grep_string)
  " NOTE: This relies on the current working directory being the project root.
  " NOTE: Could use `&path` here instead of the working directory, but it may
  " contain things like `/usr/include` which makes it overkill for this case.
  " NOTE: This ignores hidden files and directories, maybe that's a good thing.
  let items = globpath(".", "**", v:false, v:true)

  " NOTE: In the third argument, add `"nr": "$"` to add the quickfix list at the
  " end of the stack instead of after the current one, freeing all following
  " lists. Also see `:h setqflist()`.
  call setqflist([], " ",
  \ {"title": StrCat("MyNativeProjectGrep(\"", a:grep_string, "\")")})
  for item in items
    " NOTE: We could try and check that the files are not binary using the
    " `file` shell command if it exists on the system, but I think I'm waiting
    " with implementing that until I see that I actually could need that.
    let i = 0
    if filereadable(item)
      echo StrCat(i, "/", len(items))
      silent! execute StrCat("hide vimgrepadd /", a:grep_string, "/j ", item)
    endif
  endfor
  echo StrCat(getqflist({"size": 0})["size"], " matches")
  copen
endfunction

function MyNativeProjectGrepCommandCompletion(ArgLead, CmdLine, CursorPos)
  if exists("g:my_general_keywords")
    return g:my_general_keywords
  else
    return []
  endif
endfunction

command -nargs=1 -complete=customlist,MyNativeProjectGrepCommandCompletion
\ MyNativeProjectGrep call MyNativeProjectGrep("<args>")

function MyNativeProjectGrepCommandOpen()
  call feedkeys(":MyNativeProjectGrep\<space>\<c-i>\<c-p>", "nt")
  return ""
endfunction

" Grep the project with Ctrl+/ (escaped as `<c-_>` in Vim Script)
" The idea being that this mapping can be overriden by a project grep plugin,
" if any such plugin is enabled
if v:version > 800 " NOTE: Version is a guess
  nnoremap <c-_> <cmd>call MyNativeProjectGrepCommandOpen()<cr>
else
  nnoremap <expr> <c-_> MyNativeProjectGrepCommandOpen()
endif

