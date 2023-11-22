" (the following line is a modeline)
" vim: foldmethod=marker

function MyNativeProjectGrep(grep_string)
  " NOTE: This relies on the current working directory being the project root.
  " NOTE: Could use `&path` here instead of the working directory, but it may
  " contain things like `/usr/include` which makes it overkill for this case.
  " NOTE: This ignores hidden files and directories, maybe that's a good thing.
  let items = globpath(".", "**", v:false, v:true)
  let file_command_executable = executable("file")
  let cwd = getcwd()
  " NOTE: In the third argument, add `"nr": "$"` to add the quickfix list at the
  " end of the stack instead of after the current one, freeing all following
  " lists. Also see `:h setqflist()`.
  call setqflist([], " ",
  \ {"title": StrCat("MyNativeProjectGrep ", a:grep_string)})
  let i = 0
  for item in items
    let use = filereadable(item)
    if file_command_executable
      let output = systemlist(StrCat("file --mime-encoding ", cwd, "/", item))
      let use = use && (match(output, "binary$") == -1)
    endif
    if use
      let i = i + 1
      silent! execute StrCat("hide vimgrepadd /", a:grep_string, "/j ", item)
    " else
    "   echo StrCat("ignoring ", item)
    endif
  endfor
  echo StrCat(getqflist({"size": 0})["size"], " matches in ", i, " of ",
  \ len(items), " files")
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
\ MyNativeProjectGrep call MyNativeProjectGrep(<q-args>)

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

