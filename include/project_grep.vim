" (the following line is a modeline)
" vim: foldmethod=marker

" NOTE: When determining file type with the `file` command, some files are
" falsely determined to be binary. Hence, a list of file formats to whitelist.
let g:my_native_project_grep_ext_whitelist = ["json"]

function MyNativeProjectGrep(grep_string)
  let file_command_executable = executable("file")
  if ! has("lambda") | throw "no lambda support" | endif
  let ext_whitelist_pattern = join(map(
  \ copy(g:my_native_project_grep_ext_whitelist),
  \ {i, ext -> StrCat(".", ext, '$')}), '\|')
  " NOTE: This relies on the current working directory being the project root.
  " NOTE: Could use `&path` here instead of the working directory, but it may
  " contain things like `/usr/include` which makes it overkill for this case.
  " NOTE: This ignores hidden files and directories, maybe that's a good thing.
  let items = globpath(getcwd(), "**", v:false, v:true)
  " NOTE: In the third argument, add `"nr": "$"` to add the quickfix list at the
  " end of the stack instead of after the current one, freeing all following
  " lists. Also see `:h setqflist()`.
  call setqflist([], " ",
  \ {"title": StrCat("MyNativeProjectGrep ", a:grep_string)})
  let i_used_files = 0
  let i_matched_files = 0
  for item in items
    let use = filereadable(item)
    if use && file_command_executable
      if match(item, ext_whitelist_pattern) == -1
        let output = systemlist(StrCat("file --mime-encoding ", item))
        let use = (match(output, 'binary$') == -1)
      end
    endif
    if use
      let i_used_files += 1
      let n_before = getqflist({"size": 0})["size"]
      silent! execute StrCat("hide vimgrepadd /", a:grep_string, "/j ", item)
      let n_after = getqflist({"size": 0})["size"]
      if n_after > n_before
        let i_matched_files += 1
      endif
    " else
    "   echo StrCat("ignoring ", item)
    endif
  endfor
  echo StrCat(getqflist({"size": 0})["size"], " matches in ", i_matched_files,
  \ " files (searched ", i_used_files, " of ", len(items), " non-hidden)")
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

